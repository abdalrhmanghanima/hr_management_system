import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/data/attendance/data_source/attendance_remote_data_source.dart';
import 'package:hr_management_system/data/attendance/model/attendance_model.dart';
import 'package:hr_management_system/domain/application_user/entity/application_user_entity.dart';
import 'package:hr_management_system/domain/application_user/repository/application_user_repository.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_entity.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_status.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/domain/auth/entity/user_entity.dart';
import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';
import 'package:hr_management_system/main.dart';
import 'package:hr_management_system/presentation/application_user/provider/application_user_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_action_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/selected_attendance_month_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/selected_attendance_status_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/selected_employee_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/today_attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/tab/attendance_tab.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_record_card.dart';
import 'package:hr_management_system/presentation/auth/providers/auth_state_provider.dart';
import 'package:hr_management_system/presentation/auth/providers/login_notifier.dart';
import 'package:hr_management_system/presentation/auth/providers/login_provider.dart';
import 'package:hr_management_system/presentation/auth/screens/login_screen.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_notifier.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/department/provider/department_by_id_provider.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_details_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/gender_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/selected_department_provider.dart';
import 'package:hr_management_system/presentation/home/home_screen.dart';
import 'package:hr_management_system/presentation/home/provider/bottom_nav_provider.dart';
import 'package:hr_management_system/presentation/home/tabs/home_tab_item.dart';
import 'package:hr_management_system/presentation/more/provider/general_settings_provider.dart';
import 'package:hr_management_system/presentation/official_holiday/provider/official_holidays_provider.dart';
import 'package:hr_management_system/presentation/payroll/provider/payroll_provider.dart';

import '../../helpers/attendance_test_data.dart';
import '../../helpers/authorization_test_data.dart';
import '../../helpers/localization_test_helper.dart';

class FakeAttendanceRemoteDataSource implements AttendanceRemoteDataSource {
  FakeAttendanceRemoteDataSource(
    List<AttendanceModel>? initial, {
    this.latency = Duration.zero,
  }) : documents = [...?initial];

  final List<AttendanceModel> documents;

  /// Emulates Firestore round-trip time so provider rebuild ordering can race.
  final Duration latency;

  int queryCount = 0;
  int writeCount = 0;

  Future<void> _wait() async {
    if (latency == Duration.zero) return;

    await Future<void>.delayed(latency);
  }

  @override
  Future<List<AttendanceModel>> getAttendances() async {
    queryCount++;
    await _wait();

    return documents;
  }

  @override
  Future<List<AttendanceModel>> getAttendancesByEmployeeId(
    String employeeId,
  ) async {
    queryCount++;
    await _wait();

    return documents
        .where((document) => document.employeeId == employeeId)
        .toList();
  }

  @override
  Future<AttendanceModel?> getAttendanceByEmployeeAndDate(
    String employeeId,
    DateTime date,
  ) async {
    for (final document in documents) {
      if (document.employeeId == employeeId &&
          document.attendanceDate.year == date.year &&
          document.attendanceDate.month == date.month &&
          document.attendanceDate.day == date.day) {
        return document;
      }
    }

    return null;
  }

  @override
  Future<void> addAttendance(AttendanceModel attendance) async {
    writeCount++;
    documents.add(attendance);
  }

  @override
  Future<void> updateAttendance(AttendanceModel attendance) async {
    writeCount++;
  }

  @override
  Future<void> deleteAttendance(String id) async {}
}

/// Mimics `AuthorizationNotifier` reading `FirebaseAuth.instance.currentUser`
/// and resolving the user's group from Firestore.
class SessionAuthorizationNotifier extends AuthorizationNotifier {
  SessionAuthorizationNotifier(this.entity, {this.latency = Duration.zero});

  final AuthorizationEntity entity;

  /// Emulates the real `AuthorizationNotifier.build` Firestore round-trip.
  final Duration latency;

  bool signedIn = true;

  int buildCount = 0;

  @override
  Future<AuthorizationEntity> build() async {
    buildCount++;
    debugPrint(
      '[ATTENDANCE-RELOGIN] auth.build#$buildCount start '
      'signedIn=$signedIn latency=${latency.inMilliseconds}ms',
    );

    if (latency != Duration.zero) {
      await Future<void>.delayed(latency);
    }

    if (!signedIn) {
      debugPrint('[ATTENDANCE-RELOGIN] auth.build#$buildCount -> unauthenticated');
      return const AuthorizationEntity.unauthenticated();
    }

    debugPrint(
      '[ATTENDANCE-RELOGIN] auth.build#$buildCount -> ${entity.status}',
    );
    return entity;
  }
}

