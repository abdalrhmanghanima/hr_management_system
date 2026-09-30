import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/repository/group_repository.dart';

class AddGroup {
  final GroupRepository repository;

  AddGroup(this.repository);

  Future<void> call(GroupEntity group) {
    return repository.addGroup(group);
  }
}
