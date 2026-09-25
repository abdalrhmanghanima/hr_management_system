import 'package:hr_management_system/domain/employee/repository/employee_repository.dart';

class DeleteEmployee {
  final EmployeeRepository repository;

  DeleteEmployee(this.repository);

  Future<void> call(String id) {
    return repository.deleteEmployee(id);
  }
}