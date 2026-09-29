import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/domain/auth/use_case/logout_use_case.dart';
import 'package:hr_management_system/presentation/auth/providers/login_notifier.dart';
import 'package:hr_management_system/presentation/auth/providers/user_data_invalidation.dart';

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepoProvider));
});

class LogoutNotifier extends AsyncNotifier<void> {
  Future<void>? pendingLogout;

  @override
  Future<void> build() async {}

  Future<void> logout() {
    return pendingLogout ??= performLogout().whenComplete(() {
      pendingLogout = null;
    });
  }

  Future<void> performLogout() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() {
      return ref.read(logoutUseCaseProvider).call();
    });

    if (state.hasError) {
      return;
    }

    invalidateUserScopedData(ref);

    state = const AsyncData(null);
  }
}
