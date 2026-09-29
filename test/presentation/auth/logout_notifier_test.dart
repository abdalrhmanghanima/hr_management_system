import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/domain/auth/entity/user_entity.dart';
import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/employee/repository/employee_repository.dart';
import 'package:hr_management_system/injection.dart';
import 'package:hr_management_system/presentation/auth/providers/login_notifier.dart';
import 'package:hr_management_system/presentation/auth/providers/logout_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRepo implements AuthRepo {
  FakeAuthRepo({this.shouldFail = false, this.gate});

  final bool shouldFail;
  final Completer<void>? gate;

  int logoutCallCount = 0;

  @override
  Future<UserEntity> login({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    logoutCallCount++;

    if (gate != null) {
      await gate!.future;
    }

    if (shouldFail) {
      throw Exception('sign out failed');
    }
  }
}

class FakeEmployeeRepository implements EmployeeRepository {
  FakeEmployeeRepository(this.employees);

  List<EmployeeEntity> employees;

  @override
  Future<List<EmployeeEntity>> getEmployees() async => employees;

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
}

EmployeeEntity buildEmployee(String id) {
  return EmployeeEntity(
    id: id,
    fullName: 'Employee $id',
    address: 'Address',
    phoneNumber: '01000000000',
    birthDate: DateTime(1990),
    nationalId: '0000000000000$id',
    nationality: 'Egyptian',
    gender: 'Male',
    departmentId: 'department-1',
    contractDate: DateTime(2020),
    salary: 1000,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('logout flow', () {
    test('runs the existing sign out use case and reports success', () async {
      final authRepo = FakeAuthRepo();

      final container = ProviderContainer(
        overrides: [authRepoProvider.overrideWithValue(authRepo)],
      );
      addTearDown(container.dispose);

      await container.read(logoutProvider.future);
      await container.read(logoutProvider.notifier).logout();

      expect(authRepo.logoutCallCount, 1);
      expect(container.read(logoutProvider).hasError, isFalse);
    });

    test('clears user scoped providers and local user storage', () async {
      SharedPreferences.setMockInitialValues({
        'user': 'cached user',
        'firebaseToken': 'cached token',
        'chatNotificationData': 'cached notifications',
        'isDarkMode': true,
      });

      final preferences = await SharedPreferences.getInstance();
      getIt.registerSingleton<SharedPreferences>(preferences);
      addTearDown(getIt.reset);

      final employeeRepo = FakeEmployeeRepository([buildEmployee('1')]);

      final container = ProviderContainer(
        overrides: [
          authRepoProvider.overrideWithValue(FakeAuthRepo()),
          employeeRepositoryProvider.overrideWithValue(employeeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(employeeProvider.notifier).getEmployees();

      expect(container.read(employeeProvider).value, hasLength(1));

      await container.read(logoutProvider.future);
      await container.read(logoutProvider.notifier).logout();

      expect(await container.read(employeeProvider.future), isEmpty);

      employeeRepo.employees = [buildEmployee('2')];

      await container.read(employeeProvider.notifier).getEmployees();

      final employees = container.read(employeeProvider).value!;

      expect(employees.map((employee) => employee.id), ['2']);
      expect(employees.map((employee) => employee.id), isNot(contains('1')));

      await pumpEventQueue();

      expect(preferences.getString('user'), isNull);
      expect(preferences.getString('firebaseToken'), isNull);
      expect(preferences.getString('chatNotificationData'), isNull);
      expect(preferences.getBool('isDarkMode'), isTrue);
    });

    test('failed logout keeps the session data untouched', () async {
      SharedPreferences.setMockInitialValues({
        'user': 'cached user',
        'firebaseToken': 'cached token',
        'chatNotificationData': 'cached notifications',
      });

      final preferences = await SharedPreferences.getInstance();
      getIt.registerSingleton<SharedPreferences>(preferences);
      addTearDown(getIt.reset);

      final employeeRepo = FakeEmployeeRepository([buildEmployee('1')]);

      final container = ProviderContainer(
        overrides: [
          authRepoProvider.overrideWithValue(FakeAuthRepo(shouldFail: true)),
          employeeRepositoryProvider.overrideWithValue(employeeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(employeeProvider.notifier).getEmployees();

      await container.read(logoutProvider.future);
      await container.read(logoutProvider.notifier).logout();

      expect(container.read(logoutProvider).hasError, isTrue);
      expect(container.read(employeeProvider).value, hasLength(1));
      expect(container.read(employeeProvider).value!.first.id, '1');

      await pumpEventQueue();

      expect(preferences.getString('user'), 'cached user');
      expect(preferences.getString('firebaseToken'), 'cached token');
      expect(
        preferences.getString('chatNotificationData'),
        'cached notifications',
      );
    });

    test('repeated calls trigger a single sign out request', () async {
      final gate = Completer<void>();
      final authRepo = FakeAuthRepo(gate: gate);

      final container = ProviderContainer(
        overrides: [authRepoProvider.overrideWithValue(authRepo)],
      );
      addTearDown(container.dispose);

      await container.read(logoutProvider.future);
      final notifier = container.read(logoutProvider.notifier);

      final firstCall = notifier.logout();
      final secondCall = notifier.logout();

      expect(container.read(logoutProvider).isLoading, isTrue);

      gate.complete();

      await Future.wait([firstCall, secondCall]);

      expect(authRepo.logoutCallCount, 1);
      expect(container.read(logoutProvider).hasError, isFalse);
    });
  });
}