class FakeAuthRepo implements AuthRepo {
  int loginCallCount = 0;

  int logoutCallCount = 0;

  @override
  Future<UserEntity> login({required String email, required String password}) {
    loginCallCount++;

    return Future.value(
      const UserEntity(uid: 'uid-1', email: 'user@example.com'),
    );
  }

  @override
  Future<void> logout() async {
    logoutCallCount++;
  }

  @override
  Future<UserEntity?> getUserByUid(String uid) async => null;

  @override
  Future<void> updateUserGroup({
    required String uid,
    required String employeeId,
    String? groupId,
  }) async {}
}

class FakeApplicationUserRepository implements ApplicationUserRepository {
  @override
  Future<List<ApplicationUserEntity>> getApplicationUsers() async => const [];

  @override
  Future<ApplicationUserEntity?> getApplicationUserByUid(String uid) async {
    return const ApplicationUserEntity(
      id: 'app-1',
      employeeId: testEmployeeId,
      email: 'user@example.com',
    );
  }

  @override
  Future<void> updateApplicationUser(
    ApplicationUserEntity applicationUser,
  ) async {}
}

AttendanceModel _doc({
  String id = 'att-1',
  String employeeId = testEmployeeId,
  DateTime? date,
}) {
  return AttendanceModel(
    id: id,
    employeeId: employeeId,
    attendanceDate: date ?? DateTime(2026, 9, 27),
    status: AttendanceEntity.presentStatus,
  );
}

void ignoreRenderFlexOverflows() {
  final previous = FlutterError.onError;

  FlutterError.onError = (details) {
    if (details.exceptionAsString().startsWith('A RenderFlex overflowed')) {
      return;
    }

    previous == null ? FlutterError.presentError(details) : previous(details);
  };

  addTearDown(() => FlutterError.onError = previous);
}

/// Mirrors `invalidateUserScopedData` (logout).
void _invalidateUserScopedData(ProviderContainer container) {
  container
    ..invalidate(loginProvider)
    ..invalidate(authorizationProvider)
    ..invalidate(employeeProvider)
    ..invalidate(employeeDetailsProvider)
    ..invalidate(departmentProvider)
    ..invalidate(departmentByIdProvider)
    ..invalidate(attendanceProvider)
    ..invalidate(attendanceActionProvider)
    ..invalidate(todayAttendanceProvider)
    ..invalidate(officialHolidaysProvider)
    ..invalidate(selectedEmployeeProvider)
    ..invalidate(selectedAttendanceStatusProvider)
    ..invalidate(genderProvider)
    ..invalidate(selectedDepartmentProvider)
    ..invalidate(payrollSummariesProvider);
}

class _Harness {
  _Harness({
    required this.authorization,
    required this.source,
    required this.authRepo,
    required this.holidayRepository,
    required this.container,
  });

  final SessionAuthorizationNotifier authorization;
  final FakeAttendanceRemoteDataSource source;
  final FakeAuthRepo authRepo;
  final FakeOfficialHolidayRepository holidayRepository;
  final ProviderContainer container;
}

_Harness _createHarness({
  Duration latency = Duration.zero,
  Duration authorizationLatency = Duration.zero,
}) {
  final authorization = SessionAuthorizationNotifier(
    buildTestAuthorization(),
    latency: authorizationLatency,
  );
  final source = FakeAttendanceRemoteDataSource([_doc()], latency: latency);
  final authRepo = FakeAuthRepo();
  final holidayRepository = FakeOfficialHolidayRepository();

  final container = ProviderContainer(
    overrides: [
      authorizationProvider.overrideWith(() => authorization),
      authStateProvider.overrideWith((ref) => Stream.value(null)),
      attendanceRemoteDataSourceProvider.overrideWithValue(source),
      authRepoProvider.overrideWithValue(authRepo),
      applicationUserRepositoryProvider.overrideWithValue(
        FakeApplicationUserRepository(),
      ),
      employeeRepositoryProvider.overrideWithValue(FakeEmployeeRepository()),
      departmentRepositoryProvider.overrideWithValue(FakeDepartmentRepository()),
      generalSettingsRepositoryProvider.overrideWithValue(
        FakeGeneralSettingsRepository(),
      ),
      officialHolidayRepositoryProvider.overrideWithValue(holidayRepository),
      selectedAttendanceMonthProvider.overrideWith((ref) => DateTime(2026, 9)),
    ],
  );

  return _Harness(
    authorization: authorization,
    source: source,
    authRepo: authRepo,
    holidayRepository: holidayRepository,
    container: container,
  );
}

