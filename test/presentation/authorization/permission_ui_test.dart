import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_entity.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_status.dart';
import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/main.dart';
import 'package:hr_management_system/presentation/attendance/add_attendance_screen.dart';
import 'package:hr_management_system/presentation/attendance/edit_attendance_screen.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/tab/attendance_tab.dart';
import 'package:hr_management_system/presentation/auth/providers/auth_state_provider.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_notifier.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/department/departments_screen.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/add_employee.dart';
import 'package:hr_management_system/presentation/employee/edit_employee.dart';
import 'package:hr_management_system/presentation/employee/employee_details.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/employee/tab/employee_tab.dart';
import 'package:hr_management_system/presentation/groups_permissions/create_group_screen.dart';
import 'package:hr_management_system/presentation/groups_permissions/group_members_screen.dart';
import 'package:hr_management_system/presentation/groups_permissions/provider/group_notifier.dart';
import 'package:hr_management_system/presentation/groups_permissions/provider/group_provider.dart';
import 'package:hr_management_system/presentation/groups_permissions/groups_screen.dart';
import 'package:hr_management_system/presentation/home/home_screen.dart';
import 'package:hr_management_system/presentation/home/provider/bottom_nav_provider.dart';
import 'package:hr_management_system/presentation/home/tabs/home_tab.dart';
import 'package:hr_management_system/presentation/home/tabs/home_tab_item.dart';
import 'package:hr_management_system/presentation/more/provider/general_settings_provider.dart';
import 'package:hr_management_system/presentation/more/tab/more_tab.dart';
import 'package:hr_management_system/presentation/official_holiday/add_official_holiday_screen.dart';
import 'package:hr_management_system/presentation/official_holiday/edit_official_holiday_screen.dart';
import 'package:hr_management_system/presentation/official_holiday/official_holidays_screen.dart';
import 'package:hr_management_system/presentation/official_holiday/provider/official_holidays_provider.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_floating_action_button.dart';

import '../../helpers/attendance_test_data.dart';
import '../../helpers/authorization_test_data.dart';
import '../../helpers/localization_test_helper.dart';

class FakeGroupNotifier extends GroupNotifier {
  @override
  Future<List<GroupEntity>> build() async => const [
    GroupEntity(
      id: 'group-1',
      name: 'HR',
      description: 'Human resources',
      employeeIds: ['employee-1'],
    ),
  ];
}

class MutableAuthorizationNotifier extends AuthorizationNotifier {
  MutableAuthorizationNotifier(this.entity);

  AuthorizationEntity entity;

  @override
  Future<AuthorizationEntity> build() async => entity;

  @override
  Future<void> reload() async {
    state = AsyncData(entity);
  }

  void setEntity(AuthorizationEntity next) {
    entity = next;
    state = AsyncData(next);
  }
}

