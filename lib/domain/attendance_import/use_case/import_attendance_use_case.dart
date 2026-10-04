import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance/repository/attendance_repository.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_exception.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_file.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_row_failure.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_sheet.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_stage.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_summary.dart';
import 'package:hr_management_system/domain/attendance_import/parser/attendance_import_value_parser.dart';
import 'package:hr_management_system/domain/attendance_import/repository/attendance_import_repository.dart';
import 'package:hr_management_system/domain/attendance_import/service/attendance_import_employee_factory.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/domain/department/repository/department_repository.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/employee/repository/employee_repository.dart';

class ImportAttendanceUseCase {
  final AttendanceRepository attendanceRepository;
  final EmployeeRepository employeeRepository;
  final DepartmentRepository departmentRepository;
  final AttendanceImportRepository importRepository;
  final AttendanceImportEmployeeFactory employeeFactory;
  final void Function(AttendanceImportStage stage)? onStage;

  ImportAttendanceUseCase({
    required this.attendanceRepository,
    required this.employeeRepository,
    required this.departmentRepository,
    required this.importRepository,
    this.employeeFactory = const AttendanceImportEmployeeFactory(),
    this.onStage,
  });

  Future<AttendanceImportSummary> call(AttendanceImportFile file) async {
    onStage?.call(AttendanceImportStage.parsing);

    final sheet = importRepository.parseWorkbook(file.bytes);

    _validateSheet(sheet);

    final employeesById = <String, EmployeeEntity>{};
    final employeesByNationalId = <String, EmployeeEntity>{};

    for (final employee in await employeeRepository.getEmployees()) {
      _indexEmployee(employeesById, employeesByNationalId, employee);
    }

    final departmentsById = <String, DepartmentEntity>{};
    final departmentsByName = <String, DepartmentEntity>{};

    for (final department in await departmentRepository.getDepartments()) {
      _indexDepartment(departmentsById, departmentsByName, department);
    }

    onStage?.call(AttendanceImportStage.importing);

    var employeesCreated = 0;
    var existingEmployeesUsed = 0;
    var added = 0;
    var updated = 0;
    var skipped = 0;
    var failed = 0;

    final issues = <AttendanceImportRowIssue>[];

    for (final row in sheet.rows) {
      if (_isEmptyRow(row, sheet)) {
        skipped++;
        continue;
      }

      try {
        final attendance = _readAttendance(row, sheet);

        final employee = await _resolveEmployee(
          row,
          sheet,
          employeesById,
          employeesByNationalId,
          departmentsById,
          departmentsByName,
        );

        if (employee.created) {
          employeesCreated++;
        } else {
          existingEmployeesUsed++;
        }

        final existing = await attendanceRepository
            .getAttendanceByEmployeeAndDate(
              employee.employee.id,
              attendance.date,
            );

        if (existing == null) {
          await attendanceRepository.addAttendance(
            AttendanceEntity(
              id: AttendanceEntity.documentIdFor(
                employee.employee.id,
                attendance.date,
              ),
              employeeId: employee.employee.id,
              attendanceDate: attendance.date,
              status: AttendanceEntity.presentStatus,
              checkInTime: attendance.checkIn,
              checkOutTime: attendance.checkOut,
            ),
          );

          added++;
          continue;
        }

        await attendanceRepository.updateAttendance(
          AttendanceEntity(
            id: existing.id,
            employeeId: employee.employee.id,
            attendanceDate: attendance.date,
            status: existing.status,
            checkInTime: attendance.checkIn ?? existing.checkInTime,
            checkOutTime: attendance.checkOut ?? existing.checkOutTime,
          ),
        );

        updated++;
      } on AttendanceImportRowFailure catch (failure) {
        failed++;
        issues.add(
          AttendanceImportRowIssue(
            rowNumber: row.rowNumber,
            reason: failure.reason,
          ),
        );
      } catch (error) {
        failed++;
        issues.add(
          AttendanceImportRowIssue(
            rowNumber: row.rowNumber,
            reason: 'attendance_import.row_save_failed',
          ),
        );
      }
    }

    return AttendanceImportSummary(
      totalRows: sheet.rows.length - skipped,
      added: added,
      updated: updated,
      skipped: skipped,
      failed: failed,
      employeesCreated: employeesCreated,
      existingEmployeesUsed: existingEmployeesUsed,
      issues: issues,
    );
  }