Future<void> _pumpHomeScreen(WidgetTester tester, ProviderContainer container) {
  return tester.pumpWidget(
    wrapWithLocalization(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(navigatorKey: navigatorKey, home: const HomeScreen()),
      ),
    ),
  );
}

void main() {
  group('logout then login re-initializes user scoped providers', () {
    testWidgets('when authorization is flushed to unauthenticated at logout', (
      tester,
    ) async {
      ignoreRenderFlexOverflows();

      tester.view.physicalSize = const Size(480, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final harness = _createHarness();
      addTearDown(harness.container.dispose);

      await _pumpHomeScreen(tester, harness.container);
      await tester.pumpAndSettle();

      expect(
        harness.container.read(authorizationProvider).valueOrNull?.status,
        AuthorizationStatus.authenticated,
      );
      expect(harness.container.read(attendanceProvider).valueOrNull, isNotEmpty);
      expect(
        harness.container.read(visibleHomeTabsProvider),
        contains(HomeTabItem.attendance),
      );

      final queriesBeforeLogout = harness.source.queryCount;

      // ---- Logout -----------------------------------------------------
      harness.authorization.signedIn = false;
      _invalidateUserScopedData(harness.container);

      unawaited(NavigatorHandler.pushAndRemoveUntil(LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);

      // Riverpod refreshes invalidated providers that still had listeners.
      expect(
        harness.container.read(authorizationProvider).valueOrNull?.status,
        AuthorizationStatus.unauthenticated,
      );

      final holidayLoadsBeforeLogin = harness.holidayRepository.loadCount;

      // ---- Login ------------------------------------------------------
      harness.authorization.signedIn = true;

      await harness.container
          .read(loginProvider.notifier)
          .login(email: 'user@example.com', password: 'secret');

      await tester.pumpAndSettle();

      expect(harness.authRepo.loginCallCount, 1);
      expect(find.byType(HomeScreen), findsOneWidget);

      expect(
        harness.container.read(authorizationProvider).valueOrNull?.status,
        AuthorizationStatus.authenticated,
        reason: 'authorization must be reloaded for the new session',
      );
      expect(
        harness.container.read(visibleHomeTabsProvider),
        containsAll([
          HomeTabItem.home,
          HomeTabItem.employees,
          HomeTabItem.attendance,
          HomeTabItem.payroll,
          HomeTabItem.more,
        ]),
      );
      expect(
        harness.source.queryCount,
        greaterThan(queriesBeforeLogout),
        reason: 'a firestore attendance query must run after login',
      );
      expect(
        harness.container.read(attendanceProvider).valueOrNull,
        isNotEmpty,
        reason: 'attendance records must be shown without restarting the app',
      );
      expect(
        harness.container.read(employeeProvider).valueOrNull,
        isNotEmpty,
      );
      expect(
        harness.container.read(departmentProvider).valueOrNull,
        isNotEmpty,
      );
      expect(
        harness.holidayRepository.loadCount,
        greaterThan(holidayLoadsBeforeLogin),
        reason: 'official holidays must be reloaded after login',
      );
      expect(harness.container.read(officialHolidaysProvider).hasValue, isTrue);

      final payrollMonth = harness.container.read(currentPayrollMonthProvider);
      final payroll = harness.container.read(
        payrollSummariesProvider(payrollMonth),
      );

      expect(payroll.hasError, isFalse);
      expect(payroll.hasValue, isTrue, reason: 'payroll must be available');

      // A record added right after login must show up without a restart.
      final saveResult = await harness.container
          .read(attendanceProvider.notifier)
          .addAttendance(buildAttendance(id: 'att-2', date: DateTime(2026, 9, 28)));

      expect(saveResult, SaveResult.success);
      expect(harness.source.writeCount, 1);
      expect(
        harness.container.read(attendanceProvider).valueOrNull,
        hasLength(2),
        reason: 'a newly added attendance must appear without restarting',
      );
    });

    testWidgets('when authorization stays cached from the previous session', (
      tester,
    ) async {
      ignoreRenderFlexOverflows();

      tester.view.physicalSize = const Size(480, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final harness = _createHarness();
      addTearDown(harness.container.dispose);

      await _pumpHomeScreen(tester, harness.container);
      await tester.pumpAndSettle();

      final queriesBeforeLogout = harness.source.queryCount;

      // ---- Logout -----------------------------------------------------
      harness.authorization.signedIn = false;
      _invalidateUserScopedData(harness.container);

      unawaited(NavigatorHandler.pushAndRemoveUntil(LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);

      // Nothing reads authorization while logged out, so the invalidated
      // provider keeps its previous (authenticated) value until re-login.

      // ---- Login ------------------------------------------------------
      harness.authorization.signedIn = true;

      await harness.container
          .read(loginProvider.notifier)
          .login(email: 'user@example.com', password: 'secret');

      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        harness.container.read(authorizationProvider).valueOrNull?.status,
        AuthorizationStatus.authenticated,
      );
      expect(
        harness.container.read(visibleHomeTabsProvider),
        contains(HomeTabItem.attendance),
      );
      expect(
        harness.source.queryCount,
        greaterThan(queriesBeforeLogout),
        reason: 'a firestore attendance query must run after login',
      );
      expect(
        harness.container.read(attendanceProvider).valueOrNull,
        isNotEmpty,
        reason: 'attendance records must be shown without restarting the app',
      );
    });
  });

  group('logout -> login -> open Attendance tab', () {
    for (final latencies in <(Duration, Duration)>[
      (Duration.zero, Duration.zero),
      (const Duration(milliseconds: 40), const Duration(milliseconds: 150)),
      (const Duration(milliseconds: 120), const Duration(milliseconds: 30)),
    ]) {
      final attendanceLatency = latencies.$1;
      final authorizationLatency = latencies.$2;

      testWidgets(
        'renders the records (attendance=${attendanceLatency.inMilliseconds}ms, '
        'authorization=${authorizationLatency.inMilliseconds}ms)',
        (tester) async {
          ignoreRenderFlexOverflows();

          tester.view.physicalSize = const Size(480, 2400);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          final harness = _createHarness(
            latency: attendanceLatency,
            authorizationLatency: authorizationLatency,
          );
          addTearDown(harness.container.dispose);

          // ---- Session 1: fresh login -----------------------------------
          await _pumpHomeScreen(tester, harness.container);
          await _settle(tester);
          debugPrint(
            '[ATTENDANCE-RELOGIN] afterSession1Settle auth=${harness.container.read(authorizationProvider)} builds=${harness.authorization.buildCount}',
          );

          await _openAttendanceTab(tester, harness.container);
          expect(
            _attendanceCards(tester),
            findsWidgets,
            reason: 'records must be visible in the Attendance tab (session 1)',
          );
          expect(find.text('No attendance records found'), findsNothing);

          // ---- Logout ----------------------------------------------------
          harness.authorization.signedIn = false;
          _invalidateUserScopedData(harness.container);

          unawaited(NavigatorHandler.pushAndRemoveUntil(LoginScreen()));
          await _settle(tester);

          expect(find.byType(LoginScreen), findsOneWidget);

          // ---- Login again ----------------------------------------------
          harness.authorization.signedIn = true;

          await harness.container
              .read(loginProvider.notifier)
              .login(email: 'user@example.com', password: 'secret');

          await _settle(tester);

          expect(find.byType(HomeScreen), findsOneWidget);

          // ---- Open the Attendance tab ----------------------------------
          await _openAttendanceTab(tester, harness.container);

          expect(
            harness.container.read(visibleHomeTabsProvider),
            contains(HomeTabItem.attendance),
          );

          expect(
            _attendanceCards(tester),
            findsWidgets,
            reason:
                'after logout -> login the Attendance tab must show the records '
                'without restarting the app',
          );
          expect(
            find.text('No attendance records found'),
            findsNothing,
            reason: 'the empty state must not be rendered after re-login',
          );
        },
      );
    }
  });
}

/// Advances the fake clock so pending `Future.delayed` timers (fake Firestore /
/// authorization latency) actually fire, then lets the tree settle.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }

  await tester.pumpAndSettle();
}

Finder _attendanceCards(WidgetTester tester) {
  return find.descendant(
    of: find.byType(AttendanceTab),
    matching: find.byType(AttendanceRecordCard),
  );
}

Future<void> _openAttendanceTab(
  WidgetTester tester,
  ProviderContainer container,
) async {
  container.read(currentHomeTabProvider.notifier).state =
      HomeTabItem.attendance;

  await _settle(tester);
}
