import 'package:hr_management_system/data/employee/data_source/employee_remote_data_source.dart';
import 'package:hr_management_system/data/employee/model/employee_model.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/employee/repository/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource dataSource;

  EmployeeRepositoryImpl(this.dataSource);

  @override
  Future<List<EmployeeEntity>> getEmployees() {
    return dataSource.getEmployees();
  }

  @override
  Future<EmployeeEntity> getEmployeeById(String id) {
    return dataSource.getEmployeeById(id);
  }

  @override
  Future<void> addEmployee(EmployeeEntity employee) {
    final model = EmployeeModel.fromEntity(employee);
    return dataSource.addEmployee(model);
  }

  @override
  Future<void> updateEmployee(EmployeeEntity employee) {
    final model = EmployeeModel.fromEntity(employee);
    return dataSource.updateEmployee(model);
  }

  @override
  Future<void> deleteEmployee(String id) {
    return dataSource.deleteEmployee(id);
  }
}