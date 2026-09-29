import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';
import 'package:hr_management_system/domain/general_settings/validation/general_settings_validator.dart';
import 'package:hr_management_system/presentation/more/provider/general_settings_provider.dart';
import 'package:hr_management_system/presentation/payroll/provider/payroll_provider.dart';

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

  Future<bool> updateGeneralSettings(GeneralSettingsEntity settings) async {
    final validationError = GeneralSettingsValidator.validate(settings);

    if (validationError != null) {
      state = AsyncData(state.value ?? GeneralSettingsEntity.defaults());

      return false;
    }

    state = const AsyncLoading();

    try {
      await ref.read(updateGeneralSettingsUseCaseProvider).call(settings);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return false;
    }

    state = AsyncData(settings);

    ref.invalidate(payrollSummariesProvider);

    return true;
  }
}
