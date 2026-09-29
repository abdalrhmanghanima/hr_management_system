import 'dart:math' as math;

import 'package:hr_management_system/core/constants/constants.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_calculation_entity.dart';

class CalculateAttendanceHoursUseCase {
  static const double daysPerMonth = 30;

  static const int gracePeriodMinutes = 30;

  static const double roundingTolerance = 1e-9;

  AttendanceCalculationEntity call({
    required double monthlySalary,
    required DateTime? checkInTime,
    required DateTime? checkOutTime,
    required double workingHoursPerDay,
    required double multiplier,
    bool isWorkingDay = true,
  }) {
    if (workingHoursPerDay <= 0) {
      return AttendanceCalculationEntity.empty(isWorkingDay: isWorkingDay);
    }

    if (!isWorkingDay) {
      return AttendanceCalculationEntity.empty(isWorkingDay: false);
    }

    final daily = dailyRate(monthlySalary);
    final hourly = hourlyRate(monthlySalary, workingHoursPerDay);

    if (checkInTime == null) {
      return AttendanceCalculationEntity(
        actualWorkedHours: 0,
        overtimeHours: 0,
        deductionHours: 0,
        hourlyRate: hourly,
        overtimeAmount: 0,
        deductionAmount: 0,
        lateHours: 0,
        earlyCheckoutHours: 0,
        dailyRate: daily,
        absenceDeduction: _round(daily * multiplier),
        isWorkingDay: true,
        isAbsent: true,
      );
    }

    final shiftStart = DateTime(
      checkInTime.year,
      checkInTime.month,
      checkInTime.day,
      companyShiftStartHour,
      companyShiftStartMinute,
    );

    final standardMinutes = workingHoursPerDay * Duration.minutesPerHour;
    final shiftEnd = shiftStart.add(Duration(minutes: standardMinutes.round()));

    final lateMinutes = _lateMinutes(checkInTime, shiftStart);
    final earlyMinutes = checkOutTime == null
        ? 0
        : _earlyMinutes(checkOutTime, shiftEnd);

    final lateHours = _round(_penaltyHours(lateMinutes));
    final earlyCheckoutHours = _round(_penaltyHours(earlyMinutes));

    final deductionHours = _round(math.max(lateHours, earlyCheckoutHours));

    final workedMinutes = checkOutTime == null
        ? 0.0
        : checkOutTime.difference(checkInTime).inMinutes.toDouble();

    final actualWorkedHours = _round(math.max(0.0, workedMinutes) / 60);

    final overtimeMinutes = math.max(0.0, workedMinutes - standardMinutes);
    final overtimeHours = _round(overtimeMinutes / 60);

    return AttendanceCalculationEntity(
      actualWorkedHours: actualWorkedHours,
      overtimeHours: overtimeHours,
      deductionHours: deductionHours,
      hourlyRate: hourly,
      overtimeAmount: _round(overtimeHours * hourly * multiplier),
      deductionAmount: _round(deductionHours * hourly * multiplier),
      lateHours: lateHours,
      earlyCheckoutHours: earlyCheckoutHours,
      dailyRate: daily,
      absenceDeduction: 0,
      isWorkingDay: true,
      isAbsent: false,
    );
  }

  double dailyRate(double monthlySalary) {
    return _round(monthlySalary / daysPerMonth);
  }

  double hourlyRate(double monthlySalary, double workingHoursPerDay) {
    if (workingHoursPerDay <= 0) {
      return 0;
    }

    return _round(dailyRate(monthlySalary) / workingHoursPerDay);
  }

  int _lateMinutes(DateTime checkInTime, DateTime shiftStart) {
    final minutes = checkInTime.difference(shiftStart).inMinutes;

    return minutes > 0 ? minutes : 0;
  }

  int _earlyMinutes(DateTime checkOutTime, DateTime shiftEnd) {
    final minutes = shiftEnd.difference(checkOutTime).inMinutes;

    return minutes > 0 ? minutes : 0;
  }

  double _penaltyHours(int minutes) {
    if (minutes < gracePeriodMinutes) {
      return 0;
    }

    return minutes / Duration.minutesPerHour;
  }

  double _round(double value) {
    return ((value * 100) + roundingTolerance).roundToDouble() / 100;
  }
}
