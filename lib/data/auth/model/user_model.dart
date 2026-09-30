import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_management_system/domain/auth/entity/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.employeeId,
    super.groupId,
    super.isActive,
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

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    return UserModel(
      uid: document.id,
      email: (data['email'] as String?) ?? '',
      employeeId: data['employeeId'] as String?,
      groupId: data['groupId'] as String?,
      isActive: (data['isActive'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'employeeId': employeeId,
      'groupId': groupId,
      'isActive': isActive,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      employeeId: employeeId,
      groupId: groupId,
      isActive: isActive,
    );
  }
}
