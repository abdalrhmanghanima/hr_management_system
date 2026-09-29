import 'package:hr_management_system/core/constants/constants.dart';
import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';

class WorkingDayPolicy {
  const WorkingDayPolicy();

  bool isWeeklyHoliday(DateTime date, List<String> weekendDays) {
    if (weekendDays.isEmpty) {
      return false;
    }

    final dayName = _dayName(date);
    final normalized = weekendDays
        .map((day) => day.trim().toLowerCase())
        .toSet();

    return normalized.contains(dayName);
  }

  bool isOfficialHoliday(
    DateTime date,
    List<OfficialHolidayEntity> officialHolidays,
  ) {
    for (final holiday in officialHolidays) {
      if (isSameDay(holiday.date, date)) {
        return true;
      }
    }

    return false;
  }

  bool isWorkingDay({
    required DateTime date,
    required GeneralSettingsEntity settings,
    required List<OfficialHolidayEntity> officialHolidays,
  }) {
    if (isWeeklyHoliday(date, settings.weekendDays)) {
      return false;
    }

    if (isOfficialHoliday(date, officialHolidays)) {
      return false;
    }

    return true;
  }

  String _dayName(DateTime date) {
    return weekDayNames[date.weekday - 1].toLowerCase();
  }

  bool isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
