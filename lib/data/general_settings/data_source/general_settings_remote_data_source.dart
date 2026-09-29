import 'package:hr_management_system/data/general_settings/model/general_settings_model.dart';

abstract class GeneralSettingsRemoteDataSource {
  Future<GeneralSettingsModel> getGeneralSettings();

  Future<void> updateGeneralSettings(GeneralSettingsModel settings);
}
