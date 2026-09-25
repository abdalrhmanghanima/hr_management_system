import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/core/utils/date_parser.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/department/provider/department_by_id_provider.dart';
import 'package:hr_management_system/presentation/employee/edit_employee.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_details_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/employee/widgets/employee_info_row.dart';

class EmployeeDetails extends ConsumerWidget {
  final String employeeId;

  const EmployeeDetails({
    super.key,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeState = ref.watch(
      employeeDetailsProvider(employeeId),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: "Employee Details",
        actionIconPath: AppIcons.edit,
        actionText: "Edit",
        onActionPressed: () => NavigatorHandler.push(
          EditEmployee(
            employeeId: employeeId,
          ),
        ),
      ),
      body: employeeState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: CustomText(
            title: error.toString(),
            fontColor: AppColors.red,
          ),
        ),
        data: (employee) {
          final departmentState = ref.watch(
            departmentByIdProvider(employee.departmentId),
          );
          return Padding(
            padding: EdgeInsets.all(16.r),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: Dimens.width,
                    padding: EdgeInsets.symmetric(
                      vertical: 24.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
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
                            color: AppColors.primary.withValues(
                              alpha: 0.08,
                            ),
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
                              title: 'Unknown Department',
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
                    title: "Personal Information",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: Dimens.width,
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
                            title: "Phone Number",
                            value: employee.phoneNumber,
                          ),
                          SizedBox(height: 14.h),
                          EmployeeInfoRow(
                            icon: AppIcons.location,
                            title: "Address",
                            value: employee.address,
                          ),
                          SizedBox(height: 14.h),
                          EmployeeInfoRow(
                            icon: AppIcons.calendar,
                            title: "Birth Date",
                            value: DateParser.toDisplayDate(
                              employee.birthDate,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          EmployeeInfoRow(
                            icon: AppIcons.nationalId,
                            title: "National ID",
                            value: employee.nationalId,
                          ),
                          SizedBox(height: 14.h),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      title: "Gender",
                                      fontSize: 11.sp,
                                      fontColor: AppColors.gray,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    SizedBox(height: 4.h),
                                    CustomText(
                                      title: employee.gender,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      title: "Nationality",
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
                    title: "Work Information",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: Dimens.width,
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
                            title: "Contract Date",
                            value: DateParser.toDisplayDate(
                              employee.contractDate,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          EmployeeInfoRow(
                            icon: AppIcons.payrollBlue,
                            title: "Basic Monthly Salary",
                            value:
                            "${employee.salary.toStringAsFixed(0)} EGP",
                          ),
                          SizedBox(height: 14.h),
                          EmployeeInfoRow(
                            icon: AppIcons.clock,
                            title: "Working Hours Shift",
                            value: "09:00 - 17:00",
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  CustomButton(
                    title: "Delete Employee",
                    isLoading: employeeState.isLoading,
                    onTap: () async {
                      await ref
                          .read(employeeProvider.notifier)
                          .deleteEmployee(employeeId);

                      if (context.mounted) {
                        NavigatorHandler.pop();
                      }
                    },
                    bg: AppColors.red,
                    fontSize: 15.sp,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}