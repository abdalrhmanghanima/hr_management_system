import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/employee/repository/employee_repository.dart';

class GetEmployeeById {
  final EmployeeRepository repository;

  GetEmployeeById(this.repository);

  Future<EmployeeEntity> call(String id) {
    return repository.getEmployeeById(id);
  }
}