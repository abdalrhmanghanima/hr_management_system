import 'package:hr_management_system/domain/application_user/entity/application_user_entity.dart';
import 'package:hr_management_system/domain/application_user/entity/application_user_exception.dart';
import 'package:hr_management_system/domain/application_user/repository/application_user_repository.dart';
import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';

class ValidateApplicationUser {
  final ApplicationUserRepository repository;
  final AuthRepo authRepo;

  ValidateApplicationUser(this.repository, this.authRepo);

  Future<ApplicationUserEntity> call(String uid) async {
    if (uid.isEmpty) {
      await _reject(const ApplicationUserException.notLinked());
    }

    final applicationUser = await repository.getApplicationUserByUid(uid);

    if (applicationUser == null) {
      await _reject(const ApplicationUserException.notLinked());
    }

    if (!applicationUser.isActive) {
      await _reject(const ApplicationUserException.inactive());
    }

    return applicationUser;
  }

  Future<Never> _reject(ApplicationUserException exception) async {
    try {
      await authRepo.logout();
    } catch (_) {}

    throw exception;
  }
}
