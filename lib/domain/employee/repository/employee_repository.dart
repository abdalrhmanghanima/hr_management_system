import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';

abstract class EmployeeRepository {
  Future<List<EmployeeEntity>> getEmployees();

  Future<EmployeeEntity> getEmployeeById(String id);

  Future<void> addEmployee(EmployeeEntity employee);

  Future<void> updateEmployee(EmployeeEntity employee);

  Future<void> deleteEmployee(String id);
}