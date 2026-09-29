import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';
import 'package:hr_management_system/presentation/more/provider/general_settings_provider.dart';

class GeneralSettingsNotifier extends AsyncNotifier<GeneralSettingsEntity> {
  @override
  Future<GeneralSettingsEntity> build() async {
    return ref.read(getGeneralSettingsUseCaseProvider).call();
  }

  Future<void> getGeneralSettings() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(getGeneralSettingsUseCaseProvider).call(),
    );
  }

  Future<void> updateGeneralSettings(GeneralSettingsEntity settings) async {
    state = const AsyncLoading();

    await ref.read(updateGeneralSettingsUseCaseProvider).call(settings);

    state = AsyncData(settings);
  }
}
