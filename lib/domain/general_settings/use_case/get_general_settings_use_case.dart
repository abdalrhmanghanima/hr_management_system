import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';
import 'package:hr_management_system/domain/general_settings/repository/general_settings_repository.dart';

class GetGeneralSettingsUseCase {
  final GeneralSettingsRepository repository;

  GetGeneralSettingsUseCase(this.repository);

  Future<GeneralSettingsEntity> call() {
    return repository.getGeneralSettings();
  }
}
