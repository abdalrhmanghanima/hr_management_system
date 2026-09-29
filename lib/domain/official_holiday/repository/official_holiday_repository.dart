import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';

abstract class OfficialHolidayRepository {
  Future<List<OfficialHolidayEntity>> getOfficialHolidays();

  Future<OfficialHolidayEntity?> getOfficialHolidayByNameAndDate(
    String name,
    DateTime date, {
    String? excludingId,
  });

  Future<void> addOfficialHoliday(OfficialHolidayEntity holiday);

  Future<void> updateOfficialHoliday(OfficialHolidayEntity holiday);

  Future<void> deleteOfficialHoliday(String id);
}
