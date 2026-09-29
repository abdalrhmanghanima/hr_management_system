import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/domain/official_holiday/repository/official_holiday_repository.dart';

class GetOfficialHolidaysUseCase {
  final OfficialHolidayRepository repository;

  GetOfficialHolidaysUseCase(this.repository);

  Future<List<OfficialHolidayEntity>> call() {
    return repository.getOfficialHolidays();
  }
}
