import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/domain/payroll/entity/payroll_calculation_entity.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/authorization/widgets/permission_guard.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/payroll/provider/payroll_provider.dart';
import 'package:hr_management_system/presentation/payroll/widgets/payroll_card.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_search_field.dart';

class PayrollTab extends ConsumerStatefulWidget {
  const PayrollTab({super.key});

  @override
  ConsumerState<PayrollTab> createState() => _PayrollTabState();
}

class _PayrollTabState extends ConsumerState<PayrollTab> {
  final TextEditingController searchController = TextEditingController();

  String searchTerm = '';

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.read(employeeProvider.notifier).getEmployees(),
      ref.read(attendanceProvider.notifier).getAttendances(),
      ref.read(departmentProvider.notifier).getDepartments(),
    ]);
  }

  List<PayrollCalculationEntity> _filter(
    List<PayrollCalculationEntity> summaries,
  ) {
    final term = searchTerm.trim().toLowerCase();

    if (term.isEmpty) {
      return summaries;
    }

    return summaries
        .where((summary) => summary.employeeName.toLowerCase().contains(term))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final payrollState = ref.watch(payrollSummariesProvider);
    final departments = ref.watch(departmentProvider).value ?? const [];

    final departmentNames = {
      for (final department in departments) department.id: department.name,
    };

    return PermissionGuard(
      module: GroupModules.payroll,
      action: PermissionAction.view,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: CustomText(
            title: 'payroll.title'.tr(),
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            fontColor: const Color(0xFF111827),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.h),
            child: Container(height: 1.h, color: const Color(0xFFE2E8F0)),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              AppSearchField(
                hintText: 'payroll.search_hint'.tr(),
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchTerm = value;
                  });
                },
              ),
              SizedBox(height: 16.h),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _refresh(ref),
                  child: payrollState.when(
                    loading: () => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 120.h),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                    error: (error, stackTrace) => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 120.h),
                        Center(
                          child: CustomText(
                            title: 'payroll.load_failed'.tr(),
                            fontColor: AppColors.red,
                          ),
                        ),
                      ],
                    ),
                    data: (summaries) {
                      final visible = _filter(summaries);

                      if (visible.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 120.h),
                            Center(
                              child: CustomText(
                                title: searchTerm.trim().isEmpty
                                    ? 'payroll.empty'.tr()
                                    : 'payroll.empty_search'.tr(),
                                fontColor: AppColors.gray,
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.separated(
                        padding: EdgeInsets.zero,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: visible.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          final summary = visible[index];

                          return PayrollCard(
                            employeeName: summary.employeeName,
                            department:
                                departmentNames[summary.departmentId] ?? '',
                            month: summary.monthLabel,
                            netSalary: summary.netSalary.toStringAsFixed(0),
                            basicSalary: summary.basicSalary.toStringAsFixed(0),
                            attendanceAbsence:
                                '${summary.presentDays}d / ${summary.absentDays}d',
                            overtime:
                                '+${summary.overtimeAmount.toStringAsFixed(0)}',
                            deduction:
                                '-${summary.totalDeductions.toStringAsFixed(0)}',
                            onDetails: () {},
                            onSalarySlip: () {},
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
