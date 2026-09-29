import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';

class GeneralSettingsValidator {
  const GeneralSettingsValidator._();

  static String? multiplier(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');

    if (parsed == null) {
      return 'Multiplier is required';
    }

    if (parsed <= 0) {
      return 'Multiplier must be greater than 0';
    }

    return null;
  }

  static String? workingHoursPerDay(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');

    if (parsed == null) {
      return 'Working Hours Per Day is required';
    }

    if (parsed <= 0) {
      return 'Working Hours Per Day must be greater than 0';
    }

    return null;
  }

  static String? weekendDays(List<String> days) {
    if (days.isEmpty) {
      return 'Select at least one weekend day';
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
