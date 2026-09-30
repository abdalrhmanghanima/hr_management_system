import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/repository/group_repository.dart';

class GetGroupById {
  final GroupRepository repository;

  GetGroupById(this.repository);

  Future<GroupEntity?> call(String id) {
    return repository.getGroupById(id);
  }
}
