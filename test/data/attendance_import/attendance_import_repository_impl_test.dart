import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/data/attendance_import/repository/attendance_import_repository_impl.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_exception.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_sheet.dart';
import 'package:hr_management_system/domain/attendance_import/parser/attendance_import_value_parser.dart';
import 'package:hr_management_system/domain/attendance_import/use_case/import_attendance_use_case.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';

import '../../helpers/attendance_test_data.dart';

void main() {
  final repository = AttendanceImportRepositoryImpl();

  Future<FakeAttendanceRepository> importBytes(
    Uint8List bytes, {
    List<EmployeeEntity> employees = const [],
  }) async {
    final attendanceRepository = FakeAttendanceRepository();

    await ImportAttendanceUseCase(
      attendanceRepository: attendanceRepository,
      employeeRepository: FakeEmployeeRepository(
        employees.isEmpty ? [buildEmployee()] : employees,
      ),
      departmentRepository: FakeDepartmentRepository(),
      importRepository: repository,
    ).call(buildImportFile(bytes: bytes));

    return attendanceRepository;
  }

  Future<String> importExpectingError(
    Uint8List bytes,
    FakeAttendanceRepository attendanceRepository,
  ) async {
    try {
      await ImportAttendanceUseCase(
        attendanceRepository: attendanceRepository,
        employeeRepository: FakeEmployeeRepository(),
        departmentRepository: FakeDepartmentRepository(),
        importRepository: repository,
      ).call(buildImportFile(bytes: bytes));

      return '';
    } on AttendanceImportException catch (error) {
      return error.message;
    }
  }

  group('excel date and time cells', () {
    test('parses real excel date and date-time cells', () async {
      final bytes = buildXlsxBytes(
        headers: const [
          'Employee ID',
          'Attendance Date',
          'Check In',
          'Check Out',
        ],
        rows: [
          [
            testEmployeeId,
            DateTime(2026, 9, 27),
            DateTime(2026, 9, 27, 8),
            DateTime(2026, 9, 27, 16),
          ],
        ],
      );

      final sheet = repository.parseWorkbook(bytes);

      expect(sheet.columnIndexes[AttendanceImportColumns.employeeId], 0);
      expect(sheet.columnIndexes[AttendanceImportColumns.attendanceDate], 1);
      expect(sheet.rows, hasLength(1));
      expect(
        sheet.rows.first.valueAt(
          sheet.indexOf(AttendanceImportColumns.attendanceDate),
        ),
        DateTime(2026, 9, 27),
      );
      expect(
        sheet.rows.first.valueAt(
          sheet.indexOf(AttendanceImportColumns.checkIn),
        ),
        DateTime(2026, 9, 27, 8),
      );

      final attendanceRepository = await importBytes(bytes);

      final record = attendanceRepository.records.single;

      expect(
        record.id,
        AttendanceEntity.documentIdFor(testEmployeeId, testAttendanceDate),
      );
      expect(record.attendanceDate, DateTime(2026, 9, 27));
      expect(record.checkInTime, DateTime(2026, 9, 27, 8));
      expect(record.checkOutTime, DateTime(2026, 9, 27, 16));
    });

    test('parses excel time cells and serial date values', () async {
      final bytes = buildXlsxBytes(
        headers: const [
          'Employee ID',
          'Attendance Date',
          'Check In',
          'Check Out',
        ],
        rows: [
          [
            testEmployeeId,
            46292.0,
            const TimeCellValue(hour: 8, minute: 30),
            '16:45',
          ],
        ],
      );

      final sheet = repository.parseWorkbook(bytes);

      expect(
        sheet.rows.first.valueAt(
          sheet.indexOf(AttendanceImportColumns.checkIn),
        ),
        '08:30:00',
      );

      final attendanceRepository = await importBytes(bytes);

      final record = attendanceRepository.records.single;

      expect(record.attendanceDate, DateTime(2026, 9, 27));
      expect(record.checkInTime, DateTime(2026, 9, 27, 8, 30));
      expect(record.checkOutTime, DateTime(2026, 9, 27, 16, 45));
    });

    test('reads a header row that is not the first row', () async {
      final bytes = buildXlsxBytes(
        headerRowIndex: 2,
        headers: const [
          'Employee ID',
          'Attendance Date',
          'Check In',
          'Check Out',
        ],
        rows: [
          [testEmployeeId, '2026-09-27', '08:00', '16:00'],
        ],
      );

      final sheet = repository.parseWorkbook(bytes);

      expect(sheet.rows, hasLength(1));
      expect(sheet.rows.first.rowNumber, 4);
    });
  });

  group('opc relationship targets', () {
    test(
      'decodes a workbook that uses absolute relationship targets',
      () async {
        final bytes = buildXlsxBytesWithAbsoluteRelationshipTargets(
          sheetName: 'Attendance',
          headers: const [
            'Employee ID',
            'National ID',
            'Employee Name',
            'Address',
            'Phone',
            'Birth Date',
            'Gender',
            'Nationality',
            'Contract Date',
            'Salary',
            'Department Name',
            'Attendance Date',
            'Check In',
            'Check Out',
          ],
          rows: [
            [
              'EMP999',
              '29801011234567',
              'Test Person',
              'Cairo, Egypt',
              '01012345678',
              '2000-01-15',
              'Male',
              'Egyptian',
              '2026-01-01',
              5000,
              'Finance',
              '2026-09-29',
              '08:30',
              '16:30',
            ],
          ],
        );

        expect(
          () => Excel.decodeBytes(bytes),
          throwsA(isA<Error>()),
          reason:
              'the raw workbook must stay undecodable for this test to matter',
        );

        final sheet = repository.parseWorkbook(bytes);

        expect(sheet.columnIndexes, {
          AttendanceImportColumns.employeeId: 0,
          AttendanceImportColumns.nationalId: 1,
          AttendanceImportColumns.employeeName: 2,
          AttendanceImportColumns.address: 3,
          AttendanceImportColumns.phoneNumber: 4,
          AttendanceImportColumns.birthDate: 5,
          AttendanceImportColumns.gender: 6,
          AttendanceImportColumns.nationality: 7,
          AttendanceImportColumns.contractDate: 8,
          AttendanceImportColumns.salary: 9,
          AttendanceImportColumns.departmentName: 10,
          AttendanceImportColumns.attendanceDate: 11,
          AttendanceImportColumns.checkIn: 12,
          AttendanceImportColumns.checkOut: 13,
        });
        expect(sheet.rows, hasLength(1));
        expect(
          sheet.rows.first.valueAt(
            sheet.indexOf(AttendanceImportColumns.departmentName),
          ),
          'Finance',
        );
        expect(
          sheet.rows.first.valueAt(
            sheet.indexOf(AttendanceImportColumns.salary),
          ),
          5000,
        );
      },
    );

    test('still decodes workbooks that already use relative targets', () {
      final bytes = buildXlsxBytes(
        rows: [
          [testEmployeeId, '2026-09-27', '08:00', '16:00'],
        ],
      );

      final sheet = repository.parseWorkbook(bytes);

      expect(sheet.rows, hasLength(1));
      expect(sheet.columnIndexes[AttendanceImportColumns.employeeId], 0);
    });
  });

  group('invalid workbook structure', () {
    test('fails before any write when required columns are missing', () async {
      final attendanceRepository = FakeAttendanceRepository();

      final missingEmployeeKey = buildXlsxBytes(
        headers: const [
          'Employee Name',
          'Attendance Date',
          'Check In',
          'Check Out',
        ],
        rows: [
          ['Ahmed Mohamed', '2026-09-27', '08:00', '16:00'],
        ],
      );

      final missingDate = buildXlsxBytes(
        headers: const ['Employee ID', 'Check In', 'Check Out'],
        rows: [
          [testEmployeeId, '08:00', '16:00'],
        ],
      );

      final missingTimes = buildXlsxBytes(
        headers: const ['Employee ID', 'Attendance Date'],
        rows: [
          [testEmployeeId, '2026-09-27'],
        ],
      );

      expect(
        await importExpectingError(missingEmployeeKey, attendanceRepository),
        contains('Employee ID or National ID'),
      );
      expect(
        await importExpectingError(missingDate, attendanceRepository),
        contains('Attendance Date'),
      );
      expect(
        await importExpectingError(missingTimes, attendanceRepository),
        contains('Check In or Check Out'),
      );
      expect(attendanceRepository.records, isEmpty);
      expect(attendanceRepository.addedIds, isEmpty);
    });

    test('fails when the worksheet has no records', () async {
      final attendanceRepository = FakeAttendanceRepository();

      final emptyWorksheet = buildXlsxBytes(rows: const []);

      final headerOnly = buildXlsxBytes(
        headers: const [
          'Employee ID',
          'Attendance Date',
          'Check In',
          'Check Out',
        ],
        rows: const [],
      );

      expect(
        await importExpectingError(emptyWorksheet, attendanceRepository),
        isNotEmpty,
      );
      expect(
        await importExpectingError(headerOnly, attendanceRepository),
        contains('does not contain any attendance records'),
      );
      expect(attendanceRepository.records, isEmpty);
      expect(attendanceRepository.addedIds, isEmpty);
    });

    test('fails when the worksheet is completely empty', () async {
      final attendanceRepository = FakeAttendanceRepository();

      final emptyWorkbook = buildXlsxBytes(headers: const [], rows: const []);

      expect(
        await importExpectingError(emptyWorkbook, attendanceRepository),
        'No worksheet with attendance columns was found',
      );
      expect(attendanceRepository.records, isEmpty);
      expect(attendanceRepository.addedIds, isEmpty);
    });

    test('fails when the file is not a readable workbook', () {
      expect(
        () => repository.parseWorkbook(Uint8List.fromList([1, 2, 3, 4])),
        throwsA(
          isA<AttendanceImportException>().having(
            (error) => error.message,
            'message',
            contains('Only .xlsx'),
          ),
        ),
      );
    });

    test('reports empty bytes before attempting to decode', () {
      expect(
        () => repository.parseWorkbook(Uint8List(0)),
        throwsA(
          isA<AttendanceImportException>().having(
            (error) => error.message,
            'message',
            'The selected file is empty',
          ),
        ),
      );
    });

    test('fails when the archive is not a workbook package', () {
      final archive = Archive()
        ..addFile(ArchiveFile('readme.txt', 0, utf8.encode('not a workbook')));

      expect(
        () => repository.parseWorkbook(
          Uint8List.fromList(ZipEncoder().encode(archive)!),
        ),
        throwsA(
          isA<AttendanceImportException>().having(
            (error) => error.message,
            'message',
            contains('Only .xlsx'),
          ),
        ),
      );
    });

    test('reports a workbook whose worksheet is missing', () {
      final valid = buildXlsxBytes(
        rows: [
          [testEmployeeId, '2026-09-27', '08:00', '16:00'],
        ],
      );

      final archive = ZipDecoder().decodeBytes(valid);
      final worksheet = archive.findFile('xl/worksheets/sheet1.xml');

      expect(worksheet, isNotNull);

      archive.removeFile(worksheet!);

      expect(
        () => repository.parseWorkbook(
          Uint8List.fromList(ZipEncoder().encode(archive)!),
        ),
        throwsA(
          isA<AttendanceImportException>().having(
            (error) => error.message,
            'message',
            contains('not a valid Excel'),
          ),
        ),
      );
    });
  });

  group('value parser', () {
    test('parses supported date and time text formats', () {
      expect(
        AttendanceImportValueParser.parseDate('2026-09-27'),
        DateTime(2026, 9, 27),
      );
      expect(
        AttendanceImportValueParser.parseDate('27/09/2026'),
        DateTime(2026, 9, 27),
      );
      expect(
        AttendanceImportValueParser.parseDate('09/27/2026'),
        DateTime(2026, 9, 27),
      );
      expect(AttendanceImportValueParser.parseDate('27-13-2026'), isNull);
      expect(AttendanceImportValueParser.parseDate(''), isNull);

      final date = DateTime(2026, 9, 27);

      expect(
        AttendanceImportValueParser.parseTime('8:05', date: date),
        DateTime(2026, 9, 27, 8, 5),
      );
      expect(
        AttendanceImportValueParser.parseTime('08:05:30 PM', date: date),
        DateTime(2026, 9, 27, 20, 5, 30),
      );
      expect(
        AttendanceImportValueParser.parseTime('99:99', date: date),
        isNull,
      );
      expect(
        AttendanceImportValueParser.parseTime('midnight', date: date),
        isNull,
      );
    });
  });
}
