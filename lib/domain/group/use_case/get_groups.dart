import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/repository/group_repository.dart';

class GetGroups {
  final GroupRepository repository;

  GetGroups(this.repository);

  Future<List<GroupEntity>> call() {
    return repository.getGroups();
  }
}
