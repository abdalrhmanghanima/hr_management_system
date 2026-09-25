import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/domain/department/repository/department_repository.dart';

class AddDepartment {
  final DepartmentRepository repository;

  AddDepartment(this.repository);

  Future<void> call(DepartmentEntity department) {
    return repository.addDepartment(department);
  }
}