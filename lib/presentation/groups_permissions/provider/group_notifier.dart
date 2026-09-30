import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/presentation/groups_permissions/provider/group_provider.dart';

class GroupNotifier extends AsyncNotifier<List<GroupEntity>> {
  @override
  Future<List<GroupEntity>> build() async {
    return ref.read(getGroupsUseCaseProvider).call();
  }

  Future<void> getGroups() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(getGroupsUseCaseProvider).call(),
    );
  }

  Future<SaveResult> addGroup(GroupEntity group) async {
    try {
      final existing = await ref
          .read(getGroupByNameUseCaseProvider)
          .call(group.name);

      if (existing != null) {
        return SaveResult.duplicate;
      }

      state = const AsyncLoading();

      await ref.read(addGroupUseCaseProvider).call(group);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return SaveResult.failure;
    }

    ref.invalidate(groupByIdProvider(group.id));
    await getGroups();

    return SaveResult.success;
  }

  Future<SaveResult> updateGroup(GroupEntity group) async {
    try {
      final existing = await ref
          .read(getGroupByNameUseCaseProvider)
          .call(group.name, excludingId: group.id);

      if (existing != null) {
        return SaveResult.duplicate;
      }

      state = const AsyncLoading();

      await ref.read(updateGroupUseCaseProvider).call(group);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return SaveResult.failure;
    }

    ref.invalidate(groupByIdProvider(group.id));
    await getGroups();

    return SaveResult.success;
  }

  Future<bool> deleteGroup(String id) async {
    try {
      await ref.read(deleteGroupUseCaseProvider).call(id);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return false;
    }

    ref.invalidate(groupByIdProvider(id));
    await getGroups();

    return true;
  }
}
