import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';

class GeneralSettingsValidator {
  const GeneralSettingsValidator._();

  static String? multiplier(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'validation.settings.field_data_required';
    }

    final parsed = double.tryParse(text);

    if (parsed == null) {
      return 'validation.settings.multiplier_required';
    }

    if (parsed <= 0) {
      return 'validation.settings.multiplier_positive';
    }

    return null;
  }

  static String? workingHoursPerDay(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'validation.settings.field_data_required';
    }

    final parsed = double.tryParse(text);

    if (parsed == null) {
      return 'validation.settings.working_hours_required';
    }

    if (parsed <= 0) {
      return 'validation.settings.working_hours_positive';
    }

    return null;
  }

  static String? weekendDays(List<String> days) {
    if (days.isEmpty) {
      return 'validation.settings.weekend_days_required';
    }

    return null;
  }

  static String? validate(GeneralSettingsEntity settings) {
    return weekendDays(settings.weekendDays) ??
        multiplier(settings.multiplier.toString()) ??
        workingHoursPerDay(settings.workingHoursPerDay.toString());
  }

  static bool isValid(GeneralSettingsEntity settings) {
    return validate(settings) == null;
  }
}
