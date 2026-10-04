import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';
import 'package:hr_management_system/core/utils/payroll_format.dart';
import 'package:hr_management_system/data/payroll/repository/salary_slip_pdf_repository_impl.dart';
import 'package:hr_management_system/domain/payroll/entity/salary_slip_entity.dart';
import 'package:hr_management_system/domain/payroll/entity/salary_slip_texts.dart';
import 'package:hr_management_system/domain/payroll/repository/salary_slip_pdf_repository.dart';
import 'package:hr_management_system/domain/payroll/use_case/build_salary_slip_use_case.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/payroll/provider/payroll_provider.dart';

final buildSalarySlipUseCaseProvider = Provider<BuildSalarySlipUseCase>((ref) {
  return const BuildSalarySlipUseCase();
});

final salarySlipPdfRepositoryProvider = Provider<SalarySlipPdfRepository>((
  ref,
) {
  return SalarySlipPdfRepositoryImpl();
});

final salarySlipActionInProgressProvider = StateProvider<bool>((ref) => false);

final salarySlipEntityProvider = FutureProvider.autoDispose
    .family<SalarySlipEntity?, String>((ref, employeeId) async {
      final payroll = await ref.watch(
        payrollSummaryProvider(employeeId).future,
      );

      if (payroll == null) {
        return null;
      }

      final departments = ref.watch(departmentProvider).value ?? const [];
      var departmentName = '';

      for (final department in departments) {
        if (department.id == payroll.departmentId) {
          departmentName = department.name;
          break;
        }
      }

      return ref
          .read(buildSalarySlipUseCaseProvider)
          .call(payroll: payroll, departmentName: departmentName);
    });

SalarySlipDocument buildSalarySlipDocument(
  SalarySlipEntity slip, {
  required bool rtl,
}) {
  final overtimeLabel =
      '${'payroll.overtime'.tr()} (${'employee.hours'.tr(
        namedArgs: {'hours': PayrollFormat.hours(slip.overtimeHours)},
      )})';
  final deductionLabel =
      '${'payroll.deductions'.tr()} (${'employee.hours'.tr(
        namedArgs: {'hours': PayrollFormat.hours(slip.deductionHours)},
      )})';

  final lines = [
    SalarySlipLine(
      label: 'payroll.basic_salary'.tr(),
      value: PayrollFormat.amount(slip.basicSalary),
    ),
    SalarySlipLine(
      label: 'payroll.attendance_work_days'.tr(),
      value: 'payroll.days_value'.tr(
        namedArgs: {'count': '${slip.presentDays}'},
      ),
    ),
    SalarySlipLine(
      label: 'payroll.absence_days'.tr(),
      value: 'payroll.days_value'.tr(namedArgs: {'count': '${slip.absentDays}'}),
    ),
    SalarySlipLine(
      label: overtimeLabel,
      value: PayrollFormat.signed(slip.overtimeAmount),
    ),
    SalarySlipLine(
      label: deductionLabel,
      value: PayrollFormat.signed(-slip.totalDeductions),
    ),
  ];

  return SalarySlipDocument(
    slip: slip,
    texts: SalarySlipTexts(
      appName: 'app.name'.tr(),
      confidentialTitle: 'payroll.confidential_pay_slip'.tr(),
      employeeNameLabel: 'payroll.employee_name'.tr(),
      departmentLabel: 'employee.field.department'.tr(),
      monthLabel: 'payroll.month_label'.tr(),
      referenceLabel: 'payroll.reference_label'.tr(),
      descriptionLabel: 'payroll.description'.tr(),
      amountLabel: 'payroll.amount_header'.tr(),
      stampLabel: 'payroll.authorized_digital_stamp'.tr(),
      approvedLabel: 'payroll.hr_approved_verified'.tr(),
      pageLabel: 'payroll.page_of'.tr(),
    ),
    lines: lines,
    netLine: SalarySlipLine(
      label: 'payroll.net_transfer_salary'.tr(),
      value: 'payroll.net_salary_value'.tr(
        namedArgs: {'net': PayrollFormat.amount(slip.netSalary)},
      ),
    ),
    periodValue: AppLocalization.monthYearValue(slip.year, slip.month),
    rtl: rtl,
  );
}
