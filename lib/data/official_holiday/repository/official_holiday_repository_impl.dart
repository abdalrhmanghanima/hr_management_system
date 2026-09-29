import 'package:hr_management_system/data/official_holiday/data_source/official_holiday_remote_data_source.dart';
import 'package:hr_management_system/data/official_holiday/model/official_holiday_model.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/domain/official_holiday/repository/official_holiday_repository.dart';

class OfficialHolidayRepositoryImpl implements OfficialHolidayRepository {
  final OfficialHolidayRemoteDataSource remoteDataSource;

  OfficialHolidayRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<OfficialHolidayEntity>> getOfficialHolidays() async {
    final holidays = await remoteDataSource.getOfficialHolidays();

    final entities = holidays.map((holiday) {
      return holiday.toEntity();
    }).toList();

    entities.sort((first, second) {
      return first.date.compareTo(second.date);
    });

    return entities;
  }

  @override
  Future<OfficialHolidayEntity?> getOfficialHolidayByNameAndDate(
    String name,
    DateTime date, {
    String? excludingId,
  }) async {
    final holiday = await remoteDataSource.getOfficialHolidayByNameAndDate(
      name,
      date,
      excludingId: excludingId,
    );

    return holiday?.toEntity();
  }

  @override
  Future<void> addOfficialHoliday(OfficialHolidayEntity holiday) async {
    final model = OfficialHolidayModel(
      id: holiday.id,
      name: holiday.name,
      date: holiday.date,
    );

    await remoteDataSource.addOfficialHoliday(model);
  }

  @override
  Future<void> updateOfficialHoliday(OfficialHolidayEntity holiday) async {
    final model = OfficialHolidayModel(
      id: holiday.id,
      name: holiday.name,
      date: holiday.date,
    );

    await remoteDataSource.updateOfficialHoliday(model);
  }

  @override
  Future<void> deleteOfficialHoliday(String id) async {
    await remoteDataSource.deleteOfficialHoliday(id);
  }
}
