import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';

class EmployeeNotifier extends AsyncNotifier<List<EmployeeEntity>> {
  @override
  Future<List<EmployeeEntity>> build() async{
    return [];
  }
  Future<void> getEmployees() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(getEmployeesUseCaseProvider).call(),
    );
  }

  Future<void> addEmployee(EmployeeEntity employee) async {
    await ref.read(addEmployeeUseCaseProvider).call(employee);
    await getEmployees();
  }
  Future<void> updateEmployee(EmployeeEntity employee) async {
    await ref.read(updateEmployeeUseCaseProvider).call(employee);
    await getEmployees();
  }
  Future<void> deleteEmployee(String id) async {
    await ref.read(deleteEmployeeUseCaseProvider).call(id);
    await getEmployees();
  }
}
