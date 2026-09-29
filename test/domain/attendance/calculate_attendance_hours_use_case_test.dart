import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/domain/attendance/use_case/calculate_attendance_hours_use_case.dart';

void main() {
  final calculate = CalculateAttendanceHoursUseCase();

  const double salary = 5000;
  const double workingHoursPerDay = 8;
  const double multiplier = 2;

  DateTime at(int hour, int minute) {
    return DateTime(2026, 9, 28, hour, minute);
  }

  group('salary rates', () {
    test('daily rate is monthly salary divided by 30', () {
      expect(calculate.dailyRate(5000), 166.67);
    });

    test('hourly rate is daily rate divided by working hours per day', () {
      expect(calculate.hourlyRate(5000, 8), 20.83);
    });

    test('hourly rate is zero when working hours per day is not positive', () {
      expect(calculate.hourlyRate(5000, 0), 0);
    });
  });

  group('normal working day', () {
    test('09:00 to 17:00 has no deduction and no overtime', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 0),
        checkOutTime: at(17, 0),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.actualWorkedHours, 8);
      expect(result.lateHours, 0);
      expect(result.earlyCheckoutHours, 0);
      expect(result.deductionHours, 0);
      expect(result.deductionAmount, 0);
      expect(result.overtimeHours, 0);
      expect(result.overtimeAmount, 0);
      expect(result.isAbsent, isFalse);
      expect(result.isWorkingDay, isTrue);
    });
  });

  group('late check in grace threshold', () {
    test('15 minutes late has no deduction', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 15),
        checkOutTime: at(17, 0),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.lateHours, 0);
      expect(result.deductionAmount, 0);
    });

    test('29 minutes late has no deduction', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 29),
        checkOutTime: at(17, 0),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.lateHours, 0);
      expect(result.deductionAmount, 0);
    });

    test('30 minutes late applies the full lateness', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 30),
        checkOutTime: at(17, 0),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.lateHours, 0.5);
      expect(result.deductionAmount, 20.83);
    });

    test('45 minutes late is not rounded to 30 minute blocks', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 45),
        checkOutTime: at(17, 0),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.lateHours, 0.75);
      expect(result.deductionAmount, 31.25);
    });

    test('60 minutes late deducts one hour', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(10, 0),
        checkOutTime: at(17, 0),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.lateHours, 1);
      expect(result.deductionAmount, 41.66);
    });

    test('90 minutes late deducts one and a half hours', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(10, 30),
        checkOutTime: at(17, 0),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.lateHours, 1.5);
      expect(result.deductionAmount, 62.49);
    });
  });

  group('early check out', () {
    test('29 minutes early has no deduction', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 0),
        checkOutTime: at(16, 31),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.earlyCheckoutHours, 0);
      expect(result.deductionAmount, 0);
    });

    test('31 minutes early crosses the threshold', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 0),
        checkOutTime: at(16, 29),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.earlyCheckoutHours, 0.52);
      expect(result.deductionAmount, 21.66);
    });

    test('30 minutes early applies the full shortage', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 0),
        checkOutTime: at(16, 30),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.earlyCheckoutHours, 0.5);
      expect(result.deductionAmount, 20.83);
    });

    test('60 minutes early deducts one hour', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 0),
        checkOutTime: at(16, 0),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.earlyCheckoutHours, 1);
      expect(result.deductionAmount, 41.66);
    });

    test('the same shortage is not counted twice', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 30),
        checkOutTime: at(16, 30),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.lateHours, 0.5);
      expect(result.earlyCheckoutHours, 0.5);
      expect(result.deductionHours, 0.5);
      expect(result.deductionAmount, 20.83);
    });
  });

  group('overtime', () {
    test('17:15 checkout is a quarter hour of overtime', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 0),
        checkOutTime: at(17, 15),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.overtimeHours, 0.25);
      expect(result.overtimeAmount, 10.42);
    });

    test('17:30 checkout is half an hour of overtime', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 0),
        checkOutTime: at(17, 30),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.overtimeHours, 0.5);
    });

    test('18:00 checkout is one overtime hour', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 0),
        checkOutTime: at(18, 0),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.overtimeHours, 1);
    });

    test('overtime amount applies the multiplier', () {
      final halfHour = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 0),
        checkOutTime: at(17, 30),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      final fullHour = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 0),
        checkOutTime: at(18, 0),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(halfHour.overtimeAmount, 20.83);
      expect(fullHour.overtimeAmount, 41.66);
    });
  });

  group('absence', () {
    test(
      'missing attendance deducts daily rate multiplied by the multiplier',
      () {
        final result = calculate.call(
          monthlySalary: salary,
          checkInTime: null,
          checkOutTime: null,
          workingHoursPerDay: workingHoursPerDay,
          multiplier: multiplier,
        );

        expect(result.isAbsent, isTrue);
        expect(result.dailyRate, 166.67);
        expect(result.absenceDeduction, 333.34);
        expect(result.deductionAmount, 0);
      },
    );

    test('a non working day has no deduction at all', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: null,
        checkOutTime: null,
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
        isWorkingDay: false,
      );

      expect(result.isWorkingDay, isFalse);
      expect(result.isAbsent, isFalse);
      expect(result.absenceDeduction, 0);
      expect(result.deductionAmount, 0);
      expect(result.overtimeAmount, 0);
    });

    test('attendance on a non working day produces no normal deductions', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 0),
        checkOutTime: at(18, 0),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
        isWorkingDay: false,
      );

      expect(result.isWorkingDay, isFalse);
      expect(result.overtimeHours, 0);
      expect(result.overtimeAmount, 0);
      expect(result.deductionHours, 0);
      expect(result.deductionAmount, 0);
    });
  });

  group('guards', () {
    test('non positive working hours produce an empty result', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(9, 0),
        checkOutTime: at(17, 0),
        workingHoursPerDay: 0,
        multiplier: multiplier,
      );

      expect(result.actualWorkedHours, 0);
      expect(result.overtimeHours, 0);
      expect(result.deductionHours, 0);
      expect(result.hourlyRate, 0);
    });

    test('a check out before the check in never produces negative values', () {
      final result = calculate.call(
        monthlySalary: salary,
        checkInTime: at(17, 0),
        checkOutTime: at(9, 0),
        workingHoursPerDay: workingHoursPerDay,
        multiplier: multiplier,
      );

      expect(result.actualWorkedHours, 0);
      expect(result.overtimeHours, 0);
    });
  });
}
