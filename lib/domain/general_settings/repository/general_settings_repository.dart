import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';

abstract class GeneralSettingsRepository {
  Future<GeneralSettingsEntity> getGeneralSettings();

  Future<void> updateGeneralSettings(GeneralSettingsEntity settings);
}
