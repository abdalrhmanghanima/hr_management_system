import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';

class DepartmentNotifier extends AsyncNotifier<List<DepartmentEntity>> {
  @override
  Future<List<DepartmentEntity>> build() async {
    return ref.read(getDepartmentsUseCaseProvider).call();
  }

  bool _can(PermissionAction action) {
    return ref
        .read(permissionCheckerProvider)
        .authorization
        .isGranted(GroupModules.departments, action);
  }

  Future<void> getDepartments() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(getDepartmentsUseCaseProvider).call(),
    );
  }

  Future<SaveResult> addDepartment(DepartmentEntity department) async {
    if (!_can(PermissionAction.add)) {
      return SaveResult.failure;
    }

    try {
      final existing = await ref
          .read(getDepartmentByNameUseCaseProvider)
          .call(department.name);

      if (existing != null) {
        return SaveResult.duplicate;
      }

      state = const AsyncLoading();

      await ref.read(addDepartmentUseCaseProvider).call(department);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return SaveResult.failure;
    }

    await getDepartments();

    return SaveResult.success;
  }

  Future<SaveResult> updateDepartment(DepartmentEntity department) async {
    if (!_can(PermissionAction.edit)) {
      return SaveResult.failure;
    }

    try {
      final existing = await ref
          .read(getDepartmentByNameUseCaseProvider)
          .call(department.name, excludingId: department.id);

      if (existing != null) {
        return SaveResult.duplicate;
      }

      state = const AsyncLoading();

      await ref.read(updateDepartmentUseCaseProvider).call(department);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return SaveResult.failure;
    }

    await getDepartments();

    return SaveResult.success;
  }

  Future<void> deleteDepartment(String id) async {
    if (!_can(PermissionAction.delete)) {
      return;
    }

    await ref.read(deleteDepartmentUseCaseProvider).call(id);
    await getDepartments();
  }
}
