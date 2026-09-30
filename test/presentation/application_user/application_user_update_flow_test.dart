import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/data/application_user/data_source/application_user_remote_data_source.dart';
import 'package:hr_management_system/data/application_user/model/application_user_model.dart';
import 'package:hr_management_system/data/application_user/repository/application_user_repository_impl.dart';
import 'package:hr_management_system/domain/auth/entity/user_entity.dart';
import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';
import 'package:hr_management_system/presentation/application_user/provider/application_user_provider.dart';
import 'package:hr_management_system/presentation/auth/providers/login_notifier.dart';
import 'package:hr_management_system/presentation/auth/providers/login_provider.dart';

class _FakeApplicationUserRemoteDataSource
    implements ApplicationUserRemoteDataSource {
  _FakeApplicationUserRemoteDataSource(this.stored);

  final List<ApplicationUserModel> stored;

  bool failNextUpdate = false;

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
  ) async {
    if (failNextUpdate) {
      throw StateError('write rejected');
    }

    for (var index = 0; index < stored.length; index++) {
      if (stored[index].id == applicationUser.id) {
        stored[index] = applicationUser;
        return;
      }
    }
  }
}

class _FakeAuthRepo implements AuthRepo {
  int signOutCount = 0;

  @override
  Future<UserEntity> login({required String email, required String password}) async {
    return const UserEntity(uid: 'uid-hr', email: 'pioneershr@gmail.com');
  }

  @override
  Future<void> logout() async {
    signOutCount++;
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

void main() {
  late _FakeApplicationUserRemoteDataSource dataSource;
  late _FakeAuthRepo authRepo;
  late ProviderContainer container;

  const hrUser = ApplicationUserModel(
    id: 'uid-hr',
    employeeId: 'EMP999',
    email: 'pioneershr@gmail.com',
    groupId: 'management',
    isActive: true,
  );

  setUp(() {
    dataSource = _FakeApplicationUserRemoteDataSource([hrUser]);
    authRepo = _FakeAuthRepo();

    container = ProviderContainer(
      overrides: [
        applicationUserRepositoryProvider.overrideWith(
          (ref) => ApplicationUserRepositoryImpl(dataSource),
        ),
        authRepoProvider.overrideWithValue(authRepo),
      ],
    );
    addTearDown(container.dispose);
  });

  test('the existing HR user is listed with its employee, group and active state', () async {
    final users = await container.read(applicationUserProvider.future);

    expect(users, hasLength(1));
    expect(users.single.id, 'uid-hr');
    expect(users.single.employeeId, 'EMP999');
    expect(users.single.email, 'pioneershr@gmail.com');
    expect(users.single.groupId, 'management');
    expect(users.single.isActive, isTrue);
  });

  test('deactivating a user keeps the current HR session', () async {
    await container.read(loginProvider.future);
    await container
        .read(loginProvider.notifier)
        .login(email: 'pioneershr@gmail.com', password: 'Secret123');

    expect(container.read(loginProvider).value?.uid, 'uid-hr');

    final result = await container
        .read(applicationUserOperationProvider.notifier)
        .setApplicationUserActive(hrUser, false);

    expect(result, SaveResult.success);
    expect(dataSource.stored.single.isActive, isFalse);

    expect(authRepo.signOutCount, 0);
    expect(container.read(loginProvider).hasError, isFalse);
    expect(container.read(loginProvider).value?.uid, 'uid-hr');
  });

  test('a failed update is reported without breaking the loaded list', () async {
    final loadedUsers = await container.read(applicationUserProvider.future);

    expect(loadedUsers.single.id, 'uid-hr');

    dataSource.failNextUpdate = true;

    final result = await container
        .read(applicationUserOperationProvider.notifier)
        .updateApplicationUser(
          hrUser.copyWith(groupId: 'group-finance', clearGroup: false),
        );

    expect(result, SaveResult.failure);
    expect(container.read(applicationUserOperationProvider).hasError, isTrue);

    expect(container.read(applicationUserProvider).hasError, isFalse);
    expect(
      container.read(applicationUserProvider).value?.single.id,
      'uid-hr',
    );
  });
}
