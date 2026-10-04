import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/payroll/provider/payroll_provider.dart';

class EmployeeNotifier extends AsyncNotifier<List<EmployeeEntity>> {
  @override
  Future<List<EmployeeEntity>> build() async {
    // TODO(hr-session-diagnostics): temporary debug logging.
    debugPrint('[hr-session] employeeProvider.initialize');

    return [];
  }

  bool _can(PermissionAction action) {
    return ref
        .read(permissionCheckerProvider)
        .authorization
        .isGranted(GroupModules.employees, action);
  }

  Future<void> getEmployees() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(getEmployeesUseCaseProvider).call(),
    );

    // TODO(hr-session-diagnostics): temporary debug logging.
    debugPrint('[hr-session] employee.getEmployees docs=${state.valueOrNull?.length} error=${state.hasError}');
  }

  Future<SaveResult> addEmployee(EmployeeEntity employee) async {
    if (!_can(PermissionAction.add)) {
      return SaveResult.failure;
    }

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

    ref.invalidate(payrollSummariesProvider);

    await getEmployees();

    return SaveResult.success;
  }

  Future<SaveResult> updateEmployee(EmployeeEntity employee) async {
    if (!_can(PermissionAction.edit)) {
      return SaveResult.failure;
    }

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

    ref.invalidate(payrollSummariesProvider);

    await getEmployees();

    return SaveResult.success;
  }

  Future<void> deleteEmployee(String id) async {
    if (!_can(PermissionAction.delete)) {
      return;
    }

    await ref.read(deleteEmployeeUseCaseProvider).call(id);

    ref.invalidate(payrollSummariesProvider);

    await getEmployees();
  }
}
