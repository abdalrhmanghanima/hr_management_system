import 'package:hr_management_system/domain/auth/entity/user_entity.dart';
import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';

class LoginUseCase {
  final AuthRepo authRepo;

  LoginUseCase(this.authRepo);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) {
    return authRepo.login(
      email: email,
      password: password,
    );
  }
}