import 'package:hr_management_system/domain/auth/entity/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
  });

  factory UserModel.fromFirebaseUser({
    required String uid,
    required String email,
  }) {
    return UserModel(
      uid: uid,
      email: email,
    );
  }
}