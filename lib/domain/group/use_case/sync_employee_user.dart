import 'package:hr_management_system/domain/group/repository/group_repository.dart';

class SyncEmployeeUser {
  final GroupRepository repository;

  SyncEmployeeUser(this.repository);

  Future<void> call(String employeeId) {
    return repository.syncEmployeeUser(employeeId);
  }
}
