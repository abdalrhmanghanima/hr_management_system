import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/authorization/repository/authorization_repository_impl.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_entity.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_status.dart';
import 'package:hr_management_system/domain/authorization/repository/authorization_repository.dart';
import 'package:hr_management_system/domain/authorization/service/permission_checker.dart';
import 'package:hr_management_system/domain/authorization/use_case/load_authorization.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/auth/providers/login_notifier.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_notifier.dart';
import 'package:hr_management_system/presentation/groups_permissions/provider/group_provider.dart';

final authorizationProvider =
    AsyncNotifierProvider<AuthorizationNotifier, AuthorizationEntity>(
      AuthorizationNotifier.new,
    );

final authorizationRepositoryProvider = Provider<AuthorizationRepository>((ref) {
  return AuthorizationRepositoryImpl(
    authRepo: ref.read(authRepoProvider),
    groupRepository: ref.read(groupRepositoryProvider),
  );
});

final loadAuthorizationProvider = Provider<LoadAuthorization>((ref) {
  return LoadAuthorization(ref.read(authorizationRepositoryProvider));
});

final authorizationEntityProvider = Provider<AuthorizationEntity>((ref) {
  final authorization = ref.watch(authorizationProvider);

  return authorization.when(
    data: (entity) => entity,
    error: (error, stackTrace) => const AuthorizationEntity.failed(),
    loading: () => const AuthorizationEntity.loading(),
  );
});

final permissionCheckerProvider = Provider<PermissionChecker>((ref) {
  return PermissionChecker(ref.watch(authorizationEntityProvider));
});

final modulePermissionProvider =
    Provider.family<bool, ({GroupModule module, PermissionAction action})>((
      ref,
      key,
    ) {
      return ref
          .watch(permissionCheckerProvider)
          .authorization
          .isGranted(key.module, key.action);
    });

final authorizationStatusProvider = Provider<AuthorizationStatus>((ref) {
  return ref.watch(authorizationEntityProvider).status;
});

final currentEmployeeIdProvider = Provider<String?>((ref) {
  return ref.watch(authorizationEntityProvider).employeeId;
});

final currentGroupNameProvider = Provider<String>((ref) {
  return ref.watch(authorizationEntityProvider).groupName;
});
