import 'package:hr_management_system/domain/group/entity/group_entity.dart';

abstract class GroupRepository {
  Future<List<GroupEntity>> getGroups();

  Future<GroupEntity?> getGroupById(String id);

  Future<GroupEntity?> getGroupByName(String name, {String? excludingId});

  Future<void> addGroup(GroupEntity group);

  Future<void> updateGroup(GroupEntity group);

  Future<void> deleteGroup(String id);

  Future<void> syncEmployeeUser(String employeeId);
}
