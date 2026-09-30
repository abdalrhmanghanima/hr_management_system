import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance/repository/attendance_repository.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_file.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_sheet.dart';
import 'package:hr_management_system/domain/attendance_import/repository/attendance_import_repository.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/domain/department/repository/department_repository.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/employee/repository/employee_repository.dart';
import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';
import 'package:hr_management_system/domain/general_settings/repository/general_settings_repository.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/domain/official_holiday/repository/official_holiday_repository.dart';

const String testEmployeeId = 'EMP001';

const String testNationalId = '29801011234567';

final DateTime testAttendanceDate = DateTime(2026, 9, 27);

EmployeeEntity buildEmployee({
  String id = testEmployeeId,
  String nationalId = testNationalId,
  String fullName = 'Ahmed Mohamed',
  String departmentId = 'dep-1',
}) {
  return EmployeeEntity(
    id: id,
    fullName: fullName,
    address: 'Cairo',
    phoneNumber: '01000000000',
    birthDate: DateTime(1990, 1, 1),
    nationalId: nationalId,
    nationality: 'Egyptian',
    gender: 'Male',
    departmentId: departmentId,
    contractDate: DateTime(2024, 1, 1),
    salary: 15000,
  );
}

AttendanceEntity buildAttendance({
  required String id,
  String employeeId = testEmployeeId,
  DateTime? date,
  String status = AttendanceEntity.presentStatus,
  DateTime? checkIn,
  DateTime? checkOut,
}) {
  final attendanceDate = date ?? testAttendanceDate;

  return AttendanceEntity(
    id: id,
    employeeId: employeeId,
    attendanceDate: attendanceDate,
    status: status,
    checkInTime: checkIn,
    checkOutTime: checkOut,
  );
}

Uint8List buildXlsxBytes({
  List<String> headers = const [
    'Employee ID',
    'National ID',
    'Employee Name',
    'Attendance Date',
    'Check In',
    'Check Out',
  ],
  required List<List<Object?>> rows,
  String sheetName = 'Sheet1',
  int headerRowIndex = 0,
}) {
  final excel = Excel.createExcel();

  final sheet = excel[sheetName];

  for (var column = 0; column < headers.length; column++) {
    sheet
        .cell(
          CellIndex.indexByColumnRow(
            columnIndex: column,
            rowIndex: headerRowIndex,
          ),
        )
        .value = TextCellValue(
      headers[column],
    );
  }

  for (var row = 0; row < rows.length; row++) {
    final values = rows[row];

    for (var column = 0; column < values.length; column++) {
      final value = values[column];

      if (value == null) {
        continue;
      }

      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: column,
              rowIndex: headerRowIndex + row + 1,
            ),
          )
          .value = _toCellValue(
        value,
      );
    }
  }

  return Uint8List.fromList(excel.save()!);
}

