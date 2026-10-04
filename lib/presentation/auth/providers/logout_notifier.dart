import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

    // TODO(hr-session-diagnostics): temporary debug logging.
    debugPrint('[hr-session] logout.start uid=${_debugUid()}');

    state = await AsyncValue.guard(() {
      return ref.read(logoutUseCaseProvider).call();
    });

    if (state.hasError) {
      return;
    }

    invalidateUserScopedData(ref);

    // TODO(hr-session-diagnostics): temporary debug logging.
    debugPrint('[hr-session] logout.done uid=${_debugUid()}');
    debugPrint('[ATTENDANCE-RELOGIN] logout uid=${_debugUid()}');

    state = const AsyncData(null);
  }

  // TODO(hr-session-diagnostics): temporary debug logging.
  String _debugUid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid ?? '<empty>';
    } catch (_) {
      return '<unavailable>';
    }
  }
}
