import 'package:hr_management_system/domain/authorization/entity/authorization_entity.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_status.dart';
import 'package:hr_management_system/domain/authorization/repository/authorization_repository.dart';
import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';
import 'package:hr_management_system/domain/group/repository/group_repository.dart';

class AuthorizationRepositoryImpl implements AuthorizationRepository {
  final AuthRepo authRepo;
  final GroupRepository groupRepository;

  AuthorizationRepositoryImpl({
    required this.authRepo,
    required this.groupRepository,
  });

  @override
  Future<AuthorizationEntity> load(String uid) async {
    if (uid.isEmpty) {
      return const AuthorizationEntity.unauthenticated();
    }

    final user = await authRepo.getUserByUid(uid);

    if (user == null) {
      return AuthorizationEntity(
        status: AuthorizationStatus.missingUserDocument,
        uid: uid,
      );
    }

    if (!user.isActive) {
      return AuthorizationEntity(
        status: AuthorizationStatus.inactive,
        uid: uid,
        email: user.email,
        employeeId: user.employeeId,
        groupId: user.groupId,
      );
    }

    final groupId = user.groupId;

    if (groupId == null || groupId.isEmpty) {
      return AuthorizationEntity(
        status: AuthorizationStatus.withoutGroup,
        uid: uid,
        email: user.email,
        employeeId: user.employeeId,
      );
    }

    final group = await groupRepository.getGroupById(groupId);

    if (group == null) {
      return AuthorizationEntity(
        status: AuthorizationStatus.groupNotFound,
        uid: uid,
        email: user.email,
        employeeId: user.employeeId,
        groupId: groupId,
      );
    }

    return AuthorizationEntity(
      status: AuthorizationStatus.authenticated,
      uid: uid,
      email: user.email,
      employeeId: user.employeeId,
      groupId: group.id,
      group: group,
      permissions: group.permissions,
    );
  }
}
