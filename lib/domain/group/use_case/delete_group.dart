import 'package:hr_management_system/domain/group/repository/group_repository.dart';

class DeleteGroup {
  final GroupRepository repository;

  DeleteGroup(this.repository);

  Future<void> call(String id) {
    return repository.deleteGroup(id);
  }
}
