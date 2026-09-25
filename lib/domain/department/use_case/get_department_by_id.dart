import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/domain/department/repository/department_repository.dart';

class GetDepartmentById {
  final DepartmentRepository repository;

  GetDepartmentById(this.repository);

  Future<DepartmentEntity> call(String id) {
    return repository.getDepartmentById(id);
  }
}