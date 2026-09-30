import 'package:hr_management_system/data/application_user/data_source/application_user_remote_data_source.dart';
import 'package:hr_management_system/data/application_user/model/application_user_model.dart';
import 'package:hr_management_system/domain/application_user/entity/application_user_entity.dart';
import 'package:hr_management_system/domain/application_user/repository/application_user_repository.dart';

class ApplicationUserRepositoryImpl implements ApplicationUserRepository {
  final ApplicationUserRemoteDataSource dataSource;

  ApplicationUserRepositoryImpl(this.dataSource);

  @override
  Future<List<ApplicationUserEntity>> getApplicationUsers() async {
    return dataSource.getApplicationUsers();
  }

  @override
  Future<ApplicationUserEntity?> getApplicationUserByUid(String uid) async {
    final applicationUser = await dataSource.getApplicationUserByUid(uid);

    return applicationUser;
  }

  @override
  Future<void> updateApplicationUser(
    ApplicationUserEntity applicationUser,
  ) async {
    await dataSource.updateApplicationUser(
      ApplicationUserModel.fromEntity(applicationUser),
    );
  }
}