  _ImportedAttendance _readAttendance(
    AttendanceImportSheetRow row,
    AttendanceImportSheet sheet,
  ) {
    final date = AttendanceImportValueParser.parseDate(
      row.valueAt(sheet.indexOf(AttendanceImportColumns.attendanceDate)),
    );

    if (date == null) {
      throw const AttendanceImportRowFailure('attendance_import.invalid_date');
    }

    final checkInValue = row.valueAt(
      sheet.indexOf(AttendanceImportColumns.checkIn),
    );

    final checkOutValue = row.valueAt(
      sheet.indexOf(AttendanceImportColumns.checkOut),
    );

    final hasCheckInValue = !AttendanceImportValueParser.isBlank(checkInValue);

    final hasCheckOutValue = !AttendanceImportValueParser.isBlank(
      checkOutValue,
    );

    if (!hasCheckInValue && !hasCheckOutValue) {
      throw const AttendanceImportRowFailure(
        'attendance_import.missing_times',
      );
    }

    DateTime? checkIn;

    if (hasCheckInValue) {
      checkIn = AttendanceImportValueParser.parseTime(checkInValue, date: date);

      if (checkIn == null) {
        throw const AttendanceImportRowFailure(
          'attendance_import.invalid_check_in',
        );
      }
    }

    DateTime? checkOut;

    if (hasCheckOutValue) {
      checkOut = AttendanceImportValueParser.parseTime(
        checkOutValue,
        date: date,
      );

      if (checkOut == null) {
        throw const AttendanceImportRowFailure(
          'attendance_import.invalid_check_out',
        );
      }
    }

    if (checkOut != null && checkIn == null) {
      throw const AttendanceImportRowFailure(
        'attendance_import.check_out_without_check_in',
      );
    }

    return _ImportedAttendance(
      date: date,
      checkIn: checkIn,
      checkOut: checkOut,
    );
  }

  Future<_ResolvedEmployee> _resolveEmployee(
    AttendanceImportSheetRow row,
    AttendanceImportSheet sheet,
    Map<String, EmployeeEntity> employeesById,
    Map<String, EmployeeEntity> employeesByNationalId,
    Map<String, DepartmentEntity> departmentsById,
    Map<String, DepartmentEntity> departmentsByName,
  ) async {
    final employeeId = _readText(
      row,
      sheet,
      AttendanceImportColumns.employeeId,
    );

    final nationalId = _readText(
      row,
      sheet,
      AttendanceImportColumns.nationalId,
    );

    if (employeeId == null && nationalId == null) {
      throw const AttendanceImportRowFailure(
        'attendance_import.employee_key_required',
      );
    }

    final byId = employeeId == null ? null : employeesById[employeeId.trim()];

    final byNationalId = nationalId == null
        ? null
        : employeesByNationalId[nationalId.trim()];

    if (byId != null && byNationalId != null && byId.id != byNationalId.id) {
      throw const AttendanceImportRowFailure(
        'attendance_import.employee_key_mismatch',
      );
    }

    final existing = byId ?? byNationalId;

    if (existing != null) {
      return _ResolvedEmployee(existing);
    }

    final departmentId = _resolveDepartmentId(
      row,
      sheet,
      departmentsById,
      departmentsByName,
    );

    final employee = employeeFactory.build(
      row: row,
      sheet: sheet,
      employeeId: employeeId,
      departmentId: departmentId,
    );

    await employeeRepository.addEmployee(employee);

    _indexEmployee(employeesById, employeesByNationalId, employee);

    return _ResolvedEmployee(employee, created: true);
  }

