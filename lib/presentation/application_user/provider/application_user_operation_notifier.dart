import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/domain/application_user/entity/application_user_entity.dart';
import 'package:hr_management_system/presentation/application_user/provider/application_user_provider.dart';

class ApplicationUserOperationNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<SaveResult> updateApplicationUser(
    ApplicationUserEntity applicationUser,
  ) {
    return _run(() async {
      await ref
          .read(updateApplicationUserUseCaseProvider)
          .call(applicationUser);
    });
  }

  Future<SaveResult> setApplicationUserActive(
    ApplicationUserEntity applicationUser,
    bool isActive,
  ) {
    return updateApplicationUser(
      applicationUser.copyWith(
        isActive: isActive,
        groupId: applicationUser.groupId,
        clearGroup: !applicationUser.hasGroup,
      ),
    );
  }

  Future<SaveResult> _run(Future<void> Function() action) async {
    state = const AsyncLoading();

    try {
      await action();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return SaveResult.failure;
    }

    await ref.read(applicationUserProvider.notifier).getApplicationUsers();

    return SaveResult.success;
  }
}
