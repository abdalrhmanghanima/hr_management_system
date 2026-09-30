import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_management_system/data/group/model/group_permission_model.dart';
import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_permission_entity.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.name,
    super.description,
    super.employeeIds,
    super.permissions,
  });

  factory GroupModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final rawPermissions = data['permissions'];

    return GroupModel(
      id: document.id,
      name: (data['name'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      employeeIds: _stringList(data['employeeIds']),
      permissions: _permissions(rawPermissions),
    );
  }

  factory GroupModel.fromEntity(GroupEntity group) {
    return GroupModel(
      id: group.id,
      name: group.name,
      description: group.description,
      employeeIds: group.employeeIds,
      permissions: group.permissions,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'employeeIds': employeeIds,
      'permissions': permissions
          .map((key, value) => MapEntry(key, GroupPermissionModel.fromEntity(value).toFirestore())),
    };
  }

  GroupEntity toEntity() {
    return GroupEntity(
      id: id,
      name: name,
      description: description,
      employeeIds: employeeIds,
      permissions: permissions,
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<String>().toList();
  }

  static Map<String, GroupPermissionEntity> _permissions(dynamic raw) {
    if (raw is! Map) return const {};

    final result = <String, GroupPermissionEntity>{};
    raw.forEach((key, value) {
      if (key is! String) return;
      result[key] = GroupPermissionModel.fromFirestore(
        value is Map<String, dynamic> ? value : null,
      );
    });
    return result;
  }
}
