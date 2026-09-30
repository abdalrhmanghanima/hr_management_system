import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/repository/group_repository.dart';

class UpdateGroup {
  final GroupRepository repository;

  UpdateGroup(this.repository);

  Future<void> call(GroupEntity group) {
    return repository.updateGroup(group);
  }
}
