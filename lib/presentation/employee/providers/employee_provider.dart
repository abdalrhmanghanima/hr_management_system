import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/employee/data_source/employee_remote_data_source.dart';
import 'package:hr_management_system/data/employee/data_source/employee_remote_data_source_impl.dart';
import 'package:hr_management_system/data/employee/repository/employee_repository_impl.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/employee/repository/employee_repository.dart';
import 'package:hr_management_system/domain/employee/use_case/add_employee.dart';
import 'package:hr_management_system/domain/employee/use_case/delete_employee.dart';
import 'package:hr_management_system/domain/employee/use_case/get_employee_by_id.dart';
import 'package:hr_management_system/domain/employee/use_case/get_employees.dart';
import 'package:hr_management_system/domain/employee/use_case/update_employee.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_notifier.dart';

final employeeProvider = AsyncNotifierProvider<EmployeeNotifier,List<EmployeeEntity>>(
  EmployeeNotifier.new
);

final employeeRemoteDataSourceProvider =
Provider<EmployeeRemoteDataSource>((ref) {
  return EmployeeRemoteDataSourceImpl(
    FirebaseFirestore.instance,
  );
});

final employeeRepositoryProvider =
Provider<EmployeeRepository>((ref) {
  return EmployeeRepositoryImpl(
    ref.read(employeeRemoteDataSourceProvider),
  );
});

final getEmployeesUseCaseProvider =
Provider<GetEmployees>((ref) {
  return GetEmployees(
    ref.read(employeeRepositoryProvider),
  );
});

final addEmployeeUseCaseProvider =
Provider<AddEmployee>((ref) {
  return AddEmployee(
    ref.read(employeeRepositoryProvider),
  );
});

final updateEmployeeUseCaseProvider =
Provider<UpdateEmployee>((ref) {
  return UpdateEmployee(
    ref.read(employeeRepositoryProvider),
  );
});

final deleteEmployeeUseCaseProvider =
Provider<DeleteEmployee>((ref) {
  return DeleteEmployee(
    ref.read(employeeRepositoryProvider),
  );
});

final getEmployeeByIdUseCaseProvider =
Provider<GetEmployeeById>((ref) {
  return GetEmployeeById(
    ref.read(employeeRepositoryProvider),
  );
});