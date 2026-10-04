import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_entity.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';

class AuthorizationNotifier extends AsyncNotifier<AuthorizationEntity> {
  @override
  Future<AuthorizationEntity> build() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    debugPrint('[hr-session] authorization.build uid="${uid.isEmpty ? "<empty>" : uid}"');

    if (uid.isEmpty) {
      return const AuthorizationEntity.unauthenticated();
    }

    final entity = await ref.read(loadAuthorizationProvider).call(uid);

    debugPrint('[hr-session] authorization.build -> ${entity.status}');
    debugPrint(
      '[ATTENDANCE-RELOGIN] authorization.build uid=$uid status=${entity.status} '
      'isResolved=${entity.isResolved} employeeId=${entity.employeeId ?? '<null>'}',
    );

    return entity;
  }

  Future<void> reload() async {
    state = const AsyncLoading();

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    debugPrint('[hr-session] authorization.reload uid="${uid.isEmpty ? "<empty>" : uid}"');

    if (uid.isEmpty) {
      state = AsyncData(const AuthorizationEntity.unauthenticated());
      return;
    }

    state = await AsyncValue.guard(
      () => ref.read(loadAuthorizationProvider).call(uid),
    );

    debugPrint('[hr-session] authorization.reload -> ${state.valueOrNull?.status}');
  }
}
