import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';

class EmployeeNotifier extends AsyncNotifier<List<EmployeeEntity>> {
  @override
  Future<List<EmployeeEntity>> build() async {
    return [];
  }

  Future<void> getEmployees() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(getEmployeesUseCaseProvider).call(),
    );
  }

  Future<SaveResult> addEmployee(EmployeeEntity employee) async {
    try {
      final existing = await ref
          .read(getEmployeeByNationalIdUseCaseProvider)
          .call(employee.nationalId);

      if (existing != null) {
        return SaveResult.duplicate;
      }

      state = const AsyncLoading();

      await ref.read(addEmployeeUseCaseProvider).call(employee);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return SaveResult.failure;
    }

    await getEmployees();

    return SaveResult.success;
  }

  Future<SaveResult> updateEmployee(EmployeeEntity employee) async {
    try {
      final existing = await ref
          .read(getEmployeeByNationalIdUseCaseProvider)
          .call(employee.nationalId, excludingId: employee.id);

      if (existing != null) {
        return SaveResult.duplicate;
      }

      state = const AsyncLoading();

      await ref.read(updateEmployeeUseCaseProvider).call(employee);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return SaveResult.failure;
    }

    await getEmployees();

    return SaveResult.success;
  }

  Future<void> deleteEmployee(String id) async {
    await ref.read(deleteEmployeeUseCaseProvider).call(id);
    await getEmployees();
  }
}
