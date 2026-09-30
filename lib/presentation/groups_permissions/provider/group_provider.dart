import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/group/data_source/group_remote_data_source.dart';
import 'package:hr_management_system/data/group/data_source/group_remote_data_source_impl.dart';
import 'package:hr_management_system/data/group/repository/group_repository_impl.dart';
import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/repository/group_repository.dart';
import 'package:hr_management_system/domain/group/use_case/add_group.dart';
import 'package:hr_management_system/domain/group/use_case/delete_group.dart';
import 'package:hr_management_system/domain/group/use_case/get_group_by_id.dart';
import 'package:hr_management_system/domain/group/use_case/get_group_by_name.dart';
import 'package:hr_management_system/domain/group/use_case/get_groups.dart';
import 'package:hr_management_system/domain/group/use_case/sync_employee_user.dart';
import 'package:hr_management_system/domain/group/use_case/update_group.dart';
import 'package:hr_management_system/presentation/auth/providers/login_notifier.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/groups_permissions/provider/group_notifier.dart';

final groupProvider = AsyncNotifierProvider<GroupNotifier, List<GroupEntity>>(
  GroupNotifier.new,
);

final groupByIdProvider = FutureProvider.family<GroupEntity?, String>((
  ref,
  groupId,
) {
  return ref.read(getGroupByIdUseCaseProvider).call(groupId);
});

final groupRemoteDataSourceProvider = Provider<GroupRemoteDataSource>((ref) {
  return GroupRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepositoryImpl(
    dataSource: ref.read(groupRemoteDataSourceProvider),
    employeeRepository: ref.read(employeeRepositoryProvider),
    authRepo: ref.read(authRepoProvider),
  );
});

final getGroupsUseCaseProvider = Provider<GetGroups>((ref) {
  return GetGroups(ref.read(groupRepositoryProvider));
});

final getGroupByIdUseCaseProvider = Provider<GetGroupById>((ref) {
  return GetGroupById(ref.read(groupRepositoryProvider));
});

final getGroupByNameUseCaseProvider = Provider<GetGroupByName>((ref) {
  return GetGroupByName(ref.read(groupRepositoryProvider));
});

final addGroupUseCaseProvider = Provider<AddGroup>((ref) {
  return AddGroup(ref.read(groupRepositoryProvider));
});

final updateGroupUseCaseProvider = Provider<UpdateGroup>((ref) {
  return UpdateGroup(ref.read(groupRepositoryProvider));
});

final deleteGroupUseCaseProvider = Provider<DeleteGroup>((ref) {
  return DeleteGroup(ref.read(groupRepositoryProvider));
});

final syncEmployeeUserProvider = Provider<SyncEmployeeUser>((ref) {
  return SyncEmployeeUser(ref.read(groupRepositoryProvider));
});
