import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/domain/department/repository/department_repository.dart';

class GetDepartmentByName {
  final DepartmentRepository repository;

  GetDepartmentByName(this.repository);

  Future<DepartmentEntity?> call(String name, {String? excludingId}) {
    return repository.getDepartmentByName(name, excludingId: excludingId);
  }
}
