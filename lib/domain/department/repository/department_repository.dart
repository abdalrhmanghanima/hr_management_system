import 'package:hr_management_system/domain/department/entity/department_entity.dart';

abstract class DepartmentRepository {
  Future<List<DepartmentEntity>> getDepartments();

  Future<DepartmentEntity> getDepartmentById(String id);

  Future<void> addDepartment(DepartmentEntity department);

  Future<void> updateDepartment(DepartmentEntity department);

  Future<void> deleteDepartment(String id);
}