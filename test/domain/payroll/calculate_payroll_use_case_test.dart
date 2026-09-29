import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/domain/payroll/entity/payroll_calculation_entity.dart';
import 'package:hr_management_system/domain/payroll/use_case/calculate_payroll_use_case.dart';

void main() {
  final calculate = CalculatePayrollUseCase();

  final month = DateTime(2026, 9);

  final settings = GeneralSettingsEntity(
    multiplier: 2,
    workingHoursPerDay: 8,
    weekendDays: ['Friday', 'Saturday'],
  );

  final employee = EmployeeEntity(
    id: 'EMP001',
    fullName: 'Ahmed Ali',
    address: 'Cairo',
    phoneNumber: '01000000000',
    birthDate: DateTime(1990, 1, 1),
    nationalId: '123',
    nationality: 'Egyptian',
    gender: 'Male',
    departmentId: 'DEP001',
    contractDate: DateTime(2020, 1, 1),
    salary: 5000,
  );

  final workingDays2026 = [
    1,
    2,
    3,
    6,
    7,
    8,
    9,
    10,
    13,
    14,
    15,
    16,
    17,
    20,
    21,
    22,
    23,
    24,
    27,
    28,
    29,
    30,
  ];

  AttendanceEntity presentOn(
    int day, {
    int? inHour,
    int? inMinute,
    int? outHour,
    int? outMinute,
  }) {
    final checkIn = DateTime(2026, 9, day, inHour ?? 9, inMinute ?? 0);

    final checkOut = outHour == null
        ? null
        : DateTime(2026, 9, day, outHour, outMinute ?? 0);

    return AttendanceEntity(
      id: AttendanceEntity.documentIdFor('EMP001', DateTime(2026, 9, day)),
      employeeId: 'EMP001',
      attendanceDate: DateTime(2026, 9, day),
      status: AttendanceEntity.presentStatus,
      checkInTime: checkIn,
      checkOutTime: checkOut,
    );
  }

  PayrollCalculationEntity calculateFor({
    List<AttendanceEntity> attendances = const [],
    List<OfficialHolidayEntity> officialHolidays = const [],
    GeneralSettingsEntity? customSettings,
  }) {
    return calculate.call(
      employee: employee,
      attendances: attendances,
      settings: customSettings ?? settings,
      officialHolidays: officialHolidays,
      month: month,
    );
  }

  group('working day counts', () {
    test('september 2026 has 22 working days and 8 weekend days', () {
      final result = calculateFor();

      expect(result.workingDays, 22);
      expect(result.holidayDays, 8);
    });

    test('an official holiday removes a working day', () {
      final result = calculateFor(
        officialHolidays: [
          OfficialHolidayEntity(
            id: 'holiday_1',
            name: 'Company Holiday',
            date: DateTime(2026, 9, 30),
          ),
        ],
      );

      expect(result.workingDays, 21);
      expect(result.holidayDays, 9);
    });

    test('the weekend comes from general settings', () {
      final result = calculateFor(
        customSettings: GeneralSettingsEntity(
          multiplier: 2,
          workingHoursPerDay: 8,
          weekendDays: ['Sunday'],
        ),
      );

      expect(result.holidayDays, 4);
      expect(result.workingDays, 26);
    });
  });

  group('absence', () {
    test('every working day without attendance is absent', () {
      final result = calculateFor();

      expect(result.absentDays, 22);
      expect(result.presentDays, 0);
    });

    test('absence is never charged for a weekend day', () {
      final result = calculateFor();

      expect(result.absenceDeduction, 7333.48);
    });

    test('absence is never charged for an official holiday', () {
      final withHoliday = calculateFor(
        officialHolidays: [
          OfficialHolidayEntity(
            id: 'holiday_1',
            name: 'Company Holiday',
            date: DateTime(2026, 9, 30),
          ),
        ],
      );

      expect(withHoliday.absenceDeduction, 7000.14);
    });

    test('net salary can be reduced below zero', () {
      final result = calculateFor();

      expect(result.totalDeductions, 7333.48);
      expect(result.netSalary, -2333.48);
    });

    test('a check in without a check out still counts as present', () {
      final result = calculateFor(attendances: [presentOn(1)]);

      expect(result.presentDays, 1);
      expect(result.absentDays, 21);
    });
  });

  group('late and overtime', () {
    test('a late day and an overtime day combine into the net salary', () {
      final attendances = <AttendanceEntity>[
        for (final day in workingDays2026) presentOn(day, outHour: 17),
        presentOn(1, inHour: 9, inMinute: 30, outHour: 17),
        presentOn(2, outHour: 18),
      ];

      final result = calculateFor(attendances: attendances);

      expect(result.absentDays, 0);
      expect(result.deductionHours, 0.5);
      expect(result.lateEarlyDeductionAmount, 20.83);
      expect(result.overtimeHours, 1);
      expect(result.overtimeAmount, 41.66);
      expect(result.absenceDeduction, 0);
      expect(result.totalDeductions, 20.83);
      expect(result.netSalary, 5020.83);
    });

    test('a perfect month has no deductions and no overtime', () {
      final result = calculateFor(
        attendances: [
          for (final day in workingDays2026) presentOn(day, outHour: 17),
        ],
      );

      expect(result.presentDays, 22);
      expect(result.absentDays, 0);
      expect(result.overtimeAmount, 0);
      expect(result.totalDeductions, 0);
      expect(result.netSalary, 5000);
    });

    test('attendance on a weekend day never creates overtime', () {
      final result = calculateFor(attendances: [presentOn(4, outHour: 20)]);

      expect(result.holidayDays, 8);
      expect(result.overtimeHours, 0);
      expect(result.overtimeAmount, 0);
      expect(result.absentDays, 22);
    });

    test('attendance on an official holiday never creates overtime', () {
      final result = calculateFor(
        officialHolidays: [
          OfficialHolidayEntity(
            id: 'holiday_1',
            name: 'Company Holiday',
            date: DateTime(2026, 9, 30),
          ),
        ],
        attendances: [presentOn(30, outHour: 20)],
      );

      expect(result.overtimeAmount, 0);
      expect(result.absentDays, 21);
    });

    test('the standard day length comes from general settings', () {
      final result = calculateFor(
        customSettings: GeneralSettingsEntity(
          multiplier: 2,
          workingHoursPerDay: 6,
          weekendDays: ['Friday', 'Saturday'],
        ),
        attendances: [presentOn(1, outHour: 17)],
      );

      expect(result.overtimeHours, 2);
    });
  });

  group('scoping', () {
    test('attendance from another month is ignored', () {
      final result = calculateFor(
        attendances: [
          AttendanceEntity(
            id: 'attendance_august',
            employeeId: 'EMP001',
            attendanceDate: DateTime(2026, 8, 31),
            status: AttendanceEntity.presentStatus,
            checkInTime: DateTime(2026, 8, 31, 9),
            checkOutTime: DateTime(2026, 8, 31, 18),
          ),
        ],
      );

      expect(result.absentDays, 22);
      expect(result.overtimeAmount, 0);
    });
  });

  group('summary', () {
    test('the summary carries employee identity and month label', () {
      final result = calculateFor();

      expect(result.employeeId, 'EMP001');
      expect(result.employeeName, 'Ahmed Ali');
      expect(result.departmentId, 'DEP001');
      expect(result.basicSalary, 5000);
      expect(result.dailyRate, 166.67);
      expect(result.hourlyRate, 20.83);
      expect(result.monthLabel, 'September 2026');
    });
  });
}
