import 'package:hr_management_system/domain/attendance/entity/attendance_calculation_entity.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance/service/working_day_policy.dart';
import 'package:hr_management_system/domain/attendance/use_case/calculate_attendance_hours_use_case.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/domain/payroll/entity/payroll_calculation_entity.dart';

class CalculatePayrollUseCase {
  final CalculateAttendanceHoursUseCase calculateAttendanceHours;
  final WorkingDayPolicy workingDayPolicy;

  CalculatePayrollUseCase({
    CalculateAttendanceHoursUseCase? calculateAttendanceHours,
    this.workingDayPolicy = const WorkingDayPolicy(),
  }) : calculateAttendanceHours =
           calculateAttendanceHours ?? CalculateAttendanceHoursUseCase();

  PayrollCalculationEntity call({
    required EmployeeEntity employee,
    required List<AttendanceEntity> attendances,
    required GeneralSettingsEntity settings,
    required List<OfficialHolidayEntity> officialHolidays,
    required DateTime month,
  }) {
    final year = month.year;
    final monthIndex = month.month;
    final daysInMonth = DateTime(year, monthIndex + 1, 0).day;

    final dailyRate = calculateAttendanceHours.dailyRate(employee.salary);
    final hourlyRate = calculateAttendanceHours.hourlyRate(
      employee.salary,
      settings.workingHoursPerDay,
    );

    var workingDays = 0;
    var absentDays = 0;
    var holidayDays = 0;
    var overtimeHours = 0.0;
    var overtimeAmount = 0.0;
    var deductionHours = 0.0;
    var lateEarlyDeductionAmount = 0.0;
    var absenceDeduction = 0.0;

    final byDay = _attendancesByDay(attendances, year, monthIndex);

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, monthIndex, day);

      final isWorkingDay = workingDayPolicy.isWorkingDay(
        date: date,
        settings: settings,
        officialHolidays: officialHolidays,
      );

      if (!isWorkingDay) {
        holidayDays++;
        continue;
      }

      workingDays++;

      final calculation = calculateAttendanceHours.call(
        monthlySalary: employee.salary,
        checkInTime: byDay[day]?.checkInTime,
        checkOutTime: byDay[day]?.checkOutTime,
        workingHoursPerDay: settings.workingHoursPerDay,
        multiplier: settings.multiplier,
        isWorkingDay: true,
      );

      _accumulate(
        calculation,
        onAbsent: () => absentDays++,
        onOvertimeHours: (value) => overtimeHours += value,
        onOvertimeAmount: (value) => overtimeAmount += value,
        onDeductionHours: (value) => deductionHours += value,
        onDeductionAmount: (value) => lateEarlyDeductionAmount += value,
        onAbsenceDeduction: (value) => absenceDeduction += value,
      );
    }

    final totalDeductions = lateEarlyDeductionAmount + absenceDeduction;
    final netSalary = employee.salary + overtimeAmount - totalDeductions;

    return PayrollCalculationEntity(
      employeeId: employee.id,
      employeeName: employee.fullName,
      departmentId: employee.departmentId,
      basicSalary: _round(employee.salary),
      dailyRate: _round(dailyRate),
      hourlyRate: _round(hourlyRate),
      workingDays: workingDays,
      presentDays: workingDays - absentDays,
      absentDays: absentDays,
      holidayDays: holidayDays,
      overtimeHours: _round(overtimeHours),
      overtimeAmount: _round(overtimeAmount),
      deductionHours: _round(deductionHours),
      lateEarlyDeductionAmount: _round(lateEarlyDeductionAmount),
      absenceDeduction: _round(absenceDeduction),
      totalDeductions: _round(totalDeductions),
      netSalary: _round(netSalary),
      year: year,
      month: monthIndex,
    );
  }

  void _accumulate(
    AttendanceCalculationEntity calculation, {
    required void Function() onAbsent,
    required void Function(double value) onOvertimeHours,
    required void Function(double value) onOvertimeAmount,
    required void Function(double value) onDeductionHours,
    required void Function(double value) onDeductionAmount,
    required void Function(double value) onAbsenceDeduction,
  }) {
    if (calculation.isAbsent) {
      onAbsent();
      onAbsenceDeduction(calculation.absenceDeduction);
      return;
    }

    onOvertimeHours(calculation.overtimeHours);
    onOvertimeAmount(calculation.overtimeAmount);
    onDeductionHours(calculation.deductionHours);
    onDeductionAmount(calculation.deductionAmount);
  }

  Map<int, AttendanceEntity> _attendancesByDay(
    List<AttendanceEntity> attendances,
    int year,
    int month,
  ) {
    final result = <int, AttendanceEntity>{};

    for (final attendance in attendances) {
      if (attendance.attendanceDate.year != year) {
        continue;
      }

      if (attendance.attendanceDate.month != month) {
        continue;
      }

      result[attendance.attendanceDate.day] = attendance;
    }

    return result;
  }

  double _round(double value) {
    return ((value * 100) + CalculateAttendanceHoursUseCase.roundingTolerance)
            .roundToDouble() /
        100;
  }
}
