import 'package:hr_management_system/data/employee/model/employee_model.dart';

abstract class EmployeeRemoteDataSource {
  Future<List<EmployeeModel>> getEmployees();

  Future<EmployeeModel> getEmployeeById(String id);

  Future<void> addEmployee(EmployeeModel employee);

  Future<void> updateEmployee(EmployeeModel employee);

  Future<void> deleteEmployee(String id);
}