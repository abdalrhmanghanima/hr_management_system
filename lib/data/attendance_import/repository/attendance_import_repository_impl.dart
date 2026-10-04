import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hr_management_system/core/logger.dart';
import 'package:hr_management_system/data/attendance_import/xlsx/xlsx_opc_relationship_normalizer.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_exception.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_file.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_sheet.dart';
import 'package:hr_management_system/domain/attendance_import/repository/attendance_import_repository.dart';

class AttendanceImportRepositoryImpl implements AttendanceImportRepository {
  AttendanceImportRepositoryImpl({
    this._normalizer = const XlsxOpcRelationshipNormalizer(),
  });

  static const String xlsxExtension = 'xlsx';

  static const int maxHeaderScanRows = 15;

  final XlsxOpcRelationshipNormalizer _normalizer;

  static const List<String> _fieldOrder = [
    AttendanceImportColumns.employeeId,
    AttendanceImportColumns.nationalId,
    AttendanceImportColumns.employeeName,
    AttendanceImportColumns.address,
    AttendanceImportColumns.phoneNumber,
    AttendanceImportColumns.birthDate,
    AttendanceImportColumns.gender,
    AttendanceImportColumns.nationality,
    AttendanceImportColumns.departmentId,
    AttendanceImportColumns.departmentName,
    AttendanceImportColumns.contractDate,
    AttendanceImportColumns.salary,
    AttendanceImportColumns.attendanceDate,
    AttendanceImportColumns.checkIn,
    AttendanceImportColumns.checkOut,
  ];

  static const Map<String, List<String>> _aliases = {
    AttendanceImportColumns.employeeId: [
      'employeeno',
      'employeenumber',
      'employeeid',
      'employeecode',
      'employeeidnumber',
      'empid',
      'code',
      'id',
    ],
    AttendanceImportColumns.nationalId: [
      'nationalidentificationnumber',
      'nationalidentification',
      'nationalnumber',
      'nationalid',
      'nationalidnumber',
    ],
    AttendanceImportColumns.employeeName: [
      'employeename',
      'fullname',
      'name',
      'employee',
    ],
    AttendanceImportColumns.address: [
      'address',
      'homeaddress',
      'employeeaddress',
      'residentialaddress',
    ],
    AttendanceImportColumns.phoneNumber: [
      'phonenumber',
      'phone',
      'mobilenumber',
      'mobile',
      'contactnumber',
      'cellphone',
      'cellphonenumber',
    ],
    AttendanceImportColumns.birthDate: ['dateofbirth', 'birthdate', 'dob'],
    AttendanceImportColumns.gender: ['gender', 'sex'],
    AttendanceImportColumns.nationality: ['nationality', 'nation'],
    AttendanceImportColumns.departmentId: [
      'departmentid',
      'departmentcode',
      'deptid',
      'deptcode',
    ],
    AttendanceImportColumns.departmentName: [
      'departmentname',
      'department',
      'deptname',
      'dept',
    ],
    AttendanceImportColumns.contractDate: [
      'contractdate',
      'joiningdate',
      'joindate',
      'hiredate',
      'startdate',
    ],
    AttendanceImportColumns.salary: [
      'monthlysalary',
      'basicsalary',
      'grosssalary',
      'salary',
      'salaryegp',
    ],
    AttendanceImportColumns.attendanceDate: [
      'attendancedate',
      'attendanceday',
      'date',
      'day',
    ],
    AttendanceImportColumns.checkIn: [
      'checkintime',
      'checkin',
      'intime',
      'timein',
      'clockin',
      'in',
    ],
    AttendanceImportColumns.checkOut: [
      'checkouttime',
      'checkout',
      'outtime',
      'timeout',
      'clockout',
      'out',
    ],
  };

  @override
  Future<AttendanceImportFile?> pickXlsxFile() async {
    PlatformFile? picked;

    try {
      picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: [xlsxExtension],
      );
    } catch (error) {
      log('AttendanceImport', 'file picker failed: $error');

      throw const AttendanceImportException(
        'attendance_import.picker_failed',
      );
    }

    if (picked == null) {
      return null;
    }

    final extension = picked.extension?.toLowerCase();

    if (extension != null && extension != xlsxExtension) {
      throw const AttendanceImportException('attendance_import.only_xlsx');
    }

    if (picked.name.toLowerCase().endsWith('.$xlsxExtension') == false) {
      throw const AttendanceImportException('attendance_import.only_xlsx');
    }

    Uint8List bytes;

    try {
      bytes = await picked.readAsBytes();
    } catch (error) {
      log(
        'AttendanceImport',
        'unable to read bytes for ${picked.name}: $error',
      );

      throw const AttendanceImportException(
        'attendance_import.read_failed',
      );
    }

    if (bytes.isEmpty) {
      throw const AttendanceImportException('attendance_import.file_empty');
    }

    log('AttendanceImport', 'picked ${picked.name} (${bytes.length} bytes)');

