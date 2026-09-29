import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/official_holiday/data_source/official_holiday_remote_data_source.dart';
import 'package:hr_management_system/data/official_holiday/data_source/official_holiday_remote_data_source_impl.dart';
import 'package:hr_management_system/data/official_holiday/repository/official_holiday_repository_impl.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/domain/official_holiday/repository/official_holiday_repository.dart';
import 'package:hr_management_system/domain/official_holiday/use_case/add_official_holiday_use_case.dart';
import 'package:hr_management_system/domain/official_holiday/use_case/delete_official_holiday_use_case.dart';
import 'package:hr_management_system/domain/official_holiday/use_case/get_official_holidays_use_case.dart';
import 'package:hr_management_system/domain/official_holiday/use_case/get_official_holiday_by_name_and_date.dart';
import 'package:hr_management_system/domain/official_holiday/use_case/update_official_holiday_use_case.dart';
import 'package:hr_management_system/presentation/official_holiday/provider/official_holidays_notifier.dart';

final officialHolidaysProvider =
    AsyncNotifierProvider<
      OfficialHolidaysNotifier,
      List<OfficialHolidayEntity>
    >(OfficialHolidaysNotifier.new);

final officialHolidayRemoteDataSourceProvider =
    Provider<OfficialHolidayRemoteDataSource>((ref) {
      return OfficialHolidayRemoteDataSourceImpl(FirebaseFirestore.instance);
    });

final officialHolidayRepositoryProvider = Provider<OfficialHolidayRepository>((
  ref,
) {
  return OfficialHolidayRepositoryImpl(
    ref.read(officialHolidayRemoteDataSourceProvider),
  );
});

final getOfficialHolidaysUseCaseProvider = Provider<GetOfficialHolidaysUseCase>(
  (ref) {
    return GetOfficialHolidaysUseCase(
      ref.read(officialHolidayRepositoryProvider),
    );
  },
);

final addOfficialHolidayUseCaseProvider = Provider<AddOfficialHolidayUseCase>((
  ref,
) {
  return AddOfficialHolidayUseCase(ref.read(officialHolidayRepositoryProvider));
});

final getOfficialHolidayByNameAndDateUseCaseProvider =
    Provider<GetOfficialHolidayByNameAndDateUseCase>((ref) {
      return GetOfficialHolidayByNameAndDateUseCase(
        ref.read(officialHolidayRepositoryProvider),
      );
    });

final updateOfficialHolidayUseCaseProvider =
    Provider<UpdateOfficialHolidayUseCase>((ref) {
      return UpdateOfficialHolidayUseCase(
        ref.read(officialHolidayRepositoryProvider),
      );
    });

final deleteOfficialHolidayUseCaseProvider =
    Provider<DeleteOfficialHolidayUseCase>((ref) {
      return DeleteOfficialHolidayUseCase(
        ref.read(officialHolidayRepositoryProvider),
      );
    });
