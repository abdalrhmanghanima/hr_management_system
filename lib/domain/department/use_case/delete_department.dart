import 'package:hr_management_system/domain/department/repository/department_repository.dart';

class DeleteDepartment {
  final DepartmentRepository repository;

  DeleteDepartment(this.repository);

  Future<void> call(String id) {
    return repository.deleteDepartment(id);
  }
}