void main() {
  final dataOverrides = <Override>[];

  setUp(() {
    dataOverrides
      ..clear()
      ..add(employeeRepositoryProvider.overrideWithValue(FakeEmployeeRepository()))
      ..add(
        attendanceRepositoryProvider.overrideWithValue(
          FakeAttendanceRepository([buildAttendance(id: 'att-1')]),
        ),
      )
      ..add(
        departmentRepositoryProvider.overrideWithValue(
          FakeDepartmentRepository(),
        ),
      )
      ..add(
        generalSettingsRepositoryProvider.overrideWithValue(
          FakeGeneralSettingsRepository(),
        ),
      )
      ..add(
        officialHolidayRepositoryProvider.overrideWithValue(
          FakeOfficialHolidayRepository(),
        ),
      )
      ..add(
        groupProvider.overrideWith(() => FakeGroupNotifier()),
      )
      ..add(authStateProvider.overrideWith((ref) => Stream.value(null)));
  });

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    required List<Override> overrides,
  }) async {
    tester.view.physicalSize = const Size(480, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrapWithLocalization(
        ProviderScope(
          overrides: overrides,
          child: TestApp(navigatorKey: navigatorKey, home: screen),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  Override deniedAuthorizationOverride() {
    return authorizationProvider.overrideWith(
      () => FakeAuthorizationNotifier(
        buildTestAuthorization(fullAccess: false),
      ),
    );
  }

  Override viewOnlyAuthorizationOverride(GroupModule module) {
    return authorizationProvider.overrideWith(
      () => FakeAuthorizationNotifier(
        buildTestAuthorization(
          fullAccess: false,
          permissions: {module: viewOnlyPermission},
        ),
      ),
    );
  }

  group('More tab entry visibility', () {
    testWidgets('hides protected entries without view permission', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const MoreTab(),
        overrides: [...dataOverrides, deniedAuthorizationOverride()],
      );

      expect(find.text('Departments'), findsNothing);
      expect(find.text('User Groups & Permissions'), findsNothing);
      expect(find.text('Official Holidays'), findsNothing);
      expect(find.text('Application Users'), findsNothing);
      expect(find.text('My Profile'), findsNothing);
    });

    testWidgets('shows protected entries with view permission', (tester) async {
      await pumpScreen(
        tester,
        const MoreTab(),
        overrides: [...dataOverrides, fullAccessAuthorizationOverride()],
      );

      expect(find.text('Departments'), findsOneWidget);
      expect(find.text('User Groups & Permissions'), findsOneWidget);
      expect(find.text('Official Holidays'), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
    });
  });

  group('Employees tab actions', () {
    testWidgets('hides the add action without add permission', (tester) async {
      await pumpScreen(
        tester,
        const EmployeesTab(),
        overrides: [
          ...dataOverrides,
          viewOnlyAuthorizationOverride(GroupModules.employees),
        ],
      );

      expect(find.byType(AppFloatingActionButton), findsNothing);
    });

    testWidgets('shows the add action with add permission', (tester) async {
      await pumpScreen(
        tester,
        const EmployeesTab(),
        overrides: [...dataOverrides, fullAccessAuthorizationOverride()],
      );

      expect(find.byType(AppFloatingActionButton), findsOneWidget);
    });
  });

  group('Attendance tab actions', () {
    testWidgets('hides import and add actions without permissions', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const AttendanceTab(),
        overrides: [
          ...dataOverrides,
          viewOnlyAuthorizationOverride(GroupModules.attendance),
        ],
      );

      expect(find.text('attendance_import.title'.tr()), findsNothing);
      expect(find.byType(AppFloatingActionButton), findsNothing);
    });

    testWidgets('shows import and add actions with full permissions', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const AttendanceTab(),
        overrides: [...dataOverrides, fullAccessAuthorizationOverride()],
      );

      expect(find.text('attendance_import.title'.tr()), findsOneWidget);
      expect(find.byType(AppFloatingActionButton), findsOneWidget);
    });
  });

  group('Protected screen guards', () {
    testWidgets('groups screen is blocked without view permission', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const GroupsScreen(),
        overrides: [...dataOverrides, deniedAuthorizationOverride()],
      );

      expect(find.text('Groups & Permissions'), findsNothing);
    });

    testWidgets('groups screen renders with view permission', (tester) async {
      await pumpScreen(
        tester,
        const GroupsScreen(),
        overrides: [...dataOverrides, fullAccessAuthorizationOverride()],
      );

      expect(find.text('Groups & Permissions'), findsOneWidget);
    });

    testWidgets('departments screen is blocked without view permission', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const DepartmentsScreen(),
        overrides: [...dataOverrides, deniedAuthorizationOverride()],
      );

      expect(find.text('Departments'), findsNothing);
    });

    testWidgets('holidays screen is blocked without view permission', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const OfficialHolidaysScreen(),
        overrides: [...dataOverrides, deniedAuthorizationOverride()],
      );

      expect(find.text('Official Holidays'), findsNothing);
    });
  });

  group('Write screen guards', () {
    Future<void> expectBlocked(
      WidgetTester tester,
      Widget screen, {
      required List<Override> overrides,
      required String grantedMarker,
    }) async {
      await pumpScreen(tester, screen, overrides: overrides);

      expect(find.text(grantedMarker), findsNothing);
    }

    testWidgets('add employee is blocked without add permission', (
      tester,
    ) async {
      await expectBlocked(
        tester,
        const AddEmployee(),
        overrides: [
          ...dataOverrides,
          viewOnlyAuthorizationOverride(GroupModules.employees),
        ],
        grantedMarker: 'Save Employee',
      );
    });

    testWidgets('add employee is allowed with add permission', (tester) async {
      await pumpScreen(
        tester,
        const AddEmployee(),
        overrides: [...dataOverrides, fullAccessAuthorizationOverride()],
      );

      expect(find.text('Save Employee'), findsOneWidget);
    });

    testWidgets('edit employee is blocked without edit permission', (
      tester,
    ) async {
      await expectBlocked(
        tester,
        const EditEmployee(employeeId: 'EMP001'),
        overrides: [
          ...dataOverrides,
          viewOnlyAuthorizationOverride(GroupModules.employees),
        ],
        grantedMarker: 'Update Employee',
      );
    });

    testWidgets('add attendance is blocked without add permission', (
      tester,
    ) async {
      await expectBlocked(
        tester,
        const AddAttendanceScreen(),
        overrides: [
          ...dataOverrides,
          viewOnlyAuthorizationOverride(GroupModules.attendance),
        ],
        grantedMarker: 'Save Attendance',
      );
    });

    testWidgets('add attendance is allowed with add permission', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const AddAttendanceScreen(),
        overrides: [...dataOverrides, fullAccessAuthorizationOverride()],
      );

      expect(find.text('Save Attendance'), findsOneWidget);
    });

    testWidgets('edit attendance is blocked without edit permission', (
      tester,
    ) async {
      await expectBlocked(
        tester,
        EditAttendanceScreen(
          attendance: buildAttendance(id: 'att-1'),
        ),
        overrides: [
          ...dataOverrides,
          viewOnlyAuthorizationOverride(GroupModules.attendance),
        ],
        grantedMarker: 'Update Attendance',
      );
    });

    testWidgets('add holiday is blocked without add permission', (
      tester,
    ) async {
      await expectBlocked(
        tester,
        const AddOfficialHolidayScreen(),
        overrides: [
          ...dataOverrides,
          viewOnlyAuthorizationOverride(GroupModules.officialHolidays),
        ],
        grantedMarker: 'Save Holiday',
      );
    });

    testWidgets('edit holiday is blocked without edit permission', (
      tester,
    ) async {
      await expectBlocked(
        tester,
        EditOfficialHolidayScreen(
          holiday: OfficialHolidayEntity(
            id: 'hol-1',
            name: 'New Year',
            date: DateTime(2026, 1, 1),
          ),
        ),
        overrides: [
          ...dataOverrides,
          viewOnlyAuthorizationOverride(GroupModules.officialHolidays),
        ],
        grantedMarker: 'Update Holiday',
      );
    });

    testWidgets('create group is blocked without add permission', (
      tester,
    ) async {
      await expectBlocked(
        tester,
        const CreateGroupScreen(),
        overrides: [
          ...dataOverrides,
          viewOnlyAuthorizationOverride(GroupModules.groups),
        ],
        grantedMarker: 'Save Group',
      );
    });

    testWidgets('group members is blocked without edit permission', (
      tester,
    ) async {
      await expectBlocked(
        tester,
        const GroupMembersScreen(
          groupId: 'group-1',
          groupName: 'HR',
          memberIds: ['EMP001'],
        ),
        overrides: [
          ...dataOverrides,
          viewOnlyAuthorizationOverride(GroupModules.groups),
        ],
        grantedMarker: 'Save Members',
      );
    });
  });

  group('Employee details access', () {
    testWidgets('blocks another profile without employees view', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const EmployeeDetails(employeeId: 'EMP002'),
        overrides: [
          ...dataOverrides,
          authorizationProvider.overrideWith(
            () => FakeAuthorizationNotifier(
              buildTestAuthorization(
                employeeId: 'EMP001',
                fullAccess: false,
                permissions: {GroupModules.profile: viewOnlyPermission},
              ),
            ),
          ),
        ],
      );

      expect(
        find.text('You do not have access to this profile.'),
        findsOneWidget,
      );
    });

    testWidgets('allows the own profile with profile view', (tester) async {
      await pumpScreen(
        tester,
        const EmployeeDetails(employeeId: 'EMP001'),
        overrides: [
          ...dataOverrides,
          authorizationProvider.overrideWith(
            () => FakeAuthorizationNotifier(
              buildTestAuthorization(
                employeeId: 'EMP001',
                fullAccess: false,
                permissions: {GroupModules.profile: viewOnlyPermission},
              ),
            ),
          ),
        ],
      );

      expect(
        find.text('You do not have access to this profile.'),
        findsNothing,
      );
      expect(find.text('Personal Information'), findsOneWidget);
    });

    testWidgets('allows any profile with employees view', (tester) async {
      await pumpScreen(
        tester,
        const EmployeeDetails(employeeId: 'EMP002'),
        overrides: [
          ...dataOverrides,
          employeeRepositoryProvider.overrideWithValue(
            FakeEmployeeRepository([
              buildEmployee(),
              buildEmployee(
                id: 'EMP002',
                nationalId: '29801019999999',
                fullName: 'Sara Ibrahim',
              ),
            ]),
          ),
          fullAccessAuthorizationOverride(),
        ],
      );

      expect(
        find.text('You do not have access to this profile.'),
        findsNothing,
      );
      expect(find.text('Personal Information'), findsOneWidget);
    });
  });

  group('Home tab access state', () {
    Future<void> pumpWithStatus(
      WidgetTester tester,
      AuthorizationStatus status,
    ) async {
      await pumpScreen(tester, const HomeTab(), overrides: [
        ...dataOverrides,
        authorizationProvider.overrideWith(
          () => FakeAuthorizationNotifier(
            buildTestAuthorizationForStatus(status),
          ),
        ),
      ]);
    }

    testWidgets('explains that the account has no group', (tester) async {
      await pumpWithStatus(tester, AuthorizationStatus.withoutGroup);

      expect(
        find.text(
          'Your account is not assigned to a group, so no modules are available.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('explains that the account is deactivated', (tester) async {
      await pumpWithStatus(tester, AuthorizationStatus.inactive);

      expect(
        find.text('Your account has been deactivated.'),
        findsOneWidget,
      );
    });

    testWidgets('explains that the group no longer exists', (tester) async {
      await pumpWithStatus(tester, AuthorizationStatus.groupNotFound);

      expect(
        find.text('The group assigned to your account no longer exists.'),
        findsOneWidget,
      );
    });

    testWidgets('explains that the account is not linked yet', (tester) async {
      await pumpWithStatus(tester, AuthorizationStatus.missingUserDocument);

      expect(
        find.text('Your account is not linked to an application user yet.'),
        findsOneWidget,
      );
    });

    testWidgets('shows a checking message while loading', (tester) async {
      await pumpWithStatus(tester, AuthorizationStatus.loading);

      expect(find.text('Checking your access...'), findsOneWidget);
    });

    testWidgets('explains that the group grants no module', (tester) async {
      await pumpScreen(
        tester,
        const HomeTab(),
        overrides: [...dataOverrides, deniedAuthorizationOverride()],
      );

      expect(
        find.text('You do not have access to any modules.'),
        findsOneWidget,
      );
      expect(find.text('Quick Actions'), findsNothing);
    });

    testWidgets('explains a failed permission load and recovers', (
      tester,
    ) async {
      final notifier = FailingAuthorizationNotifier();

      await pumpScreen(
        tester,
        const HomeTab(),
        overrides: [
          ...dataOverrides,
          authorizationProvider.overrideWith(() => notifier),
        ],
      );

      expect(
        find.text('We could not load your permissions. Pull down to try again.'),
        findsOneWidget,
      );
      expect(find.text('Checking your access...'), findsNothing);

      await tester.fling(
        find.byType(RefreshIndicator),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      expect(notifier.reloadCount, 1);
      expect(find.text('Quick Actions'), findsOneWidget);
    });
  });

  group('Visible home tabs', () {
    Future<List<HomeTabItem>> readVisibleTabs({
      required List<Override> overrides,
    }) async {
      final container = ProviderContainer(overrides: overrides);
      addTearDown(container.dispose);

      await container.read(authorizationProvider.future);

      return container.read(visibleHomeTabsProvider);
    }

    test('keeps only home and more when no module is granted', () async {
      expect(
        await readVisibleTabs(
          overrides: [...dataOverrides, deniedAuthorizationOverride()],
        ),
        [HomeTabItem.home, HomeTabItem.more],
      );
    });

    test('keeps home and more when authorization is unresolved', () async {
      expect(
        await readVisibleTabs(overrides: [
          ...dataOverrides,
          authorizationProvider.overrideWith(
            () => FakeAuthorizationNotifier(
              buildTestAuthorizationForStatus(AuthorizationStatus.withoutGroup),
            ),
          ),
        ]),
        [HomeTabItem.home, HomeTabItem.more],
      );
    });

    for (final status in [
      AuthorizationStatus.loading,
      AuthorizationStatus.unauthenticated,
      AuthorizationStatus.missingUserDocument,
      AuthorizationStatus.inactive,
      AuthorizationStatus.withoutGroup,
      AuthorizationStatus.groupNotFound,
      AuthorizationStatus.failed,
    ]) {
      test('never drops below two tabs for status $status', () async {
        final tabs = await readVisibleTabs(overrides: [
          ...dataOverrides,
          authorizationProvider.overrideWith(
            () => FakeAuthorizationNotifier(
              buildTestAuthorizationForStatus(status),
            ),
          ),
        ]);

        expect(tabs.length, greaterThanOrEqualTo(2));
        expect(tabs, contains(HomeTabItem.home));
        expect(tabs, contains(HomeTabItem.more));
      });
    }

    test('returns home and more while authorization is loading', () {
      final container = ProviderContainer(
        overrides: [...dataOverrides, deniedAuthorizationOverride()],
      );
      addTearDown(container.dispose);

      expect(container.read(visibleHomeTabsProvider), [
        HomeTabItem.home,
        HomeTabItem.more,
      ]);
    });

    test('hides modules the group cannot view', () async {
      final tabs = await readVisibleTabs(overrides: [
        ...dataOverrides,
        authorizationProvider.overrideWith(
          () => FakeAuthorizationNotifier(
            buildTestAuthorization(
              fullAccess: false,
              permissions: {
                GroupModules.employees: fullAccessPermission,
                GroupModules.attendance: viewOnlyPermission,
              },
            ),
          ),
        ),
      ]);

      expect(tabs, [
        HomeTabItem.home,
        HomeTabItem.employees,
        HomeTabItem.attendance,
        HomeTabItem.more,
      ]);
    });

    test('returns every tab with full access', () async {
      expect(
        await readVisibleTabs(
          overrides: [...dataOverrides, fullAccessAuthorizationOverride()],
        ),
        HomeTabItem.values,
      );
    });
  });

  group('Home navigation bar', () {
    Future<ProviderContainer> pumpHomeScreen(
      WidgetTester tester,
      List<Override> overrides,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final container = ProviderContainer(overrides: overrides);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        wrapWithLocalization(
          UncontrolledProviderScope(
            container: container,
            child: TestApp(
              navigatorKey: navigatorKey,
              home: const HomeScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      return container;
    }

    List<BottomNavigationBarItem> navItems(WidgetTester tester) {
      return tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .items;
    }

    List<String> navLabels(WidgetTester tester) {
      return navItems(tester).map((item) => item.label ?? '').toList();
    }

    testWidgets('lists every tab with full access', (tester) async {
      await pumpHomeScreen(tester, [
        ...dataOverrides,
        fullAccessAuthorizationOverride(),
      ]);

      expect(navLabels(tester), [
        'Home',
        'Employees',
        'Attendance',
        'Payroll',
        'More',
      ]);
    });

    testWidgets('keeps home and more when no module is granted', (
      tester,
    ) async {
      await pumpHomeScreen(tester, [
        ...dataOverrides,
        deniedAuthorizationOverride(),
      ]);

      expect(navLabels(tester), ['Home', 'More']);
    });

    testWidgets('adds a tab for every granted module', (tester) async {
      await pumpHomeScreen(tester, [
        ...dataOverrides,
        authorizationProvider.overrideWith(
          () => FakeAuthorizationNotifier(
            buildTestAuthorization(
              fullAccess: false,
              permissions: {
                GroupModules.employees: viewOnlyPermission,
                GroupModules.payroll: viewOnlyPermission,
              },
            ),
          ),
        ),
      ]);

      expect(navLabels(tester), ['Home', 'Employees', 'Payroll', 'More']);
    });

    for (final status in [
      AuthorizationStatus.loading,
      AuthorizationStatus.unauthenticated,
      AuthorizationStatus.missingUserDocument,
      AuthorizationStatus.inactive,
      AuthorizationStatus.withoutGroup,
      AuthorizationStatus.groupNotFound,
      AuthorizationStatus.failed,
    ]) {
      testWidgets('renders a usable navigation bar for status $status', (
        tester,
      ) async {
        await pumpHomeScreen(tester, [
          ...dataOverrides,
          authorizationProvider.overrideWith(
            () => MutableAuthorizationNotifier(
              buildTestAuthorizationForStatus(status),
            ),
          ),
        ]);

        expect(navItems(tester).length, greaterThanOrEqualTo(2));
        expect(navLabels(tester), ['Home', 'More']);
      });
    }

    testWidgets('renders a usable navigation bar when loading fails', (
      tester,
    ) async {
      await pumpHomeScreen(tester, [
        ...dataOverrides,
        authorizationProvider.overrideWith(() => FailingAuthorizationNotifier()),
      ]);

      expect(navItems(tester).length, greaterThanOrEqualTo(2));
      expect(navItems(tester).first.label, 'Home');
    });

    testWidgets('falls back to a visible tab when the current one is revoked', (
      tester,
    ) async {
      final notifier = MutableAuthorizationNotifier(
        buildTestAuthorization(
          fullAccess: false,
          permissions: {GroupModules.payroll: viewOnlyPermission},
        ),
      );

      final container = await pumpHomeScreen(tester, [
        ...dataOverrides,
        authorizationProvider.overrideWith(() => notifier),
      ]);

      expect(navLabels(tester), ['Home', 'Payroll', 'More']);

      await tester.tap(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text('Payroll'),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(currentHomeTabProvider), HomeTabItem.payroll);

      notifier.setEntity(buildTestAuthorization(fullAccess: false));
      await tester.pumpAndSettle();

      expect(container.read(currentHomeTabProvider), HomeTabItem.home);
      expect(navLabels(tester), ['Home', 'More']);
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        0,
      );
    });

    testWidgets('keeps the current tab when it stays available', (
      tester,
    ) async {
      final notifier = MutableAuthorizationNotifier(
        buildTestAuthorization(
          fullAccess: false,
          permissions: {
            GroupModules.employees: viewOnlyPermission,
            GroupModules.attendance: viewOnlyPermission,
          },
        ),
      );

      final container = await pumpHomeScreen(tester, [
        ...dataOverrides,
        authorizationProvider.overrideWith(() => notifier),
      ]);

      await tester.tap(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text('Attendance'),
        ),
      );
      await tester.pumpAndSettle();

      notifier.setEntity(
        buildTestAuthorization(
          fullAccess: false,
          permissions: {
            GroupModules.attendance: fullAccessPermission,
            GroupModules.payroll: viewOnlyPermission,
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(currentHomeTabProvider), HomeTabItem.attendance);
      expect(navLabels(tester), [
        'Home',
        'Attendance',
        'Payroll',
        'More',
      ]);
    });
  });
}
