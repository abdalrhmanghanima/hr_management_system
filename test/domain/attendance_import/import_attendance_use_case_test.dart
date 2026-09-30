import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_sheet.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_summary.dart';
import 'package:hr_management_system/domain/attendance_import/use_case/import_attendance_use_case.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';

import '../../helpers/attendance_test_data.dart';

void main() {
  late FakeAttendanceRepository lastAttendanceRepository;
  late FakeEmployeeRepository lastEmployeeRepository;

  setUp(() {
    lastAttendanceRepository = FakeAttendanceRepository();
  });

  Future<AttendanceImportSummary> importRows({
    required List<List<Object?>> rows,
    List<EmployeeEntity> employees = const [],
    List<AttendanceEntity> existing = const [],
    Map<String, int>? columnIndexes,
  }) async {
    final attendanceRepository = FakeAttendanceRepository(existing);

    final employeeRepository = FakeEmployeeRepository(
      employees.isEmpty ? [buildEmployee()] : employees,
    );

    final sheetRows = <AttendanceImportSheetRow>[];

    for (var index = 0; index < rows.length; index++) {
      sheetRows.add(buildRow(index + 2, rows[index]));
    }

    final useCase = ImportAttendanceUseCase(
      attendanceRepository: attendanceRepository,
      employeeRepository: employeeRepository,
      departmentRepository: FakeDepartmentRepository(),
      importRepository: FakeImportRepository(
        sheet: buildSheet(columnIndexes: columnIndexes, rows: sheetRows),
      ),
    );

    final summary = await useCase.call(buildImportFile(bytes: Uint8List(0)));

    lastAttendanceRepository = attendanceRepository;
    lastEmployeeRepository = employeeRepository;

    return summary;
  }

  group('attendance import add', () {
    test(
      'creates a record with the deterministic id for a new employee date',
      () async {
        final summary = await importRows(
          rows: [
            [
              testEmployeeId,
              testNationalId,
              'Ahmed Mohamed',
              '2026-09-27',
              '08:00',
              '16:00',
            ],
          ],
        );

        final records = lastAttendanceRepository.records;

        expect(summary.added, 1);
        expect(summary.updated, 0);
        expect(summary.failed, 0);
        expect(records, hasLength(1));

        final record = records.first;

        expect(
          record.id,
          AttendanceEntity.documentIdFor(testEmployeeId, testAttendanceDate),
        );
        expect(record.employeeId, testEmployeeId);
        expect(record.attendanceDate, testAttendanceDate);
        expect(record.status, AttendanceEntity.presentStatus);
        expect(record.checkInTime, DateTime(2026, 9, 27, 8));
        expect(record.checkOutTime, DateTime(2026, 9, 27, 16));
      },
    );
  });

  group('attendance import update', () {
    test('updates the existing record without creating a second one', () async {
      final summary = await importRows(
        existing: [
          buildAttendance(
            id: AttendanceEntity.documentIdFor(
              testEmployeeId,
              testAttendanceDate,
            ),
            checkIn: DateTime(2026, 9, 27, 9),
          ),
        ],
        rows: [
          [
            testEmployeeId,
            testNationalId,
            'Ahmed Mohamed',
            '2026-09-27',
            '08:00',
            '16:00',
          ],
        ],
      );

      final records = lastAttendanceRepository.records;

      expect(summary.added, 0);
      expect(summary.updated, 1);
      expect(records, hasLength(1));
      expect(records.first.checkInTime, DateTime(2026, 9, 27, 8));
      expect(records.first.checkOutTime, DateTime(2026, 9, 27, 16));
    });

    test('updates a legacy record and keeps its existing id', () async {
      final summary = await importRows(
        existing: [
          buildAttendance(
            id: '3f0c1c74-0a1e-4f1d-9f7f-2c2f9a1b8d55',
            checkIn: DateTime(2026, 9, 27, 9),
          ),
        ],
        rows: [
          [
            testEmployeeId,
            testNationalId,
            'Ahmed Mohamed',
            '2026-09-27',
            '08:00',
            '16:00',
          ],
        ],
      );

      final records = lastAttendanceRepository.records;

      expect(summary.updated, 1);
      expect(summary.added, 0);
      expect(records, hasLength(1));
      expect(records.first.id, '3f0c1c74-0a1e-4f1d-9f7f-2c2f9a1b8d55');
      expect(lastAttendanceRepository.updatedIds, [
        '3f0c1c74-0a1e-4f1d-9f7f-2c2f9a1b8d55',
      ]);
    });

    test(
      'keeps the existing check-out when the imported check-out is empty',
      () async {
        final summary = await importRows(
          existing: [
            buildAttendance(
              id: 'legacy-id',
              checkIn: DateTime(2026, 9, 27, 9),
              checkOut: DateTime(2026, 9, 27, 17),
            ),
          ],
          rows: [
            [
              testEmployeeId,
              testNationalId,
              'Ahmed Mohamed',
              '2026-09-27',
              '08:00',
              null,
            ],
          ],
        );

        final record = lastAttendanceRepository.records.first;

        expect(summary.updated, 1);
        expect(record.checkInTime, DateTime(2026, 9, 27, 8));
        expect(record.checkOutTime, DateTime(2026, 9, 27, 17));
      },
    );
  });

  group('attendance import employee matching', () {
    test('resolves by employee id and falls back to national id', () async {
      final summary = await importRows(
        employees: [
          buildEmployee(),
          buildEmployee(
            id: 'EMP002',
            nationalId: '29801019999999',
            fullName: 'Sara Ali',
          ),
        ],
        rows: [
          [
            testEmployeeId,
            null,
            'Ahmed Mohamed',
            '2026-09-27',
            '08:00',
            '16:00',
          ],
          [
            'UNKNOWN',
            testNationalId,
            'Ahmed Mohamed',
            '2026-09-28',
            '08:00',
            '16:00',
          ],
          [null, '29801019999999', 'Sara Ali', '2026-09-27', '08:00', '16:00'],
        ],
      );

      final records = lastAttendanceRepository.records;

      expect(summary.added, 3);
      expect(summary.failed, 0);
      expect(
        records.where((record) => record.employeeId == testEmployeeId),
        hasLength(2),
      );
      expect(
        records.where((record) => record.employeeId == 'EMP002'),
        hasLength(1),
      );
    });

    test(
      'fails the row when employee id and national id belong to different employees',
      () async {
        final summary = await importRows(
          employees: [
            buildEmployee(),
            buildEmployee(
              id: 'EMP002',
              nationalId: '29801019999999',
              fullName: 'Sara Ali',
            ),
          ],
          rows: [
            [
              testEmployeeId,
              '29801019999999',
              'Ahmed Mohamed',
              '2026-09-27',
              '08:00',
              '16:00',
            ],
          ],
        );

        expect(summary.failed, 1);
        expect(summary.added, 0);
        expect(summary.issues, hasLength(1));
        expect(summary.issues.first.rowNumber, 2);
        expect(summary.issues.first.reason, contains('different employees'));
        expect(lastAttendanceRepository.records, isEmpty);
      },
    );

    test(
      'fails the row when no employee matches and creation is invalid',
      () async {
        final summary = await importRows(
          rows: [
            [
              'UNKNOWN',
              '00000000000000',
              'Nobody',
              '2026-09-27',
              '08:00',
              '16:00',
            ],
          ],
        );

        expect(summary.failed, 1);
        expect(summary.employeesCreated, 0);
        expect(lastEmployeeRepository.added, isEmpty);
        expect(lastAttendanceRepository.records, isEmpty);
      },
    );
  });

  group('attendance import employee auto creation', () {
    test(
      'creates the employee then the attendance for a new employee',
      () async {
        final summary = await importRows(
          columnIndexes: testEmployeeColumns,
          rows: [
            buildEmployeeRow(
              employeeId: 'EMP999',
              nationalId: '29801015555555',
              name: 'Sara Ali',
              address: 'Cairo',
              phone: '01012345678',
              birthDate: '1990-05-04',
              gender: 'Female',
              nationality: 'Egyptian',
              departmentId: 'dep-1',
              contractDate: '2024-01-01',
              salary: 15000,
            ),
          ],
        );

        final created = lastEmployeeRepository.added.single;

        expect(summary.employeesCreated, 1);
        expect(summary.existingEmployeesUsed, 0);
        expect(summary.added, 1);
        expect(summary.failed, 0);
        expect(created.id, 'EMP999');
        expect(created.fullName, 'Sara Ali');
        expect(created.nationalId, '29801015555555');
        expect(created.departmentId, 'dep-1');
        expect(created.salary, 15000);
        expect(created.gender, 'Female');

        final record = lastAttendanceRepository.records.single;

        expect(record.employeeId, 'EMP999');
        expect(
          record.id,
          AttendanceEntity.documentIdFor('EMP999', testAttendanceDate),
        );
      },
    );

    test(
      'resolves a new employee by department name and reuses them',
      () async {
        final summary = await importRows(
          columnIndexes: testEmployeeColumns,
          rows: [
            buildEmployeeRow(
              employeeId: 'EMP500',
              nationalId: '29801015555555',
              name: 'Sara Ali',
              address: 'Cairo',
              phone: '01012345678',
              birthDate: '1990-05-04',
              gender: 'female',
              nationality: 'Egyptian',
              departmentName: 'engineering',
              contractDate: '2024-01-01',
              salary: '12,000',
            ),
            buildEmployeeRow(
              employeeId: null,
              nationalId: '29801015555555',
              attendanceDate: '2026-09-28',
            ),
          ],
        );

        expect(summary.employeesCreated, 1);
        expect(summary.existingEmployeesUsed, 1);
        expect(summary.added, 2);
        expect(summary.failed, 0);
        expect(lastEmployeeRepository.added, hasLength(1));
        expect(lastEmployeeRepository.added.single.departmentId, 'dep-1');
        expect(lastEmployeeRepository.added.single.salary, 12000);
      },
    );

    test('fails a new employee without a resolvable department', () async {
      final summary = await importRows(
        columnIndexes: testEmployeeColumns,
        rows: [
          buildEmployeeRow(
            employeeId: 'EMP999',
            nationalId: '29801015555555',
            name: 'Sara Ali',
            address: 'Cairo',
            phone: '01012345678',
            birthDate: '1990-05-04',
            gender: 'Female',
            nationality: 'Egyptian',
            contractDate: '2024-01-01',
            salary: 15000,
          ),
        ],
      );

      expect(summary.failed, 1);
      expect(summary.employeesCreated, 0);
      expect(summary.issues.first.reason, 'Department is required');
      expect(lastEmployeeRepository.added, isEmpty);
      expect(lastAttendanceRepository.records, isEmpty);
    });

    test('fails a new employee when a required field is missing', () async {
      final summary = await importRows(
        columnIndexes: testEmployeeColumns,
        rows: [
          buildEmployeeRow(
            employeeId: 'EMP999',
            nationalId: '29801015555555',
            name: 'Sara Ali',
            address: 'Cairo',
            phone: '01012345678',
            birthDate: '1990-05-04',
            gender: 'Female',
            departmentId: 'dep-1',
            contractDate: '2024-01-01',
            salary: 15000,
          ),
        ],
      );

      expect(summary.failed, 1);
      expect(
        summary.issues.first.reason,
        'validation.employee.nationality_required',
      );
      expect(summary.issues.first.rowNumber, 2);
      expect(lastEmployeeRepository.added, isEmpty);
      expect(lastAttendanceRepository.records, isEmpty);
    });

    test('fails a new employee when the national id is invalid', () async {
      final summary = await importRows(
        columnIndexes: testEmployeeColumns,
        rows: [
          buildEmployeeRow(
            employeeId: 'EMP999',
            nationalId: '123',
            name: 'Sara Ali',
            address: 'Cairo',
            phone: '01012345678',
            birthDate: '1990-05-04',
            gender: 'Female',
            nationality: 'Egyptian',
            departmentId: 'dep-1',
            contractDate: '2024-01-01',
            salary: 15000,
          ),
        ],
      );

      expect(summary.failed, 1);
      expect(
        summary.issues.first.reason,
        'validation.employee.national_id_invalid',
      );
      expect(lastEmployeeRepository.added, isEmpty);
    });

    test(
      'does not create an employee for a structurally invalid row',
      () async {
        final summary = await importRows(
          columnIndexes: testEmployeeColumns,
          rows: [
            buildEmployeeRow(
              employeeId: 'EMP999',
              nationalId: '29801015555555',
              name: 'Sara Ali',
              address: 'Cairo',
              phone: '01012345678',
              birthDate: '1990-05-04',
              gender: 'Female',
              nationality: 'Egyptian',
              departmentId: 'dep-1',
              contractDate: '2024-01-01',
              salary: 15000,
              attendanceDate: 'not-a-date',
            ),
          ],
        );

        expect(summary.failed, 1);
        expect(summary.issues.first.reason, 'Invalid attendance date');
        expect(lastEmployeeRepository.added, isEmpty);
        expect(lastAttendanceRepository.records, isEmpty);
      },
    );

    test(
      'generates an employee id when the row has only a national id',
      () async {
        final summary = await importRows(
          columnIndexes: testEmployeeColumns,
          rows: [
            buildEmployeeRow(
              nationalId: '29801015555555',
              name: 'Sara Ali',
              address: 'Cairo',
              phone: '01012345678',
              birthDate: '1990-05-04',
              gender: 'Male',
              nationality: 'Egyptian',
              departmentId: 'dep-1',
              contractDate: '2024-01-01',
              salary: 15000,
            ),
          ],
        );

        final created = lastEmployeeRepository.added.single;

        expect(summary.employeesCreated, 1);
        expect(summary.failed, 0);
        expect(created.id, isNotEmpty);
        expect(lastAttendanceRepository.records.single.employeeId, created.id);
      },
    );

    test('keeps the existing employee profile untouched', () async {
      await importRows(
        columnIndexes: testEmployeeColumns,
        employees: [buildEmployee()],
        rows: [
          buildEmployeeRow(
            employeeId: testEmployeeId,
            name: 'Changed Name',
            address: 'Changed Address',
            phone: '01099999999',
            birthDate: '1991-01-01',
            gender: 'Female',
            nationality: 'Other',
            departmentId: 'dep-1',
            contractDate: '2025-01-01',
            salary: 1,
          ),
        ],
      );

      expect(lastEmployeeRepository.added, isEmpty);

      final employee = lastEmployeeRepository.employees.first;

      expect(employee.fullName, 'Ahmed Mohamed');
      expect(employee.salary, 15000);
      expect(employee.gender, 'Male');
    });
  });

  group('attendance import duplicate protection', () {
    test(
      'imports two rows for the same employee and date as a single record',
      () async {
        final summary = await importRows(
          rows: [
            [
              testEmployeeId,
              testNationalId,
              'Ahmed Mohamed',
              '2026-09-27',
              '08:00',
              '16:00',
            ],
            [
              testEmployeeId,
              testNationalId,
              'Ahmed Mohamed',
              '2026-09-27',
              '09:00',
              '17:00',
            ],
          ],
        );

        final records = lastAttendanceRepository.records;

        expect(summary.totalRows, 2);
        expect(summary.added, 1);
        expect(summary.updated, 1);
        expect(summary.failed, 0);
        expect(records, hasLength(1));
        expect(
          records.first.id,
          AttendanceEntity.documentIdFor(testEmployeeId, testAttendanceDate),
        );
        expect(records.first.checkInTime, DateTime(2026, 9, 27, 9));
        expect(records.first.checkOutTime, DateTime(2026, 9, 27, 17));
      },
    );
  });

  group('attendance import check-in and check-out rules', () {
    test(
      'fails missing times, check-out without check-in, and keeps a null check-out',
      () async {
        final summary = await importRows(
          employees: [
            buildEmployee(),
            buildEmployee(
              id: 'EMP002',
              nationalId: '29801019999999',
              fullName: 'Sara Ali',
            ),
            buildEmployee(
              id: 'EMP003',
              nationalId: '29801018888888',
              fullName: 'Mona Ali',
            ),
          ],
          rows: [
            [testEmployeeId, null, null, '2026-09-27', null, null],
            ['EMP002', null, null, '2026-09-27', null, '16:00'],
            ['EMP003', null, null, '2026-09-27', '08:00', null],
          ],
        );

        final records = lastAttendanceRepository.records;

        expect(summary.added, 1);
        expect(summary.failed, 2);
        expect(summary.issues.map((issue) => issue.rowNumber), [2, 3]);
        expect(summary.issues.first.reason, contains('both missing'));
        expect(summary.issues.last.reason, 'Check-out without check-in');
        expect(records, hasLength(1));
        expect(records.first.checkInTime, DateTime(2026, 9, 27, 8));
        expect(records.first.checkOutTime, isNull);
      },
    );
  });

  group('attendance import invalid values', () {
    test(
      'reports invalid date and time rows while valid rows are imported',
      () async {
        final summary = await importRows(
          employees: [
            buildEmployee(),
            buildEmployee(
              id: 'EMP002',
              nationalId: '29801019999999',
              fullName: 'Sara Ali',
            ),
            buildEmployee(
              id: 'EMP003',
              nationalId: '29801018888888',
              fullName: 'Mona Ali',
            ),
          ],
          rows: [
            [testEmployeeId, null, null, '27-13-2026', '08:00', '16:00'],
            ['EMP002', null, null, '2026-09-27', '25:99', '16:00'],
            ['EMP003', null, null, '2026-09-27', '08:00', 'not-a-time'],
            [testEmployeeId, null, null, '2026-09-28', '08:00', '16:00'],
          ],
        );

        expect(summary.totalRows, 4);
        expect(summary.added, 1);
        expect(summary.failed, 3);
        expect(summary.issues.map((issue) => issue.rowNumber), [2, 3, 4]);
        expect(summary.issues[0].reason, 'Invalid attendance date');
        expect(summary.issues[1].reason, 'Invalid check-in time');
        expect(summary.issues[2].reason, 'Invalid check-out time');
        expect(lastAttendanceRepository.records, hasLength(1));
        expect(
          lastAttendanceRepository.records.first.attendanceDate,
          DateTime(2026, 9, 28),
        );
      },
    );
  });

  group('attendance import mixed rows', () {
    test(
      'imports valid rows, reports invalid rows, and counts skipped rows',
      () async {
        final summary = await importRows(
          employees: [
            buildEmployee(),
            buildEmployee(
              id: 'EMP002',
              nationalId: '29801019999999',
              fullName: 'Sara Ali',
            ),
          ],
          rows: [
            [testEmployeeId, null, null, '2026-09-27', '08:00', '16:00'],
            [null, '29801019999999', null, '2026-09-27', '09:00', '17:00'],
            ['UNKNOWN', null, null, '2026-09-27', '09:00', '17:00'],
            [testEmployeeId, null, null, 'bad-date', '09:00', '17:00'],
            ['EMP002', null, null, '2026-09-27', null, null],
            [null, null, null, null, null, null],
          ],
        );

        final records = lastAttendanceRepository.records;

        expect(summary.added, 2);
        expect(summary.updated, 0);
        expect(summary.failed, 3);
        expect(summary.skipped, 1);
        expect(summary.totalRows, 5);
        expect(summary.issues.map((issue) => issue.rowNumber), [4, 5, 6]);
        expect(records, hasLength(2));
        expect(records.map((record) => record.employeeId).toSet(), {
          testEmployeeId,
          'EMP002',
        });
      },
    );
  });
}
