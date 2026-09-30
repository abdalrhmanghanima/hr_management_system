import 'package:hr_management_system/domain/application_user/entity/application_user_entity.dart';
import 'package:hr_management_system/domain/application_user/repository/application_user_repository.dart';

class GetApplicationUsers {
  final ApplicationUserRepository repository;

  GetApplicationUsers(this.repository);

  Future<List<ApplicationUserEntity>> call() {
    return repository.getApplicationUsers();
  }
}
