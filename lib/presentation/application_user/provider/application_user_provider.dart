import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/application_user/data_source/application_user_remote_data_source.dart';
import 'package:hr_management_system/data/application_user/data_source/application_user_remote_data_source_impl.dart';
import 'package:hr_management_system/data/application_user/repository/application_user_repository_impl.dart';
import 'package:hr_management_system/domain/application_user/entity/application_user_entity.dart';
import 'package:hr_management_system/domain/application_user/repository/application_user_repository.dart';
import 'package:hr_management_system/domain/application_user/use_case/get_application_user_by_uid.dart';
import 'package:hr_management_system/domain/application_user/use_case/get_application_users.dart';
import 'package:hr_management_system/domain/application_user/use_case/update_application_user.dart';
import 'package:hr_management_system/domain/application_user/use_case/validate_application_user.dart';
import 'package:hr_management_system/presentation/application_user/provider/application_user_notifier.dart';
import 'package:hr_management_system/presentation/application_user/provider/application_user_operation_notifier.dart';
import 'package:hr_management_system/presentation/auth/providers/login_notifier.dart';

final applicationUserProvider =
    AsyncNotifierProvider<ApplicationUserNotifier, List<ApplicationUserEntity>>(
      ApplicationUserNotifier.new,
    );

final applicationUserOperationProvider =
    AsyncNotifierProvider<ApplicationUserOperationNotifier, void>(
      ApplicationUserOperationNotifier.new,
    );

final applicationUserSearchProvider =
    StateProvider.autoDispose<String>((ref) => '');

final applicationUserRemoteDataSourceProvider =
    Provider<ApplicationUserRemoteDataSource>((ref) {
      return ApplicationUserRemoteDataSourceImpl(FirebaseFirestore.instance);
    });

final applicationUserRepositoryProvider = Provider<ApplicationUserRepository>((
  ref,
) {
  return ApplicationUserRepositoryImpl(
    ref.read(applicationUserRemoteDataSourceProvider),
  );
});

final getApplicationUsersUseCaseProvider = Provider<GetApplicationUsers>((ref) {
  return GetApplicationUsers(ref.read(applicationUserRepositoryProvider));
});

final getApplicationUserByUidUseCaseProvider =
    Provider<GetApplicationUserByUid>((ref) {
      return GetApplicationUserByUid(ref.read(applicationUserRepositoryProvider));
    });

final updateApplicationUserUseCaseProvider = Provider<UpdateApplicationUser>((
  ref,
) {
  return UpdateApplicationUser(ref.read(applicationUserRepositoryProvider));
});

final validateApplicationUserUseCaseProvider = Provider<ValidateApplicationUser>(
  (ref) {
    return ValidateApplicationUser(
      ref.read(applicationUserRepositoryProvider),
      ref.read(authRepoProvider),
    );
  },
);
