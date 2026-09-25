import 'package:hr_management_system/data/department/model/department_model.dart';

abstract class DepartmentRemoteDataSource {
  Future<List<DepartmentModel>> getDepartments();

  Future<DepartmentModel> getDepartmentById(String id);

  Future<void> addDepartment(DepartmentModel department);

  Future<void> updateDepartment(DepartmentModel department);

  Future<void> deleteDepartment(String id);
}