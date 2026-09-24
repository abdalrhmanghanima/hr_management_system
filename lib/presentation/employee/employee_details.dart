import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/employee/edit_employee.dart';
import 'package:hr_management_system/presentation/employee/widgets/employee_info_row.dart';

class EmployeeDetails extends StatelessWidget {
  const EmployeeDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: "Employee Details",
        actionIconPath: AppIcons.edit,
        actionText: "Edit",
        onActionPressed: () => NavigatorHandler.push(EditEmployee(employeeId: "")),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: Dimens.width,
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
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
                        border: Border.all(color: AppColors.white, width: 2),
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
                      title: "Ahmed Mohamed",
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
                      child: CustomText(
                        title: "Engineering",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        fontColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h,),
              CustomText(title: "Personal Information",fontSize: 16.sp,fontWeight: FontWeight.w700,),
              SizedBox(height: 12.h,),
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
                        value: "01123456789",
                      ),

                      SizedBox(height: 14.h),

                      EmployeeInfoRow(
                        icon: AppIcons.location,
                        title: "Address",
                        value: "42 Al-Ahram Street, Nasr City, Cairo",
                      ),

                      SizedBox(height: 14.h),

                      EmployeeInfoRow(
                        icon: AppIcons.calendar,
                        title: "Birth Date",
                        value: "1988-11-22",
                      ),

                      SizedBox(height: 14.h),

                      EmployeeInfoRow(
                        icon: AppIcons.nationalId,
                        title: "National ID",
                        value: "28811220104567",
                      ),

                      SizedBox(height: 14.h),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  title: "Gender",
                                  fontSize: 11.sp,
                                  fontColor: AppColors.gray,
                                  fontWeight: FontWeight.w400,
                                ),
                                SizedBox(height: 4.h),
                                CustomText(
                                  title: "Male",
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
                                  title: "Nationality",
                                  fontSize: 11.sp,
                                  fontColor: AppColors.gray,
                                  fontWeight: FontWeight.w400,
                                ),
                                SizedBox(height: 4.h),
                                CustomText(
                                  title: "Egyptian",
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h,),
              CustomText(title: "Work Information",fontSize: 16.sp,fontWeight: FontWeight.w700,),
              SizedBox(height: 12.h,),
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
                          value: "2012-07-15",
                        ),

                        SizedBox(height: 14.h),
                        EmployeeInfoRow(
                          icon: AppIcons.payrollBlue,
                          title: "Basic Monthly Salary",
                          value: "18,000 EGP",
                        ),

                        SizedBox(height: 14.h),
                        EmployeeInfoRow(
                          icon: AppIcons.clock,
                          title: "Working Hours Shift",
                          value: "09:00 - 17:00",
                        ),

                      ]
                  ),
              )
              ),
              SizedBox(height: 24.h,),
              CustomButton(title: "Delete Employee", onTap: () {

              },
              bg: AppColors.red,
                fontSize: 15.sp,

              )
            ],
          ),
        ),
      ),
    );
  }
}
