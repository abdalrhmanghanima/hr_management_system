import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class PayrollCard extends StatelessWidget {
  final String employeeName;
  final String department;
  final String month;
  final String netSalary;
  final String basicSalary;
  final String attendanceAbsence;
  final String overtime;
  final String deduction;
  final VoidCallback? onDetails;
  final VoidCallback? onSalarySlip;

  const PayrollCard({
    super.key,
    required this.employeeName,
    required this.department,
    required this.month,
    required this.netSalary,
    required this.basicSalary,
    required this.attendanceAbsence,
    required this.overtime,
    required this.deduction,
    this.onDetails,
    this.onSalarySlip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title: employeeName,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      fontColor: const Color(0xFF111827),
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      title: '$department • $month',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      fontColor: const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomText(
                    title: 'Net Salary',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    fontColor: const Color(0xFF64748B),
                  ),
                  SizedBox(height: 2.h),
                  CustomText(
                    title: '$netSalary EGP',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    fontColor: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 22.h),

          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CustomText(
                      title: 'Basic',
                      fontSize: 13.sp,
                      fontColor: const Color(0xFF64748B),
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      title: basicSalary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontColor: const Color(0xFF111827),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    CustomText(
                      title: 'Att / Abs',
                      fontSize: 13.sp,
                      fontColor: const Color(0xFF64748B),
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      title: attendanceAbsence,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontColor: const Color(0xFF111827),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    CustomText(
                      title: 'Overtime',
                      fontSize: 13.sp,
                      fontColor: const Color(0xFF64748B),
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      title: overtime,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.green,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    CustomText(
                      title: 'Deduction',
                      fontSize: 13.sp,
                      fontColor: const Color(0xFF64748B),
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      title: deduction,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onDetails,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    height: 42.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.eye,
                          size: 18.w,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        CustomText(
                          title: 'Details',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          fontColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: InkWell(
                  onTap: onSalarySlip,
                  borderRadius: BorderRadius.circular(16.r),
                  child: SizedBox(
                    height: 42.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomSvgIcon(
                          assetName: AppIcons.print,
                          width: 18.w,
                          height: 18.w,
                        ),
                        SizedBox(width: 8.w),
                        CustomText(
                          title: 'Salary Slip',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          fontColor: const Color(0xFF111827),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}