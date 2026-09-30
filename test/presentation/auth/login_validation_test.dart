import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/data/application_user/data_source/application_user_remote_data_source.dart';
import 'package:hr_management_system/data/application_user/model/application_user_model.dart';
import 'package:hr_management_system/data/application_user/repository/application_user_repository_impl.dart';
import 'package:hr_management_system/domain/application_user/entity/application_user_exception.dart';
import 'package:hr_management_system/domain/auth/entity/user_entity.dart';
import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';
import 'package:hr_management_system/presentation/application_user/provider/application_user_provider.dart';
import 'package:hr_management_system/presentation/auth/providers/login_notifier.dart';
import 'package:hr_management_system/presentation/auth/providers/login_provider.dart';

class _FakeAuthRepo implements AuthRepo {
  int logoutCallCount = 0;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    return UserEntity(uid: 'uid-1', email: email);
  }

  @override
  Future<void> logout() async {
    logoutCallCount++;
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

class _FakeApplicationUserRemoteDataSource
    implements ApplicationUserRemoteDataSource {
  _FakeApplicationUserRemoteDataSource(this.stored);

  final List<ApplicationUserModel> stored;

  @override
  Future<List<ApplicationUserModel>> getApplicationUsers() async => stored;

  @override
  Future<ApplicationUserModel?> getApplicationUserByUid(String uid) async {
    for (final applicationUser in stored) {
      if (applicationUser.id == uid) {
        return applicationUser;
      }
    }
    return null;
  }

  @override
  Future<void> updateApplicationUser(
    ApplicationUserModel applicationUser,
  ) {
    throw UnimplementedError();
  }
}

ProviderContainer _buildContainer(List<ApplicationUserModel> stored) {
  final authRepo = _FakeAuthRepo();

  return ProviderContainer(
    overrides: [
      authRepoProvider.overrideWithValue(authRepo),
      applicationUserRepositoryProvider.overrideWith(
        (ref) => ApplicationUserRepositoryImpl(
          _FakeApplicationUserRemoteDataSource(stored),
        ),
      ),
    ],
  );
}

void main() {
  group('login validation', () {
    test('signs in when the application user exists and is active', () async {
      final authRepo = _FakeAuthRepo();

      final container = ProviderContainer(
        overrides: [
          authRepoProvider.overrideWithValue(authRepo),
          applicationUserRepositoryProvider.overrideWith(
            (ref) => ApplicationUserRepositoryImpl(
              _FakeApplicationUserRemoteDataSource(const [
                ApplicationUserModel(
                  id: 'uid-1',
                  employeeId: 'EMP-1',
                  email: 'pioneershr@gmail.com',
                  groupId: 'group-hr',
                ),
              ]),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(loginProvider.future);

      await container
          .read(loginProvider.notifier)
          .login(email: 'pioneershr@gmail.com', password: 'Secret123');

      final state = container.read(loginProvider);

      expect(state.hasError, isFalse);
      expect(state.value?.uid, 'uid-1');
      expect(authRepo.logoutCallCount, 0);
    });

    test('signs out when there is no application user', () async {
      final container = _buildContainer(const []);
      addTearDown(container.dispose);

      await container.read(loginProvider.future);

      await container
          .read(loginProvider.notifier)
          .login(email: 'pioneershr@gmail.com', password: 'Secret123');

      final state = container.read(loginProvider);

      expect(state.hasError, isTrue);
      expect(state.error, isA<ApplicationUserException>());
      expect(state.value, isNull);
    });

    test('signs out when the application user is inactive', () async {
      final container = _buildContainer(const [
        ApplicationUserModel(
          id: 'uid-1',
          employeeId: 'EMP-1',
          email: 'pioneershr@gmail.com',
          groupId: 'group-hr',
          isActive: false,
        ),
      ]);
      addTearDown(container.dispose);

      await container.read(loginProvider.future);

      await container
          .read(loginProvider.notifier)
          .login(email: 'pioneershr@gmail.com', password: 'Secret123');

      final state = container.read(loginProvider);

      expect(state.hasError, isTrue);
      expect(
        (state.error! as ApplicationUserException).messageKey,
        'auth.error_account_inactive',
      );
      expect(state.value, isNull);
    });
  });
}