    return AttendanceImportFile(name: picked.name, bytes: bytes);
  }

  @override
  AttendanceImportSheet parseWorkbook(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw const AttendanceImportException('attendance_import.file_empty');
    }

    final Excel excel;

    try {
      excel = Excel.decodeBytes(_normalizer.normalize(bytes));
    } on UnsupportedError catch (error) {
      log('AttendanceImport', 'unsupported workbook: ${error.message}');

      throw const AttendanceImportException(
        'attendance_import.only_xlsx_excel',
      );
    } catch (error) {
      log(
        'AttendanceImport',
        'unable to decode workbook (${error.runtimeType}): $error',
      );

      throw const AttendanceImportException(
        'attendance_import.invalid_excel',
      );
    }

    if (excel.tables.isEmpty) {
      throw const AttendanceImportException(
        'attendance_import.no_worksheet',
      );
    }

    AttendanceImportSheet? bestPartialSheet;
    var bestPartialCount = 0;

    for (final table in excel.tables.values) {
      final sheet = _readSheet(table);

      if (sheet == null) {
        continue;
      }

      if (_hasRequiredColumns(sheet.columnIndexes)) {
        return sheet;
      }

      if (sheet.columnIndexes.length > bestPartialCount) {
        bestPartialCount = sheet.columnIndexes.length;
        bestPartialSheet = sheet;
      }
    }

    if (bestPartialSheet != null) {
      return bestPartialSheet;
    }

    throw const AttendanceImportException(
      'attendance_import.no_attendance_sheet',
    );
  }

  AttendanceImportSheet? _readSheet(Sheet table) {
    final rows = table.rows;

    if (rows.isEmpty) {
      return null;
    }

    final headerLimit = rows.length < maxHeaderScanRows
        ? rows.length
        : maxHeaderScanRows;

    AttendanceImportSheet? bestSheet;
    var bestCount = 0;

    for (var headerIndex = 0; headerIndex < headerLimit; headerIndex++) {
      final columns = _detectColumns(rows[headerIndex]);

      if (columns.isEmpty || columns.length <= bestCount) {
        continue;
      }

      bestCount = columns.length;
      bestSheet = AttendanceImportSheet(
        columnIndexes: columns,
        rows: _readRows(rows, headerIndex),
      );
    }

    return bestSheet;
  }

  List<AttendanceImportSheetRow> _readRows(
    List<List<Data?>> rows,
    int headerIndex,
  ) {
    final result = <AttendanceImportSheetRow>[];

    for (var index = headerIndex + 1; index < rows.length; index++) {
      final values = _valuesOf(rows[index]);

      if (_isBlank(values)) {
        continue;
      }

      result.add(
        AttendanceImportSheetRow(rowNumber: index + 1, values: values),
      );
    }

    return result;
  }

  Map<String, int> _detectColumns(List<Data?> row) {
    final headers = <int, String>{};

    for (var index = 0; index < row.length; index++) {
      final text = _textOf(row[index]);

      if (text == null || text.isEmpty) {
        continue;
      }

      headers[index] = _normalizeHeader(text);
    }

    final columns = <String, int>{};
    final claimed = <int>{};

    for (final field in _fieldOrder) {
      for (final alias in _aliases[field]!) {
        for (final entry in headers.entries) {
          if (claimed.contains(entry.key) || entry.value != alias) {
            continue;
          }

          columns[field] = entry.key;
          claimed.add(entry.key);
          break;
        }

        if (columns.containsKey(field)) {
          break;
        }
      }
    }

    return columns;
  }

  bool _hasRequiredColumns(Map<String, int> columns) {
    final hasEmployeeKey =
        columns.containsKey(AttendanceImportColumns.employeeId) ||
        columns.containsKey(AttendanceImportColumns.nationalId);

    final hasDate = columns.containsKey(AttendanceImportColumns.attendanceDate);

    final hasTime =
        columns.containsKey(AttendanceImportColumns.checkIn) ||
        columns.containsKey(AttendanceImportColumns.checkOut);

    return hasEmployeeKey && hasDate && hasTime;
  }

  String _normalizeHeader(String value) {
    return value.toLowerCase().trim().replaceAll(RegExp(r'[\s_\-]+'), '');
  }

  List<Object?> _valuesOf(List<Data?> row) {
    return row.map(_valueOf).toList();
  }

  bool _isBlank(List<Object?> values) {
    for (final value in values) {
      if (value == null) {
        continue;
      }

      if (value is String && value.trim().isEmpty) {
        continue;
      }

      return false;
    }

    return true;
  }

  Object? _valueOf(Data? cell) {
    final value = cell?.value;

    if (value is TextCellValue) {
      return value.value.text;
    }

    if (value is IntCellValue) {
      return value.value;
    }

    if (value is DoubleCellValue) {
      return value.value;
    }

    if (value is BoolCellValue) {
      return value.value;
    }

    if (value is DateCellValue) {
      return value.asDateTimeLocal();
    }

    if (value is DateTimeCellValue) {
      return value.asDateTimeLocal();
    }

    if (value is TimeCellValue) {
      return value.toString();
    }

    return null;
  }

  String? _textOf(Data? cell) {
    final value = _valueOf(cell);

    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    return value.toString();
  }
}
