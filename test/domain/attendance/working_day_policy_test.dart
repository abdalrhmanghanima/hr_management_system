import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/domain/attendance/service/working_day_policy.dart';
import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';

void main() {
  const policy = WorkingDayPolicy();

  const settings = GeneralSettingsEntity(
    multiplier: 2,
    workingHoursPerDay: 8,
    weekendDays: ['Friday', 'Saturday'],
  );

  final officialHolidays = [
    OfficialHolidayEntity(
      id: 'holiday_1',
      name: 'Company Holiday',
      date: DateTime(2026, 9, 30),
    ),
  ];

  bool isWorking(int year, int month, int day) {
    return policy.isWorkingDay(
      date: DateTime(year, month, day),
      settings: settings,
      officialHolidays: officialHolidays,
    );
  }

  group('weekly holidays', () {
    test('friday is not a working day', () {
      expect(policy.isWeeklyHoliday(DateTime(2026, 9, 25), ['Friday']), isTrue);
    });

    test('saturday is not a working day', () {
      expect(
        policy.isWeeklyHoliday(DateTime(2026, 9, 26), ['Saturday']),
        isTrue,
      );
    });

    test('sunday is a working day when the weekend is friday and saturday', () {
      expect(
        policy.isWeeklyHoliday(DateTime(2026, 9, 27), ['Friday', 'Saturday']),
        isFalse,
      );
    });

    test('day names are matched regardless of case and padding', () {
      expect(
        policy.isWeeklyHoliday(DateTime(2026, 9, 25), [' friday ']),
        isTrue,
      );
    });

    test('an empty weekend list has no weekly holiday', () {
      expect(policy.isWeeklyHoliday(DateTime(2026, 9, 25), []), isFalse);
    });
  });

  group('official holidays', () {
    test('a matching date is an official holiday', () {
      expect(
        policy.isOfficialHoliday(DateTime(2026, 9, 30), officialHolidays),
        isTrue,
      );
    });

    test('another date is not an official holiday', () {
      expect(
        policy.isOfficialHoliday(DateTime(2026, 9, 29), officialHolidays),
        isFalse,
      );
    });

    test('the time of day does not affect the match', () {
      expect(
        policy.isOfficialHoliday(
          DateTime(2026, 9, 30, 23, 59),
          officialHolidays,
        ),
        isTrue,
      );
    });
  });

  group('is working day', () {
    test('a regular weekday is a working day', () {
      expect(isWorking(2026, 9, 28), isTrue);
    });

    test('a weekend day is not a working day', () {
      expect(isWorking(2026, 9, 25), isFalse);
    });

    test('an official holiday on a weekday is not a working day', () {
      expect(isWorking(2026, 9, 30), isFalse);
    });

    test('a day that is both weekly and official is not a working day', () {
      final fridayHolidaySettings = GeneralSettingsEntity(
        multiplier: 2,
        workingHoursPerDay: 8,
        weekendDays: ['Thursday', 'Friday'],
      );

      final overlappingHolidays = [
        OfficialHolidayEntity(
          id: 'holiday_2',
          name: 'Overlapping Holiday',
          date: DateTime(2026, 10, 2),
        ),
      ];

      final result = policy.isWorkingDay(
        date: DateTime(2026, 10, 2),
        settings: fridayHolidaySettings,
        officialHolidays: overlappingHolidays,
      );

      expect(result, isFalse);
    });
  });
}
