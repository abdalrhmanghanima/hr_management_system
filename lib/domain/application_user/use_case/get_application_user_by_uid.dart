import 'package:hr_management_system/domain/application_user/entity/application_user_entity.dart';
import 'package:hr_management_system/domain/application_user/repository/application_user_repository.dart';

class GetApplicationUserByUid {
  final ApplicationUserRepository repository;

  GetApplicationUserByUid(this.repository);

  Future<ApplicationUserEntity?> call(String uid) {
    return repository.getApplicationUserByUid(uid);
  }
}
