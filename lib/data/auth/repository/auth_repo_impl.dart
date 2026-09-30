import 'package:hr_management_system/data/auth/data_source/auth_remote_data_source.dart';
import 'package:hr_management_system/domain/auth/entity/user_entity.dart';
import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';

class AuthRepoImpl implements AuthRepo{
  final AuthRemoteDataSource authRemoteDataSource;
  AuthRepoImpl(this.authRemoteDataSource);
  @override
  Future<UserEntity> login({required String email, required String password}) {
    return authRemoteDataSource.login(email: email, password: password);
  }
  @override
  Future<void> logout() {
    return authRemoteDataSource.logout();
  }
  @override
  Future<UserEntity?> getUserByUid(String uid) {
    return authRemoteDataSource.getUserByUid(uid);
  }
  @override
  Future<void> updateUserGroup({
    required String uid,
    required String employeeId,
    String? groupId,
  }) {
    return authRemoteDataSource.updateUserGroup(
      uid: uid,
      employeeId: employeeId,
      groupId: groupId,
    );
  }
}
