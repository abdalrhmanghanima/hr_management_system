import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance/repository/attendance_repository.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_file.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_sheet.dart';
import 'package:hr_management_system/domain/attendance_import/repository/attendance_import_repository.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/domain/department/repository/department_repository.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/employee/repository/employee_repository.dart';
import 'package:hr_management_system/main.dart';
import '../../helpers/authorization_test_data.dart';
import '../../helpers/localization_test_helper.dart';
import 'package:hr_management_system/presentation/attendance/attendance_import_screen.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_import_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/tab/attendance_tab.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';

void main() {
  Future<void> pumpAttendanceTab(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrapWithLocalization(
        ProviderScope(
          overrides: [fullAccessAuthorizationOverride()],
          child: TestApp(
            navigatorKey: navigatorKey,
            home: const AttendanceTab(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

group('Attendance import navigation', () {
    testWidgets('opens the import screen from the attendance app bar', (
      tester,
    ) async {
      await pumpAttendanceTab(tester);

      expect(find.text('attendance.records_title'.tr()), findsOneWidget);

      await tester.tap(find.text('attendance_import.title'.tr()));
      await tester.pumpAndSettle();

      expect(find.byType(AttendanceImportScreen), findsOneWidget);
      expect(find.text('attendance_import.title'.tr()), findsWidgets);
    });

    testWidgets('back navigation returns to the attendance tab', (
      tester,
    ) async {
      await pumpAttendanceTab(tester);

      await tester.tap(find.text('attendance_import.title'.tr()));
      await tester.pumpAndSettle();

      expect(find.byType(AttendanceImportScreen), findsOneWidget);

      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(AttendanceImportScreen), findsNothing);
      expect(find.text('attendance.records_title'.tr()), findsOneWidget);
    });
  });

group('Attendance import screen', () {
    testWidgets('shows the import area with an unavailable import action', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        wrapWithLocalization(
          ProviderScope(
            child: TestApp(
              navigatorKey: navigatorKey,
              home: const AttendanceImportScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('attendance_import.title'.tr()), findsWidgets);
      expect(
        find.text('attendance_import.header_description'.tr()),
        findsOneWidget,
      );
      expect(find.text('attendance_import.choose_file'.tr()), findsOneWidget);
      expect(find.text('attendance.empty'.tr()), findsNothing);
    });

    testWidgets('imports the selected file and shows the result summary', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final attendanceRepository = _FakeAttendanceRepository();

      await tester.pumpWidget(
        wrapWithLocalization(
          ProviderScope(
            overrides: [
              fullAccessAuthorizationOverride(),
              attendanceImportRepositoryProvider.overrideWithValue(
                _FakeAttendanceImportRepository(),
              ),
              attendanceRepositoryProvider.overrideWithValue(
                attendanceRepository,
              ),
              employeeRepositoryProvider.overrideWithValue(
                _FakeEmployeeRepository(),
              ),
              departmentRepositoryProvider.overrideWithValue(
                _FakeDepartmentRepository(),
              ),
            ],
            child: TestApp(
              navigatorKey: navigatorKey,
              home: const AttendanceImportScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('attendance_import.choose_file'.tr()), findsOneWidget);
      expect(find.text('common.change'.tr()), findsNothing);

      await tester.tap(find.text('attendance_import.choose_file'.tr()));
      await tester.pumpAndSettle();

      expect(find.text('attendance.xlsx'), findsOneWidget);
      expect(find.text('common.change'.tr()), findsOneWidget);

      await tester.tap(
        find.widgetWithText(CustomButton, 'attendance_import.title'.tr()),
      );
      await tester.pumpAndSettle();

      expect(attendanceRepository.saved, hasLength(1));
      expect(
        find.text('attendance_import.chip_rows'.tr(namedArgs: {'count': '1'})),
        findsOneWidget,
      );
      expect(
        find.text('attendance_import.chip_added'.tr(namedArgs: {'count': '1'})),
        findsOneWidget,
      );
      expect(
        find.text('attendance_import.chip_updated'.tr(namedArgs: {'count': '0'})),
        findsOneWidget,
      );

      await tester.tap(find.text('common.done'.tr()));
      await tester.pumpAndSettle();

      expect(
        find.text('attendance_import.summary'.tr(namedArgs: {'added': '1', 'updated': '0'})),
        findsOneWidget,
      );
    });
  });
}

class _FakeAttendanceImportRepository implements AttendanceImportRepository {
  @override
  Future<AttendanceImportFile?> pickXlsxFile() async {
    return AttendanceImportFile(name: 'attendance.xlsx', bytes: Uint8List(1));
  }

  @override
  AttendanceImportSheet parseWorkbook(Uint8List bytes) {
    return AttendanceImportSheet(
      columnIndexes: const {
        AttendanceImportColumns.employeeId: 0,
        AttendanceImportColumns.attendanceDate: 1,
        AttendanceImportColumns.checkIn: 2,
        AttendanceImportColumns.checkOut: 3,
      },
      rows: [
        AttendanceImportSheetRow(
          rowNumber: 2,
          values: ['emp-1', '2026-01-05', '09:00', '17:00'],
        ),
      ],
    );
  }
}

class _FakeEmployeeRepository implements EmployeeRepository {
  @override
  Future<List<EmployeeEntity>> getEmployees() async {
    return [
      EmployeeEntity(
        id: 'emp-1',
        fullName: 'Test Employee',
        address: 'Address',
        phoneNumber: '0000',
        birthDate: DateTime(1990),
        nationalId: 'NID-1',
        nationality: 'Egyptian',
        gender: 'Male',
        departmentId: 'dep-1',
        contractDate: DateTime(2020),
        salary: 1000,
      ),
    ];
  }

  @override
  Future<EmployeeEntity> getEmployeeById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<EmployeeEntity?> getEmployeeByNationalId(
    String nationalId, {
    String? excludingId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> addEmployee(EmployeeEntity employee) {
    throw UnimplementedError();
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

class _FakeAttendanceRepository implements AttendanceRepository {
  final List<AttendanceEntity> saved = [];

  @override
  Future<void> addAttendance(AttendanceEntity attendance) async {
    saved.add(attendance);
  }

  @override
  Future<void> updateAttendance(AttendanceEntity attendance) async {
    saved.add(attendance);
  }

  @override
  Future<void> deleteAttendance(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<AttendanceEntity>> getAttendances() async {
    return saved;
  }

  @override
  Future<List<AttendanceEntity>> getAttendancesByEmployeeId(
    String employeeId,
  ) async {
    return saved;
  }

  @override
  Future<AttendanceEntity?> getAttendanceByEmployeeAndDate(
    String employeeId,
    DateTime date,
  ) async {
    return null;
  }
}

class _FakeDepartmentRepository implements DepartmentRepository {
  @override
  Future<List<DepartmentEntity>> getDepartments() async {
    return const [DepartmentEntity(id: 'dep-1', name: 'Engineering')];
  }

  @override
  Future<DepartmentEntity> getDepartmentById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<DepartmentEntity?> getDepartmentByName(
    String name, {
    String? excludingId,
  }) {
    throw UnimplementedError();
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
