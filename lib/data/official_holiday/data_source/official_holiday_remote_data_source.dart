import 'package:hr_management_system/data/official_holiday/model/official_holiday_model.dart';

abstract class OfficialHolidayRemoteDataSource {
  Future<List<OfficialHolidayModel>> getOfficialHolidays();

  Future<OfficialHolidayModel?> getOfficialHolidayByNameAndDate(
    String name,
    DateTime date, {
    String? excludingId,
  });

  Future<void> addOfficialHoliday(OfficialHolidayModel holiday);

  Future<void> updateOfficialHoliday(OfficialHolidayModel holiday);

  Future<void> deleteOfficialHoliday(String id);
}
