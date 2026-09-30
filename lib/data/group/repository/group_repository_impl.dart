import 'package:hr_management_system/data/group/data_source/group_remote_data_source.dart';
import 'package:hr_management_system/data/group/model/group_model.dart';
import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/employee/repository/employee_repository.dart';
import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/repository/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource dataSource;
  final EmployeeRepository employeeRepository;
  final AuthRepo authRepo;

  GroupRepositoryImpl({
    required this.dataSource,
    required this.employeeRepository,
    required this.authRepo,
  });

  @override
  Future<List<GroupEntity>> getGroups() async {
    final groups = await dataSource.getGroups();
    return groups.map((group) => group.toEntity()).toList();
  }

  @override
  Future<GroupEntity?> getGroupById(String id) async {
    final group = await dataSource.getGroupById(id);
    return group?.toEntity();
  }

  @override
  Future<GroupEntity?> getGroupByName(String name, {String? excludingId}) async {
    final group = await dataSource.getGroupByName(name, excludingId: excludingId);
    return group?.toEntity();
  }

  @override
  Future<void> addGroup(GroupEntity group) async {
    final existingGroups = await dataSource.getGroups();
    await dataSource.addGroup(GroupModel.fromEntity(group));
    await _detachMembersFromOtherGroups(group, existingGroups);
    await _syncUserLinks(
      _affectedBySave(group, existingGroups),
      await _ownersAfterSave(group, existingGroups),
    );
  }

  @override
  Future<void> updateGroup(GroupEntity group) async {
    final existingGroups = await dataSource.getGroups();
    await dataSource.updateGroup(GroupModel.fromEntity(group));
    await _detachMembersFromOtherGroups(group, existingGroups);
    await _syncUserLinks(
      _affectedBySave(group, existingGroups),
      await _ownersAfterSave(group, existingGroups),
    );
  }

  @override
  Future<void> deleteGroup(String id) async {
    final existingGroups = await dataSource.getGroups();
    await dataSource.deleteGroup(id);

    final ownerByEmployee = <String, String>{};
    final affected = <String>{};

    for (final group in existingGroups) {
      if (group.id == id) {
        affected.addAll(group.employeeIds);
        continue;
      }
      for (final employeeId in group.employeeIds) {
        ownerByEmployee[employeeId] = group.id;
        affected.add(employeeId);
      }
    }

    await _syncUserLinks(affected, ownerByEmployee);
  }

  @override
  Future<void> syncEmployeeUser(String employeeId) async {
    final groups = await dataSource.getGroups();

    String? groupId;
    for (final group in groups) {
      if (group.employeeIds.contains(employeeId)) {
        groupId = group.id;
        break;
      }
    }

    final employee = await employeeRepository.getEmployeeById(employeeId);
    final authUid = employee.authUid;
    if (authUid == null) return;

    await authRepo.updateUserGroup(
      uid: authUid,
      employeeId: employeeId,
      groupId: groupId,
    );
  }

  Set<String> _membersOf(GroupEntity group, List<GroupModel> existingGroups) {
    for (final existing in existingGroups) {
      if (existing.id == group.id) return existing.employeeIds.toSet();
    }
    return <String>{};
  }

  Set<String> _affectedBySave(GroupEntity group, List<GroupModel> existingGroups) {
    return group.employeeIds.toSet()..addAll(_membersOf(group, existingGroups));
  }

  Future<void> _detachMembersFromOtherGroups(
    GroupEntity group,
    List<GroupModel> existingGroups,
  ) async {
    final members = group.employeeIds.toSet();

    for (final existing in existingGroups) {
      if (existing.id == group.id) continue;
      final remaining = existing.employeeIds
          .where((employeeId) => !members.contains(employeeId))
          .toList();
      if (remaining.length == existing.employeeIds.length) continue;
      await dataSource.setGroupMembers(existing.id, remaining);
    }
  }

  Future<Map<String, String>> _ownersAfterSave(
    GroupEntity group,
    List<GroupModel> existingGroups,
  ) async {
    final members = group.employeeIds.toSet();
    final ownerByEmployee = <String, String>{};

    for (final existing in existingGroups) {
      if (existing.id == group.id) continue;
      for (final employeeId in existing.employeeIds) {
        if (members.contains(employeeId)) continue;
        ownerByEmployee[employeeId] = existing.id;
      }
    }

    for (final employeeId in members) {
      ownerByEmployee[employeeId] = group.id;
    }

    return ownerByEmployee;
  }

  Future<void> _syncUserLinks(
    Set<String> affectedIds,
    Map<String, String> ownerByEmployee,
  ) async {
    final employees = await employeeRepository.getEmployees();
    final employeeById = <String, EmployeeEntity>{
      for (final employee in employees) employee.id: employee,
    };

    for (final employeeId in affectedIds) {
      final authUid = employeeById[employeeId]?.authUid;
      if (authUid == null) continue;

      await authRepo.updateUserGroup(
        uid: authUid,
        employeeId: employeeId,
        groupId: ownerByEmployee[employeeId],
      );
    }
  }
}
