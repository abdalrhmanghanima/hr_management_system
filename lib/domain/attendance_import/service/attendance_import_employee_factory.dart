import 'package:hr_management_system/core/utils/employee_id_generator.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_row_failure.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_sheet.dart';
import 'package:hr_management_system/domain/attendance_import/parser/attendance_import_value_parser.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/employee/validation/employee_validator.dart';

class AttendanceImportEmployeeFactory {
  const AttendanceImportEmployeeFactory();

  static const Map<String, String> _genderAliases = {
    'male': 'Male',
    'm': 'Male',
    'ذكر': 'Male',
    'female': 'Female',
    'f': 'Female',
    'feme': 'Female',
    'انثى': 'Female',
    'انثه': 'Female',
  };

  EmployeeEntity build({
    required AttendanceImportSheetRow row,
    required AttendanceImportSheet sheet,
    required String? employeeId,
    required String departmentId,
  }) {
    final nationalId = _textOf(row, sheet, AttendanceImportColumns.nationalId);
    final fullName = _textOf(row, sheet, AttendanceImportColumns.employeeName);
    final address = _textOf(row, sheet, AttendanceImportColumns.address);
    final phoneNumber = _textOf(
      row,
      sheet,
      AttendanceImportColumns.phoneNumber,
    );
    final nationality = _textOf(
      row,
      sheet,
      AttendanceImportColumns.nationality,
    );
    final birthDate = AttendanceImportValueParser.parseDate(
      row.valueAt(sheet.indexOf(AttendanceImportColumns.birthDate)),
    );
    final contractDate = AttendanceImportValueParser.parseDate(
      row.valueAt(sheet.indexOf(AttendanceImportColumns.contractDate)),
    );
    final gender = _genderOf(row, sheet);
    final salary = _salaryOf(row, sheet);

    _reject(EmployeeValidator.fullName(fullName));
    _reject(EmployeeValidator.address(address));
    _reject(EmployeeValidator.phoneNumber(phoneNumber));
    _reject(EmployeeValidator.birthDate(birthDate));
    _reject(EmployeeValidator.gender(gender));
    _reject(EmployeeValidator.nationalId(nationalId));
    _reject(EmployeeValidator.nationality(nationality));
    _reject(EmployeeValidator.department(departmentId));
    _reject(EmployeeValidator.contractDate(contractDate));
    _reject(EmployeeValidator.salary(salary));

    return EmployeeEntity(
      id: employeeId == null || employeeId.trim().isEmpty
          ? EmployeeIdGenerator.generate()
          : employeeId.trim(),
      fullName: fullName!.trim(),
      address: address!.trim(),
      phoneNumber: phoneNumber!.trim(),
      birthDate: birthDate!,
      nationalId: nationalId!.trim(),
      nationality: nationality!.trim(),
      gender: gender!.trim(),
      departmentId: departmentId.trim(),
      contractDate: contractDate!,
      salary: salary!,
    );
  }

  String? _genderOf(AttendanceImportSheetRow row, AttendanceImportSheet sheet) {
    final value = _textOf(row, sheet, AttendanceImportColumns.gender);

    if (value == null) {
      return null;
    }

    final gender = _genderAliases[value.trim().toLowerCase()];

    if (gender == null) {
      throw const AttendanceImportRowFailure('Gender must be Male or Female');
    }

    return gender;
  }

  double? _salaryOf(AttendanceImportSheetRow row, AttendanceImportSheet sheet) {
    final value = row.valueAt(sheet.indexOf(AttendanceImportColumns.salary));

    if (AttendanceImportValueParser.isBlank(value)) {
      return null;
    }

    final salary = double.tryParse(
      AttendanceImportValueParser.asText(value).replaceAll(',', ''),
    );

    if (salary == null) {
      throw const AttendanceImportRowFailure('Enter a valid salary');
    }

    return salary;
  }

  String? _textOf(
    AttendanceImportSheetRow row,
    AttendanceImportSheet sheet,
    String column,
  ) {
    return AttendanceImportValueParser.readText(
      row.valueAt(sheet.indexOf(column)),
    );
  }

  void _reject(String? error) {
    if (error != null) {
      throw AttendanceImportRowFailure(error);
    }
  }
}
