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
import 'package:hr_management_system/core/utils/date_parser.dart';
import 'package:hr_management_system/core/utils/delete_confirmation_dialog.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_status.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/authorization/widgets/permission_guard.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/department/provider/department_by_id_provider.dart';
import 'package:hr_management_system/presentation/employee/edit_employee.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_details_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/employee/widgets/attendance_quick_actions.dart';
import 'package:hr_management_system/presentation/employee/widgets/employee_info_row.dart';

class EmployeeDetails extends ConsumerWidget {
  final String employeeId;

  const EmployeeDetails({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authorizationStatusProvider);

    if (status == AuthorizationStatus.loading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final canViewEmployees = ref.watch(
      modulePermissionProvider((
        module: GroupModules.employees,
        action: PermissionAction.view,
      )),
    );
    final canViewOwnProfile = ref.watch(
      modulePermissionProvider((
        module: GroupModules.profile,
        action: PermissionAction.view,
      )),
    );
    final isOwnProfile = ref.watch(currentEmployeeIdProvider) == employeeId;

    if (!canViewEmployees && !(canViewOwnProfile && isOwnProfile)) {
      return AuthorizationDeniedView(
        message: 'employee.profile_denied'.tr(),
      );
    }

    final employeeState = ref.watch(employeeDetailsProvider(employeeId));

    final canEditEmployees = ref.watch(
      modulePermissionProvider((
        module: GroupModules.employees,
        action: PermissionAction.edit,
      )),
    );
    final canDeleteEmployees = ref.watch(
      modulePermissionProvider((
        module: GroupModules.employees,
        action: PermissionAction.delete,
      )),
    );
    final canAddAttendance = ref.watch(
      modulePermissionProvider((
        module: GroupModules.attendance,
        action: PermissionAction.add,
      )),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: "employee.details_title".tr(),
        actionIconPath: AppIcons.edit,
        actionText: "common.edit".tr(),
        onActionPressed: canEditEmployees
            ? () => NavigatorHandler.push(EditEmployee(employeeId: employeeId))
            : null,
      ),
      body: employeeState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: CustomText(title: error.toString(), fontColor: AppColors.red),
        ),
        data: (employee) {
          final departmentState = ref.watch(
            departmentByIdProvider(employee.departmentId),
          );
          return Padding(
            padding: EdgeInsets.all(16.r),
            child: SingleChildScrollView(
              child: MaxWidthBox(
                maxWidth: AppBreakpoints.detailsContentMaxWidth,
                applyFromWidth: AppBreakpoints.desktopMinWidth,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 24.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72.w,
                          height: 72.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: CustomSvgIcon(
                              assetName: AppIcons.person,
                              width: 40.w,
                              height: 40.w,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        CustomText(
                          title: employee.fullName,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          fontColor: AppColors.black,
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: departmentState.when(
                            loading: () => SizedBox(
                              width: 80.w,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            error: (error, stackTrace) => CustomText(
                              title: "common.unknown_department".tr(),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              fontColor: AppColors.primary,
                            ),
                            data: (department) {
                              return CustomText(
                                title: department.name,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                fontColor: AppColors.primary,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  CustomText(
                    title: "employee.personal_information".tr(),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          EmployeeInfoRow(
                            icon: AppIcons.phone,
                            title: "employee.field.phone_number".tr(),
                            value: employee.phoneNumber,
                          ),
                          SizedBox(height: 14.h),
                          EmployeeInfoRow(
                            icon: AppIcons.location,
                            title: "employee.field.address".tr(),
                            value: employee.address,
                          ),
                          SizedBox(height: 14.h),
                          EmployeeInfoRow(
                            icon: AppIcons.calendar,
                            title: "employee.field.birth_date".tr(),
                            value: DateParser.toDisplayDate(employee.birthDate),
                          ),
                          SizedBox(height: 14.h),
                          EmployeeInfoRow(
                            icon: AppIcons.nationalId,
                            title: "employee.field.national_id".tr(),
                            value: employee.nationalId,
                          ),
                          SizedBox(height: 14.h),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      title: "employee.field.gender".tr(),
                                      fontSize: 11.sp,
                                      fontColor: AppColors.gray,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    SizedBox(height: 4.h),
                                    CustomText(
                                      title: AppLocalization.gender(
                                        context,
                                        employee.gender,
                                      ),
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      title: "employee.field.nationality".tr(),
                                      fontSize: 11.sp,
                                      fontColor: AppColors.gray,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    SizedBox(height: 4.h),
                                    CustomText(
                                      title: employee.nationality,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  CustomText(
                    title: "employee.work_information".tr(),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          EmployeeInfoRow(
                            icon: AppIcons.bag,
                            title: "employee.field.contract_date".tr(),
                            value: DateParser.toDisplayDate(
                              employee.contractDate,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          EmployeeInfoRow(
                            icon: AppIcons.payrollBlue,
                            title: "employee.field.salary".tr(),
                            value:
                                "${employee.salary.toStringAsFixed(0)} ${'common.egp'.tr()}",
                          ),
                          SizedBox(height: 14.h),
                          EmployeeInfoRow(
                            icon: AppIcons.clock,
                            title: "common.working_shift".tr(),
                            value: "common.working_shift".tr(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  if (canAddAttendance) ...[
                    AttendanceQuickActions(
                      employeeId: employee.id,
                      monthlySalary: employee.salary,
                    ),
                    SizedBox(height: 24.h),
                  ],
                  if (canDeleteEmployees)
                    CustomButton(
                      title: "employee.delete_title".tr(),
                      isLoading: employeeState.isLoading,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return DeleteConfirmationDialog(
                              title: "employee.delete_title".tr(),
                              message: "employee.delete_confirmation".tr(),
                              isLoading: employeeState.isLoading,
                              onDelete: () async {
                                await ref
                                    .read(employeeProvider.notifier)
                                    .deleteEmployee(employeeId);

                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }

                                if (context.mounted) {
                                  NavigatorHandler.pop();
                                }
                              },
                            );
                          },
                        );
                      },
                      bg: AppColors.red,
                      fontSize: 15.sp,
                    ),
                ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

