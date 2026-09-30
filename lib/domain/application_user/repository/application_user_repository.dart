import 'package:hr_management_system/domain/application_user/entity/application_user_entity.dart';

abstract class ApplicationUserRepository {
  Future<List<ApplicationUserEntity>> getApplicationUsers();

  Future<ApplicationUserEntity?> getApplicationUserByUid(String uid);

  Future<void> updateApplicationUser(ApplicationUserEntity applicationUser);
}
