import 'package:hr_management_system/data/group/model/group_model.dart';

abstract class GroupRemoteDataSource {
  Future<List<GroupModel>> getGroups();

  Future<GroupModel?> getGroupById(String id);

  Future<GroupModel?> getGroupByName(String name, {String? excludingId});

  Future<void> addGroup(GroupModel group);

  Future<void> updateGroup(GroupModel group);

  Future<void> deleteGroup(String id);

  Future<void> setGroupMembers(String groupId, List<String> employeeIds);
}
