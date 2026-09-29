import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/domain/official_holiday/repository/official_holiday_repository.dart';

class UpdateOfficialHolidayUseCase {
  final OfficialHolidayRepository repository;

  UpdateOfficialHolidayUseCase(this.repository);

  Future<void> call(OfficialHolidayEntity holiday) {
    return repository.updateOfficialHoliday(holiday);
  }
}