Uint8List buildXlsxBytesWithAbsoluteRelationshipTargets({
  List<String> headers = const [
    'Employee ID',
    'National ID',
    'Employee Name',
    'Attendance Date',
    'Check In',
    'Check Out',
  ],
  required List<List<Object?>> rows,
  String sheetName = 'Sheet1',
  int headerRowIndex = 0,
}) {
  final bytes = buildXlsxBytes(
    headers: headers,
    rows: rows,
    sheetName: sheetName,
    headerRowIndex: headerRowIndex,
  );

  final archive = ZipDecoder().decodeBytes(bytes);

  _absolutizeTargets(archive, 'xl/_rels/workbook.xml.rels', '/xl/');
  _absolutizeTargets(archive, '_rels/.rels', '/');

  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

void _absolutizeTargets(Archive archive, String partName, String prefix) {
  final part = archive.findFile(partName);

  if (part == null) {
    throw StateError('Missing relationship part: $partName');
  }

  part.decompress();

  final original = utf8.decode(part.content as List<int>);
  final patched = original.replaceAll('Target="', 'Target="$prefix');

  if (patched == original) {
    throw StateError('No relationship targets found in: $partName');
  }

  final content = utf8.encode(patched);

  archive.addFile(ArchiveFile(partName, content.length, content));
}

CellValue _toCellValue(Object value) {
  if (value is CellValue) {
    return value;
  }

  if (value is DateTime) {
    if (value.hour == 0 && value.minute == 0 && value.second == 0) {
      return DateCellValue.fromDateTime(value);
    }

    return DateTimeCellValue.fromDateTime(value);
  }

  if (value is int) {
    return IntCellValue(value);
  }

  if (value is double) {
    return DoubleCellValue(value);
  }

  return TextCellValue(value.toString());
}

AttendanceImportFile buildImportFile({
  Uint8List? bytes,
  String name = 'attendance.xlsx',
}) {
  return AttendanceImportFile(
    name: name,
    bytes: bytes ?? buildXlsxBytes(rows: const []),
  );
}

AttendanceImportSheet buildSheet({
  Map<String, int>? columnIndexes,
  required List<AttendanceImportSheetRow> rows,
}) {
  return AttendanceImportSheet(
    columnIndexes:
        columnIndexes ??
        const {
          AttendanceImportColumns.employeeId: 0,
          AttendanceImportColumns.nationalId: 1,
          AttendanceImportColumns.employeeName: 2,
          AttendanceImportColumns.attendanceDate: 3,
          AttendanceImportColumns.checkIn: 4,
          AttendanceImportColumns.checkOut: 5,
        },
    rows: rows,
  );
}

const Map<String, int> testEmployeeColumns = {
  AttendanceImportColumns.employeeId: 0,
  AttendanceImportColumns.nationalId: 1,
  AttendanceImportColumns.employeeName: 2,
  AttendanceImportColumns.address: 3,
  AttendanceImportColumns.phoneNumber: 4,
  AttendanceImportColumns.birthDate: 5,
  AttendanceImportColumns.gender: 6,
  AttendanceImportColumns.nationality: 7,
  AttendanceImportColumns.departmentId: 8,
  AttendanceImportColumns.departmentName: 9,
  AttendanceImportColumns.contractDate: 10,
  AttendanceImportColumns.salary: 11,
  AttendanceImportColumns.attendanceDate: 12,
  AttendanceImportColumns.checkIn: 13,
  AttendanceImportColumns.checkOut: 14,
};

List<Object?> buildEmployeeRow({
  String? employeeId,
  String? nationalId,
  String? name,
  String? address,
  String? phone,
  Object? birthDate,
  String? gender,
  String? nationality,
  String? departmentId,
  String? departmentName,
  Object? contractDate,
  Object? salary,
  Object? attendanceDate = '2026-09-27',
  Object? checkIn = '08:00',
  Object? checkOut = '16:00',
}) {
  return [
    employeeId,
    nationalId,
    name,
    address,
    phone,
    birthDate,
    gender,
    nationality,
    departmentId,
    departmentName,
    contractDate,
    salary,
    attendanceDate,
    checkIn,
    checkOut,
  ];
}

AttendanceImportSheetRow buildRow(int rowNumber, List<Object?> values) {
  return AttendanceImportSheetRow(rowNumber: rowNumber, values: values);
}

class FakeImportRepository implements AttendanceImportRepository {
  FakeImportRepository({this.sheet, this.structuralError});

  final AttendanceImportSheet? sheet;
  final Object? structuralError;

  @override
  Future<AttendanceImportFile?> pickXlsxFile() async {
    return buildImportFile();
  }

  @override
  AttendanceImportSheet parseWorkbook(Uint8List bytes) {
    final error = structuralError;

    if (error != null) {
      throw error;
    }

    return sheet!;
  }
}

class FakeEmployeeRepository implements EmployeeRepository {
  FakeEmployeeRepository([List<EmployeeEntity>? employees])
    : employees = employees ?? [buildEmployee()];

  final List<EmployeeEntity> employees;

  final List<EmployeeEntity> added = [];

  int loadCount = 0;

  @override
  Future<List<EmployeeEntity>> getEmployees() async {
    loadCount++;

    return employees;
  }

  @override
  Future<EmployeeEntity> getEmployeeById(String id) async {
    for (final employee in employees) {
      if (employee.id == id) {
        return employee;
      }
    }

    throw StateError('Employee not found: $id');
  }

  @override
  Future<EmployeeEntity?> getEmployeeByNationalId(
    String nationalId, {
    String? excludingId,
  }) async {
    for (final employee in employees) {
      if (employee.id == excludingId) {
        continue;
      }

      if (employee.nationalId == nationalId) {
        return employee;
      }
    }

    return null;
  }

  @override
  Future<void> addEmployee(EmployeeEntity employee) async {
    added.add(employee);
    employees.add(employee);
  }

  @override
  Future<void> updateEmployee(EmployeeEntity employee) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteEmployee(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> linkEmployeeAccount(String id, String authUid) {
    throw UnimplementedError();
  }
}

class FakeAttendanceRepository implements AttendanceRepository {
  FakeAttendanceRepository([List<AttendanceEntity>? initialRecords])
    : records = [...?initialRecords];

  final List<AttendanceEntity> records;

  final List<String> addedIds = [];

  final List<String> updatedIds = [];

  int loadCount = 0;

  int byEmployeeAndDateCount = 0;

  @override
  Future<void> addAttendance(AttendanceEntity attendance) async {
    addedIds.add(attendance.id);
    records.add(attendance);
  }

  @override
  Future<void> updateAttendance(AttendanceEntity attendance) async {
    updatedIds.add(attendance.id);

    final index = records.indexWhere((record) => record.id == attendance.id);

    if (index == -1) {
      records.add(attendance);
      return;
    }

    records[index] = attendance;
  }

  @override
  Future<void> deleteAttendance(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<AttendanceEntity>> getAttendances() async {
    loadCount++;

    return records;
  }

  @override
  Future<List<AttendanceEntity>> getAttendancesByEmployeeId(
    String employeeId,
  ) async {
    return records.where((record) => record.employeeId == employeeId).toList();
  }

  @override
  Future<AttendanceEntity?> getAttendanceByEmployeeAndDate(
    String employeeId,
    DateTime date,
  ) async {
    byEmployeeAndDateCount++;

    for (final record in records) {
      if (record.employeeId != employeeId) {
        continue;
      }

      if (record.attendanceDate.year == date.year &&
          record.attendanceDate.month == date.month &&
          record.attendanceDate.day == date.day) {
        return record;
      }
    }

    return null;
  }
}

class FakeDepartmentRepository implements DepartmentRepository {
  FakeDepartmentRepository([List<DepartmentEntity>? departments])
    : departments =
          departments ??
          const [DepartmentEntity(id: 'dep-1', name: 'Engineering')];

  final List<DepartmentEntity> departments;

  int loadCount = 0;

  @override
  Future<List<DepartmentEntity>> getDepartments() async {
    loadCount++;

    return departments;
  }

  @override
  Future<DepartmentEntity> getDepartmentById(String id) async {
    return departments.firstWhere(
      (department) => department.id == id,
      orElse: () => DepartmentEntity(id: id, name: 'Unknown Department'),
    );
  }

  @override
  Future<DepartmentEntity?> getDepartmentByName(
    String name, {
    String? excludingId,
  }) async {
    final target = name.trim().toLowerCase();

    for (final department in departments) {
      if (excludingId != null && department.id == excludingId) {
        continue;
      }

      if (department.name.trim().toLowerCase() == target) {
        return department;
      }
    }

    return null;
  }

  @override
  Future<void> addDepartment(DepartmentEntity department) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateDepartment(DepartmentEntity department) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDepartment(String id) {
    throw UnimplementedError();
  }
}

class FakeGeneralSettingsRepository implements GeneralSettingsRepository {
  FakeGeneralSettingsRepository([GeneralSettingsEntity? settings])
    : settings = settings ?? GeneralSettingsEntity.defaults();

  GeneralSettingsEntity settings;

  int loadCount = 0;

  @override
  Future<GeneralSettingsEntity> getGeneralSettings() async {
    loadCount++;

    return settings;
  }

  @override
  Future<void> updateGeneralSettings(GeneralSettingsEntity settings) async {
    this.settings = settings;
  }
}

class FakeOfficialHolidayRepository implements OfficialHolidayRepository {
  FakeOfficialHolidayRepository([List<OfficialHolidayEntity>? holidays])
    : holidays = [...?holidays];

  final List<OfficialHolidayEntity> holidays;

  int loadCount = 0;

  @override
  Future<List<OfficialHolidayEntity>> getOfficialHolidays() async {
    loadCount++;

    return holidays;
  }

  @override
  Future<OfficialHolidayEntity?> getOfficialHolidayByNameAndDate(
    String name,
    DateTime date, {
    String? excludingId,
  }) async {
    return null;
  }

  @override
  Future<void> addOfficialHoliday(OfficialHolidayEntity holiday) async {
    holidays.add(holiday);
  }

  @override
  Future<void> updateOfficialHoliday(OfficialHolidayEntity holiday) async {}

  @override
  Future<void> deleteOfficialHoliday(String id) async {}
}
