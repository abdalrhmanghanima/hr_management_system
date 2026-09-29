import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/employee/repository/employee_repository.dart';

class GetEmployeeByNationalId {
  final EmployeeRepository repository;

  GetEmployeeByNationalId(this.repository);

  Future<EmployeeEntity?> call(String nationalId, {String? excludingId}) {
    return repository.getEmployeeByNationalId(
      nationalId,
      excludingId: excludingId,
    );
  }
}
