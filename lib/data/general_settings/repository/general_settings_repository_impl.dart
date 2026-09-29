import 'package:hr_management_system/data/general_settings/data_source/general_settings_remote_data_source.dart';
import 'package:hr_management_system/data/general_settings/model/general_settings_model.dart';
import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';
import 'package:hr_management_system/domain/general_settings/repository/general_settings_repository.dart';

class GeneralSettingsRepositoryImpl implements GeneralSettingsRepository {
  final GeneralSettingsRemoteDataSource remoteDataSource;

  GeneralSettingsRepositoryImpl(this.remoteDataSource);

  @override
  Future<GeneralSettingsEntity> getGeneralSettings() async {
    final settings = await remoteDataSource.getGeneralSettings();

    return settings.toEntity();
  }

  @override
  Future<void> updateGeneralSettings(GeneralSettingsEntity settings) async {
    final model = GeneralSettingsModel(
      multiplier: settings.multiplier,
      workingHoursPerDay: settings.workingHoursPerDay,
      weekendDays: settings.weekendDays,
    );

    await remoteDataSource.updateGeneralSettings(model);
  }
}
