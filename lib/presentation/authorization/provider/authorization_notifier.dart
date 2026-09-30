import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_entity.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';

class AuthorizationNotifier extends AsyncNotifier<AuthorizationEntity> {
  @override
  Future<AuthorizationEntity> build() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (uid.isEmpty) {
      return const AuthorizationEntity.unauthenticated();
    }

    return ref.read(loadAuthorizationProvider).call(uid);
  }

  Future<void> reload() async {
    state = const AsyncLoading();

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (uid.isEmpty) {
      state = AsyncData(const AuthorizationEntity.unauthenticated());
      return;
    }

    state = await AsyncValue.guard(
      () => ref.read(loadAuthorizationProvider).call(uid),
    );
  }
}
