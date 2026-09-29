import 'package:hr_management_system/domain/official_holiday/repository/official_holiday_repository.dart';

class DeleteOfficialHolidayUseCase {
  final OfficialHolidayRepository repository;

  DeleteOfficialHolidayUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteOfficialHoliday(id);
  }
}
