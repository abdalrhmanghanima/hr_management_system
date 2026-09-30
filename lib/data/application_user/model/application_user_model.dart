import 'package:hr_management_system/domain/application_user/entity/application_user_entity.dart';

class ApplicationUserModel extends ApplicationUserEntity {
  const ApplicationUserModel({
    required super.id,
    required super.employeeId,
    super.email,
    super.groupId,
    super.isActive,
  });

  factory ApplicationUserModel.fromMap(String id, Map<String, dynamic> data) {
    return ApplicationUserModel(
      id: id,
      employeeId: _readString(data['employeeId']) ?? '',
      email: _readString(data['email']) ?? '',
      groupId: _readString(data['groupId']),
      isActive: _readBool(data['isActive']) ?? true,
    );
  }

  static String? _readString(Object? value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    return null;
  }

  static bool? _readBool(Object? value) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }

    return null;
  }

  factory ApplicationUserModel.fromEntity(ApplicationUserEntity user) {
    return ApplicationUserModel(
      id: user.id,
      employeeId: user.employeeId,
      email: user.email,
      groupId: user.groupId,
      isActive: user.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'employeeId': employeeId,
      'email': email,
      'groupId': groupId,
      'isActive': isActive,
    };
  }
}
