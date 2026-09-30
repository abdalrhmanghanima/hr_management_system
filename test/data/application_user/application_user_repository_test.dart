import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/data/application_user/data_source/application_user_remote_data_source.dart';
import 'package:hr_management_system/data/application_user/model/application_user_model.dart';
import 'package:hr_management_system/data/application_user/repository/application_user_repository_impl.dart';

class _FakeApplicationUserRemoteDataSource
    implements ApplicationUserRemoteDataSource {
  final List<ApplicationUserModel> stored = [];

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
    for (var index = 0; index < stored.length; index++) {
      if (stored[index].id == applicationUser.id) {
        stored[index] = applicationUser;
        return;
      }
    }
  }
}

void main() {
  group('ApplicationUserRepositoryImpl.getApplicationUsers', () {
    test('returns the stored users documents', () async {
      final dataSource = _FakeApplicationUserRemoteDataSource();
      final repository = ApplicationUserRepositoryImpl(dataSource);

      dataSource.stored.add(
        const ApplicationUserModel(
          id: 'uid-hr',
          employeeId: 'EMP999',
          email: 'pioneershr@gmail.com',
          groupId: 'management',
        ),
      );

      final users = await repository.getApplicationUsers();

      expect(users, hasLength(1));
      expect(users.single.id, 'uid-hr');
      expect(users.single.employeeId, 'EMP999');
      expect(users.single.groupId, 'management');
    });
  });

  group('ApplicationUserRepositoryImpl.getApplicationUserByUid', () {
    test('returns the matching user document', () async {
      final dataSource = _FakeApplicationUserRemoteDataSource();
      final repository = ApplicationUserRepositoryImpl(dataSource);

      dataSource.stored.add(
        const ApplicationUserModel(
          id: 'uid-hr',
          employeeId: 'EMP999',
          email: 'pioneershr@gmail.com',
          groupId: 'management',
        ),
      );

      final user = await repository.getApplicationUserByUid('uid-hr');

      expect(user?.employeeId, 'EMP999');
      expect(user?.isActive, isTrue);
    });

    test('returns null when no user document exists for the uid', () async {
      final repository = ApplicationUserRepositoryImpl(
        _FakeApplicationUserRemoteDataSource(),
      );

      expect(await repository.getApplicationUserByUid('uid-missing'), isNull);
    });
  });

  group('ApplicationUserRepositoryImpl.updateApplicationUser', () {
    test('persists group and active state without a password field', () async {
      final dataSource = _FakeApplicationUserRemoteDataSource();
      final repository = ApplicationUserRepositoryImpl(dataSource);

      dataSource.stored.add(
        const ApplicationUserModel(
          id: 'uid-hr',
          employeeId: 'EMP999',
          email: 'pioneershr@gmail.com',
          groupId: 'management',
        ),
      );

      final stored = dataSource.stored.single;

      await repository.updateApplicationUser(
        stored.copyWith(isActive: false, groupId: 'group-finance'),
      );

      final updated = dataSource.stored.single;

      expect(updated.isActive, isFalse);
      expect(updated.groupId, 'group-finance');
      expect(updated.employeeId, 'EMP999');
      expect(
        updated.toMap().keys.any(
          (field) => field.toLowerCase().contains('password'),
        ),
        isFalse,
      );
    });
  });

  group('ApplicationUserModel', () {
    test('reads a users document and defaults isActive to true', () {
      final model = ApplicationUserModel.fromMap('uid-1', {
        'employeeId': 'EMP-1',
        'email': 'user@pioneers.com',
        'groupId': 'group-hr',
      });

      expect(model.id, 'uid-1');
      expect(model.employeeId, 'EMP-1');
      expect(model.email, 'user@pioneers.com');
      expect(model.groupId, 'group-hr');
      expect(model.isActive, isTrue);
    });

    test('keeps a null group as no group', () {
      final model = ApplicationUserModel.fromMap('uid-2', {
        'employeeId': 'EMP-2',
        'email': 'user2@pioneers.com',
        'groupId': null,
        'isActive': false,
      });

      expect(model.hasGroup, isFalse);
      expect(model.isActive, isFalse);
    });
  });
}
