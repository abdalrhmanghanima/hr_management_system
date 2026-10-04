import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/responsive/breakpoints.dart';
import 'package:hr_management_system/core/responsive/responsive_widgets.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/core/utils/payroll_format.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/domain/payroll/entity/payroll_calculation_entity.dart';
import 'package:hr_management_system/presentation/authorization/widgets/permission_guard.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/payroll/provider/payroll_provider.dart';
import 'package:hr_management_system/presentation/payroll/provider/salary_slip_provider.dart';
import 'package:hr_management_system/presentation/payroll/screens/official_salary_slip_screen.dart';

class PayrollDetailsScreen extends ConsumerWidget {
  final String employeeId;

  const PayrollDetailsScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payrollState = ref.watch(payrollSummaryProvider(employeeId));

    return PermissionGuard(
      module: GroupModules.payroll,
      action: PermissionAction.view,
      popOnDenied: true,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(
          title: 'payroll.details_title'.tr(),
          fontSize: 18.sp,
        ),
        body: payrollState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: CustomText(
              title: 'payroll.load_failed'.tr(),
              fontColor: AppColors.red,
            ),
          ),
          data: (summary) {
            if (summary == null) {
              return Center(
                child: CustomText(
                  title: 'payroll.not_found'.tr(),
                  fontColor: AppColors.gray,
                ),
              );
            }

            final departments = ref.watch(departmentProvider).value ?? const [];
            var departmentName = '';

            for (final department in departments) {
              if (department.id == summary.departmentId) {
                departmentName = department.name;
                break;
              }
            }

            final reference = ref
                .read(buildSalarySlipUseCaseProvider)
                .referenceOf(
                  employeeId: summary.employeeId,
                  year: summary.year,
                  month: summary.month,
                );

            return _DetailsBody(
              summary: summary,
              departmentName: departmentName,
              reference: reference,
              onOpenSlip: () {
                NavigatorHandler.push(
                  OfficialSalarySlipScreen(employeeId: employeeId),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final PayrollCalculationEntity summary;
  final String departmentName;
  final String reference;
  final VoidCallback onOpenSlip;

  const _DetailsBody({
    required this.summary,
    required this.departmentName,
    required this.reference,
    required this.onOpenSlip,
  });

  static const Color _ink = Color(0xFF111827);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final egp = 'common.egp'.tr();
    final month = AppLocalization.monthYear(
      context,
      DateTime(summary.year, summary.month),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: MaxWidthBox(
        maxWidth: AppBreakpoints.documentMaxWidth,
        applyFromWidth: AppBreakpoints.desktopMinWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _card(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          title: summary.employeeName,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          fontColor: _ink,
                        ),
                        SizedBox(height: 6.h),
                        CustomText(
                          title: 'payroll.department_month'.tr(
                            namedArgs: {
                              'department': departmentName,
                              'month': month,
                            },
                          ),
                          fontSize: 13.sp,
                          fontColor: _muted,
                        ),
                        SizedBox(height: 6.h),
                        CustomText(
                          title: 'payroll.reference'.tr(
                            namedArgs: {'reference': reference},
                          ),
                          fontSize: 12.sp,
                          fontColor: _muted,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomText(
                        title: 'payroll.net_salary'.tr(),
                        fontSize: 13.sp,
                        fontColor: _muted,
                      ),
                      SizedBox(height: 2.h),
                      CustomText(
                        title: 'payroll.net_salary_value'.tr(
                          namedArgs: {
                            'net': PayrollFormat.amount(summary.netSalary),
                          },
                        ),
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        fontColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            CustomText(
              title: 'payroll.attendance_statistics'.tr(),
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),

            SizedBox(height: 12.h),

            Row(
              children: [
                _statCard(
                  label: 'payroll.attendance_days'.tr(),
                  value: '${summary.presentDays}',
                ),
                SizedBox(width: 12.w),
                _statCard(
                  label: 'payroll.absence_days'.tr(),
                  value: '${summary.absentDays}',
                ),
              ],
            ),

            SizedBox(height: 12.h),

            Row(
              children: [
                _statCard(
                  label: 'payroll.overtime_hours'.tr(),
                  value:
                      '+${'employee.hours'.tr(namedArgs: {'hours': PayrollFormat.hours(summary.overtimeHours)})}',
                  valueColor: AppColors.green,
                ),
                SizedBox(width: 12.w),
                _statCard(
                  label: 'payroll.deduction_hours'.tr(),
                  value:
                      '-${'employee.hours'.tr(namedArgs: {'hours': PayrollFormat.hours(summary.deductionHours)})}',
                  valueColor: AppColors.red,
                ),
              ],
            ),

            SizedBox(height: 16.h),

            CustomText(
              title: 'payroll.financial_breakdown'.tr(),
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),

            SizedBox(height: 12.h),

            _card(
              child: Column(
                children: [
                  _amountRow(
                    label: 'payroll.basic_salary'.tr(),
                    value: '${PayrollFormat.amount(summary.basicSalary)} $egp',
                  ),
                  _amountRow(
                    label: 'payroll.total_overtime_addition'.tr(),
                    value:
                        '+${PayrollFormat.amount(summary.overtimeAmount)} $egp',
                    valueColor: AppColors.green,
                  ),
                  _amountRow(
                    label: 'payroll.total_deduction'.tr(),
                    value:
                        '-${PayrollFormat.amount(summary.totalDeductions)} $egp',
                    valueColor: AppColors.red,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: const Divider(height: 1, color: _border),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: CustomText(
                          title: 'payroll.net_monthly_salary'.tr(),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          fontColor: _ink,
                        ),
                      ),
                      Flexible(
                        child: CustomText(
                          title: 'payroll.net_salary_value'.tr(
                            namedArgs: {
                              'net': PayrollFormat.amount(summary.netSalary),
                            },
                          ),
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          fontColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            CustomButton(
              title: 'payroll.view_print_salary_slip'.tr(),
              iconPath: AppIcons.print,
              bg: AppColors.primary,
              fontColor: AppColors.white,
              fontWeight: FontWeight.w700,
              onTap: onOpenSlip,
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            CustomText(
              title: label,
              fontSize: 12.sp,
              fontColor: _muted,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            CustomText(
              title: value,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              fontColor: valueColor ?? _ink,
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: CustomText(title: label, fontSize: 14.sp, fontColor: _muted),
          ),
          Flexible(
            child: CustomText(
              title: value,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              fontColor: valueColor ?? _ink,
            ),
          ),
        ],
      ),
    );
  }
}
