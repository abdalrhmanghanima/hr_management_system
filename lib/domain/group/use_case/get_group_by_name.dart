import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/repository/group_repository.dart';

class GetGroupByName {
  final GroupRepository repository;

  GetGroupByName(this.repository);

  Future<GroupEntity?> call(String name, {String? excludingId}) {
    return repository.getGroupByName(name, excludingId: excludingId);
  }
}
