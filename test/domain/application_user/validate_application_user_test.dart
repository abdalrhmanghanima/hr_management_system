import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/domain/application_user/entity/application_user_entity.dart';
import 'package:hr_management_system/domain/application_user/entity/application_user_exception.dart';
import 'package:hr_management_system/domain/application_user/repository/application_user_repository.dart';
import 'package:hr_management_system/domain/application_user/use_case/validate_application_user.dart';
import 'package:hr_management_system/domain/auth/entity/user_entity.dart';
import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';

class _FakeApplicationUserRepository implements ApplicationUserRepository {
  _FakeApplicationUserRepository(this.applicationUser);

  final ApplicationUserEntity? applicationUser;

  int lookupCount = 0;

  @override
  Future<ApplicationUserEntity?> getApplicationUserByUid(String uid) async {
    lookupCount++;
    return applicationUser;
  }

  @override
  Future<List<ApplicationUserEntity>> getApplicationUsers() async =>
      applicationUser == null ? const [] : [applicationUser!];

  @override
  Future<void> updateApplicationUser(ApplicationUserEntity applicationUser) {
    throw UnimplementedError();
  }
}

class _FakeAuthRepo implements AuthRepo {
  int logoutCallCount = 0;
  bool shouldFailOnLogout = false;

  @override
  Future<void> logout() async {
    logoutCallCount++;

    if (shouldFailOnLogout) {
      throw Exception('sign out failed');
    }
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity?> getUserByUid(String uid) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateUserGroup({
    required String uid,
    required String employeeId,
    String? groupId,
  }) {
    throw UnimplementedError();
  }
}

const _activeUser = ApplicationUserEntity(
  id: 'uid-1',
  employeeId: 'EMP-1',
  email: 'pioneershr@gmail.com',
  groupId: 'group-hr',
);

const _inactiveUser = ApplicationUserEntity(
  id: 'uid-1',
  employeeId: 'EMP-1',
  email: 'pioneershr@gmail.com',
  groupId: 'group-hr',
  isActive: false,
);

void main() {
  group('ValidateApplicationUser', () {
    test('accepts an existing active application user', () async {
      final repository = _FakeApplicationUserRepository(_activeUser);
      final authRepo = _FakeAuthRepo();

      final result = await ValidateApplicationUser(
        repository,
        authRepo,
      ).call('uid-1');

      expect(result.employeeId, 'EMP-1');
      expect(result.groupId, 'group-hr');
      expect(result.isActive, isTrue);
      expect(authRepo.logoutCallCount, 0);
      expect(repository.lookupCount, 1);
    });

    test('rejects a signed in user without an application user', () async {
      final repository = _FakeApplicationUserRepository(null);
      final authRepo = _FakeAuthRepo();

      await expectLater(
        ValidateApplicationUser(repository, authRepo).call('uid-1'),
        throwsA(
          isA<ApplicationUserException>().having(
            (error) => error.messageKey,
            'messageKey',
            'auth.error_account_not_linked',
          ),
        ),
      );

      expect(authRepo.logoutCallCount, 1);
    });

    test('rejects an inactive application user and signs out', () async {
      final repository = _FakeApplicationUserRepository(_inactiveUser);
      final authRepo = _FakeAuthRepo();

      await expectLater(
        ValidateApplicationUser(repository, authRepo).call('uid-1'),
        throwsA(
          isA<ApplicationUserException>().having(
            (error) => error.messageKey,
            'messageKey',
            'auth.error_account_inactive',
          ),
        ),
      );

      expect(authRepo.logoutCallCount, 1);
    });

    test('rejects an empty uid without reading firestore', () async {
      final repository = _FakeApplicationUserRepository(_activeUser);
      final authRepo = _FakeAuthRepo();

      await expectLater(
        ValidateApplicationUser(repository, authRepo).call(''),
        throwsA(isA<ApplicationUserException>()),
      );

      expect(repository.lookupCount, 0);
      expect(authRepo.logoutCallCount, 1);
    });

    test('still reports the validation failure when sign out fails', () async {
      final repository = _FakeApplicationUserRepository(_inactiveUser);
      final authRepo = _FakeAuthRepo()..shouldFailOnLogout = true;

      await expectLater(
        ValidateApplicationUser(repository, authRepo).call('uid-1'),
        throwsA(
          isA<ApplicationUserException>().having(
            (error) => error.messageKey,
            'messageKey',
            'auth.error_account_inactive',
          ),
        ),
      );
    });
  });
}
