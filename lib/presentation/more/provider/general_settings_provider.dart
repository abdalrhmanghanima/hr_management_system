import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/general_settings/data_source/general_settings_remote_data_source.dart';
import 'package:hr_management_system/data/general_settings/data_source/general_settings_remote_data_source_impl.dart';
import 'package:hr_management_system/data/general_settings/repository/general_settings_repository_impl.dart';
import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';
import 'package:hr_management_system/domain/general_settings/repository/general_settings_repository.dart';
import 'package:hr_management_system/domain/general_settings/use_case/get_general_settings_use_case.dart';
import 'package:hr_management_system/domain/general_settings/use_case/update_general_settings_use_case.dart';
import 'package:hr_management_system/presentation/more/provider/general_settings_notifier.dart';

final generalSettingsProvider =
    AsyncNotifierProvider<GeneralSettingsNotifier, GeneralSettingsEntity>(
      GeneralSettingsNotifier.new,
    );

final generalSettingsRemoteDataSourceProvider =
    Provider<GeneralSettingsRemoteDataSource>((ref) {
      return GeneralSettingsRemoteDataSourceImpl(FirebaseFirestore.instance);
    });

final generalSettingsRepositoryProvider = Provider<GeneralSettingsRepository>((
  ref,
) {
  return GeneralSettingsRepositoryImpl(
    ref.read(generalSettingsRemoteDataSourceProvider),
  );
});

final getGeneralSettingsUseCaseProvider = Provider<GetGeneralSettingsUseCase>((
  ref,
) {
  return GetGeneralSettingsUseCase(ref.read(generalSettingsRepositoryProvider));
});

final updateGeneralSettingsUseCaseProvider =
    Provider<UpdateGeneralSettingsUseCase>((ref) {
      return UpdateGeneralSettingsUseCase(
        ref.read(generalSettingsRepositoryProvider),
      );
    });
