import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/domain/application_user/entity/application_user_entity.dart';
import 'package:hr_management_system/presentation/application_user/provider/application_user_provider.dart';

class ApplicationUserNotifier
    extends AsyncNotifier<List<ApplicationUserEntity>> {
  @override
  Future<List<ApplicationUserEntity>> build() async {
    return ref.read(getApplicationUsersUseCaseProvider).call();
  }

  Future<List<ApplicationUserEntity>> getApplicationUsers() async {
    state = await AsyncValue.guard(() {
      return ref.read(getApplicationUsersUseCaseProvider).call();
    });

    return state.valueOrNull ?? const [];
  }
}
