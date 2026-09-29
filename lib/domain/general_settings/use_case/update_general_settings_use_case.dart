import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';
import 'package:hr_management_system/domain/general_settings/repository/general_settings_repository.dart';

class UpdateGeneralSettingsUseCase {
  final GeneralSettingsRepository repository;

  UpdateGeneralSettingsUseCase(this.repository);

  Future<void> call(GeneralSettingsEntity settings) {
    return repository.updateGeneralSettings(settings);
  }
}
