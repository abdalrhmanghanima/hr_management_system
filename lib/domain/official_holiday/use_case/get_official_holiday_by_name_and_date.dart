import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/domain/official_holiday/repository/official_holiday_repository.dart';

class GetOfficialHolidayByNameAndDateUseCase {
  final OfficialHolidayRepository repository;

  GetOfficialHolidayByNameAndDateUseCase(this.repository);

  Future<OfficialHolidayEntity?> call(
    String name,
    DateTime date, {
    String? excludingId,
  }) {
    return repository.getOfficialHolidayByNameAndDate(
      name,
      date,
      excludingId: excludingId,
    );
  }
}
