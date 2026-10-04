import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance/service/working_day_policy.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/payroll/entity/payroll_calculation_entity.dart';
import 'package:hr_management_system/domain/payroll/use_case/calculate_payroll_use_case.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/authorization/provider/module_access_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/more/provider/general_settings_provider.dart';
import 'package:hr_management_system/presentation/official_holiday/provider/official_holidays_provider.dart';

final workingDayPolicyProvider = Provider<WorkingDayPolicy>((ref) {
  return const WorkingDayPolicy();
});

final calculatePayrollUseCaseProvider = Provider<CalculatePayrollUseCase>((
  ref,
) {
  return CalculatePayrollUseCase(
    calculateAttendanceHours: ref.read(calculateAttendanceHoursUseCaseProvider),
    workingDayPolicy: ref.read(workingDayPolicyProvider),
  );
});

final currentPayrollMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();

  return DateTime(now.year, now.month);
});

final selectedPayrollMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();

  return DateTime(now.year, now.month);
});

final payrollVisibleEmployeesProvider = FutureProvider<List<EmployeeEntity>>((
  ref,
) async {
  final payrollScope = ref.watch(moduleAccessProvider(GroupModules.payroll)).scope;

  if (payrollScope.isDenied) {
    return const [];
  }

  if (payrollScope.isUnrestricted) {
    return ref.watch(employeeProvider).value ?? const <EmployeeEntity>[];
  }

  final employeeId = payrollScope.employeeId;

  if (employeeId == null || employeeId.isEmpty) {
    return const [];
  }

  try {
    final employee = await ref
        .read(getEmployeeByIdUseCaseProvider)
        .call(employeeId);

    return [employee];
  } catch (_) {
    return const [];
  }
});

final payrollSummariesProvider = FutureProvider.family<
  List<PayrollCalculationEntity>,
  DateTime
>((ref, month) async {
  final employees = await ref.watch(payrollVisibleEmployeesProvider.future);
  final attendances =
      ref.watch(attendanceProvider).value ?? const <AttendanceEntity>[];

  final settingsState = ref.watch(generalSettingsProvider);
  final settings =
      settingsState.value ??
      await ref.read(getGeneralSettingsUseCaseProvider).call();

  final holidays =
      ref.watch(officialHolidaysProvider).value ??
      const <OfficialHolidayEntity>[];

  final calculatePayroll = ref.read(calculatePayrollUseCaseProvider);
  final payrollScope = ref
      .watch(moduleAccessProvider(GroupModules.payroll))
      .scope;

  final scopedAttendances = payrollScope.applyToAttendances(attendances);

  return employees
      .map(
        (employee) => calculatePayroll.call(
          employee: employee,
          attendances: scopedAttendances,
          settings: settings,
          officialHolidays: holidays,
          month: month,
        ),
      )
      .toList();
});

final payrollSummaryProvider = FutureProvider.autoDispose
    .family<PayrollCalculationEntity?, String>((ref, employeeId) async {
      final summaries = await ref.watch(
        payrollSummariesProvider(ref.watch(selectedPayrollMonthProvider)).future,
      );

      for (final summary in summaries) {
        if (summary.employeeId == employeeId) {
          return summary;
        }
      }

      return null;
    });
