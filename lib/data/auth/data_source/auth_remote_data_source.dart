import 'package:hr_management_system/data/auth/model/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
  Future<UserModel?> getUserByUid(String uid);
  Future<void> updateUserGroup({
    required String uid,
    required String employeeId,
    String? groupId,
  });
}
