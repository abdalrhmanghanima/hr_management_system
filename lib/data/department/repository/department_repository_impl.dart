import 'package:hr_management_system/data/department/data_source/department_remote_data_source.dart';
import 'package:hr_management_system/data/department/model/department_model.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/domain/department/repository/department_repository.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final DepartmentRemoteDataSource dataSource;

  DepartmentRepositoryImpl(this.dataSource);

  @override
  Future<List<DepartmentEntity>> getDepartments() {
    return dataSource.getDepartments();
  }

  @override
  Future<DepartmentEntity> getDepartmentById(String id) {
    return dataSource.getDepartmentById(id);
  }

  @override
  Future<void> addDepartment(DepartmentEntity department) {
    final model = DepartmentModel.fromEntity(department);

    return dataSource.addDepartment(model);
  }

  @override
  Future<void> updateDepartment(DepartmentEntity department) {
    final model = DepartmentModel.fromEntity(department);

    return dataSource.updateDepartment(model);
  }

  @override
  Future<void> deleteDepartment(String id) {
    return dataSource.deleteDepartment(id);
  }
}