import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/presentation/official_holiday/provider/official_holidays_provider.dart';
import 'package:hr_management_system/presentation/payroll/provider/payroll_provider.dart';

class OfficialHolidaysNotifier
    extends AsyncNotifier<List<OfficialHolidayEntity>> {
  @override
  Future<List<OfficialHolidayEntity>> build() async {
    return ref.read(getOfficialHolidaysUseCaseProvider).call();
  }

  Future<void> getOfficialHolidays() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(getOfficialHolidaysUseCaseProvider).call(),
    );
  }

  Future<SaveResult> addOfficialHoliday(OfficialHolidayEntity holiday) async {
    try {
      final existing = await ref
          .read(getOfficialHolidayByNameAndDateUseCaseProvider)
          .call(holiday.name, holiday.date);

      if (existing != null) {
        return SaveResult.duplicate;
      }

      state = const AsyncLoading();

      await ref.read(addOfficialHolidayUseCaseProvider).call(holiday);

      state = AsyncData(
        await ref.read(getOfficialHolidaysUseCaseProvider).call(),
      );

      ref.invalidate(payrollSummariesProvider);

      return SaveResult.success;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return SaveResult.failure;
    }
  }

  Future<SaveResult> updateOfficialHoliday(
    OfficialHolidayEntity holiday,
  ) async {
    try {
      final existing = await ref
          .read(getOfficialHolidayByNameAndDateUseCaseProvider)
          .call(holiday.name, holiday.date, excludingId: holiday.id);

      if (existing != null) {
        return SaveResult.duplicate;
      }

      state = const AsyncLoading();

      await ref.read(updateOfficialHolidayUseCaseProvider).call(holiday);

      state = AsyncData(
        await ref.read(getOfficialHolidaysUseCaseProvider).call(),
      );

      ref.invalidate(payrollSummariesProvider);

      return SaveResult.success;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return SaveResult.failure;
    }
  }

  Future<bool> deleteOfficialHoliday(String id) async {
    state = const AsyncLoading();

    try {
      await ref.read(deleteOfficialHolidayUseCaseProvider).call(id);

      final holidays = await ref
          .read(getOfficialHolidaysUseCaseProvider)
          .call();

      state = AsyncData(holidays);

      ref.invalidate(payrollSummariesProvider);

      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
