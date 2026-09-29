import 'package:hr_management_system/domain/attendance/entity/attendance_calculation_entity.dart';

class CalculateAttendanceHoursUseCase {
  static const double daysPerMonth = 30;

  AttendanceCalculationEntity call({
    required double monthlySalary,
    required DateTime? checkInTime,
    required DateTime? checkOutTime,
    required double workingHoursPerDay,
    required double multiplier,
  }) {
    if (workingHoursPerDay <= 0) {
      return AttendanceCalculationEntity.empty();
    }

    if (checkInTime == null || checkOutTime == null) {
      return AttendanceCalculationEntity.empty();
    }

    final workedMilliseconds = checkOutTime
        .difference(checkInTime)
        .inMilliseconds;

    if (workedMilliseconds <= 0) {
      return AttendanceCalculationEntity.empty();
    }

    final actualWorkedHours = workedMilliseconds / Duration.millisecondsPerHour;

    final deductionHours = actualWorkedHours < workingHoursPerDay
        ? workingHoursPerDay - actualWorkedHours
        : 0.0;

    final overtimeHours = actualWorkedHours > workingHoursPerDay
        ? actualWorkedHours - workingHoursPerDay
        : 0.0;

    final hourlyRate = monthlySalary / daysPerMonth / workingHoursPerDay;

    return AttendanceCalculationEntity(
      actualWorkedHours: _round(actualWorkedHours),
      overtimeHours: _round(overtimeHours),
      deductionHours: _round(deductionHours),
      hourlyRate: _round(hourlyRate),
      overtimeAmount: _round(overtimeHours * hourlyRate * multiplier),
      deductionAmount: _round(deductionHours * hourlyRate * multiplier),
    );
  }

  double _round(double value) {
    return (value * 100).roundToDouble() / 100;
  }
}
