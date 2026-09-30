import 'package:hr_management_system/domain/auth/entity/user_entity.dart';

abstract class AuthRepo {
  Future<UserEntity> login({required String email, required String password});
  Future<void> logout();
  Future<UserEntity?> getUserByUid(String uid);
  Future<void> updateUserGroup({
    required String uid,
    required String employeeId,
    String? groupId,
  });
}
