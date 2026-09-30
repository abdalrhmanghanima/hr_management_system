import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';

class UpdateUserGroup {
  final AuthRepo authRepo;

  UpdateUserGroup(this.authRepo);

  Future<void> call({
    required String uid,
    required String employeeId,
    String? groupId,
  }) {
    return authRepo.updateUserGroup(
      uid: uid,
      employeeId: employeeId,
      groupId: groupId,
    );
  }
}