  String _resolveDepartmentId(
    AttendanceImportSheetRow row,
    AttendanceImportSheet sheet,
    Map<String, DepartmentEntity> departmentsById,
    Map<String, DepartmentEntity> departmentsByName,
  ) {
    final departmentId = _readText(
      row,
      sheet,
      AttendanceImportColumns.departmentId,
    );

    final departmentName = _readText(
      row,
      sheet,
      AttendanceImportColumns.departmentName,
    );

    final byId = departmentId == null
        ? null
        : departmentsById[departmentId.trim()];

    final byName = departmentName == null
        ? null
        : departmentsByName[departmentName.trim().toLowerCase()];

    if (byId != null && byName != null && byId.id != byName.id) {
      throw const AttendanceImportRowFailure(
        'attendance_import.department_key_mismatch',
      );
    }

    final department = byId ?? byName;

    if (department != null) {
      return department.id;
    }

    if (departmentId != null || departmentName != null) {
      throw const AttendanceImportRowFailure(
        'attendance_import.department_not_found',
      );
    }

    throw const AttendanceImportRowFailure(
      'attendance_import.department_required',
    );
  }

  void _indexEmployee(
    Map<String, EmployeeEntity> employeesById,
    Map<String, EmployeeEntity> employeesByNationalId,
    EmployeeEntity employee,
  ) {
    if (employee.id.trim().isNotEmpty) {
      employeesById[employee.id.trim()] = employee;
    }

    if (employee.nationalId.trim().isNotEmpty) {
      employeesByNationalId[employee.nationalId.trim()] = employee;
    }
  }

  void _indexDepartment(
    Map<String, DepartmentEntity> departmentsById,
    Map<String, DepartmentEntity> departmentsByName,
    DepartmentEntity department,
  ) {
    departmentsById[department.id.trim()] = department;
    departmentsByName[department.name.trim().toLowerCase()] = department;
  }

  String? _readText(
    AttendanceImportSheetRow row,
    AttendanceImportSheet sheet,
    String column,
  ) {
    return AttendanceImportValueParser.readText(
      row.valueAt(sheet.indexOf(column)),
    );
  }

  bool _isEmptyRow(AttendanceImportSheetRow row, AttendanceImportSheet sheet) {
    for (final column in sheet.columnIndexes.keys) {
      if (!AttendanceImportValueParser.isBlank(
        row.valueAt(sheet.indexOf(column)),
      )) {
        return false;
      }
    }

    return true;
  }

  void _validateSheet(AttendanceImportSheet sheet) {
    final missing = <String>[];

    if (!sheet.has(AttendanceImportColumns.employeeId) &&
        !sheet.has(AttendanceImportColumns.nationalId)) {
      missing.add('attendance_import.column.employee_or_national_id');
    }

    if (!sheet.has(AttendanceImportColumns.attendanceDate)) {
      missing.add('attendance_import.column.attendance_date');
    }

    if (!sheet.has(AttendanceImportColumns.checkIn) &&
        !sheet.has(AttendanceImportColumns.checkOut)) {
      missing.add('attendance_import.column.check_in_or_check_out');
    }

    if (missing.isNotEmpty) {
      throw AttendanceImportException(
        'attendance_import.missing_columns',
        namedArgs: {'columns': missing.join(', ')},
      );
    }

    if (sheet.rows.isEmpty) {
      throw const AttendanceImportException(
        'attendance_import.no_records',
      );
    }
  }
}

class _ImportedAttendance {
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;

  const _ImportedAttendance({required this.date, this.checkIn, this.checkOut});
}

class _ResolvedEmployee {
  final EmployeeEntity employee;
  final bool created;

  const _ResolvedEmployee(this.employee, {this.created = false});
}
