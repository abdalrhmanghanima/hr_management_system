import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';

class DepartmentNotifier extends AsyncNotifier<List<DepartmentEntity>> {
  @override
  Future<List<DepartmentEntity>> build() async {
    return ref.read(getDepartmentsUseCaseProvider).call();
  }

  Future<void> getDepartments() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () => ref.read(getDepartmentsUseCaseProvider).call(),
    );
  }

  Future<void> addDepartment(DepartmentEntity department) async {
    await ref.read(addDepartmentUseCaseProvider).call(department);
    await getDepartments();
  }

  Future<void> updateDepartment(DepartmentEntity department) async {
    await ref.read(updateDepartmentUseCaseProvider).call(department);
    await getDepartments();
  }

  Future<void> deleteDepartment(String id) async {
    await ref.read(deleteDepartmentUseCaseProvider).call(id);
    await getDepartments();
  }
}