import 'package:hr_management_system/data/application_user/model/application_user_model.dart';

abstract class ApplicationUserRemoteDataSource {
  Future<List<ApplicationUserModel>> getApplicationUsers();

  Future<ApplicationUserModel?> getApplicationUserByUid(String uid);

  Future<void> updateApplicationUser(ApplicationUserModel applicationUser);
}
