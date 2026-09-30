import 'package:hr_management_system/domain/application_user/entity/application_user_entity.dart';
import 'package:hr_management_system/domain/application_user/repository/application_user_repository.dart';

class UpdateApplicationUser {
  final ApplicationUserRepository repository;

  UpdateApplicationUser(this.repository);

  Future<void> call(ApplicationUserEntity applicationUser) {
    return repository.updateApplicationUser(applicationUser);
  }
}
