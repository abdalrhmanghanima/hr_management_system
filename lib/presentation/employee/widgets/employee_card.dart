import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class EmployeeCard extends StatelessWidget {
  final String name;
  final String group;
  final String phone;
  final String salary;
  final String workShift;
  final VoidCallback? onTap;

  const EmployeeCard({
    super.key,
    required this.name,
    required this.group,
    required this.phone,
    required this.salary,
    required this.workShift,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: Dimens.width,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 25.w,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        title: name,
                        fontColor: const Color(0xFF1E293B),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 5.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: CustomText(
                          title: group,
                          fontColor: AppColors.primary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                CustomSvgIcon(
                  assetName: AppIcons.rightArrow,
                  width: 18.w,
                  height: 18.w,
                ),
              ],
            ),

            SizedBox(height: 14.h),

            Divider(height: 1, thickness: 1, color: const Color(0xFFE2E8F0)),

            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 14.w,
                        color: const Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: CustomText(
                          title: phone,
                          fontColor: const Color(0xFF64748B),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 17.w,
                        color: const Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: CustomText(
                          title: 'Salary: $salary EGP',
                          fontColor: const Color(0xFF64748B),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 9.h),

            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 17.w,
                  color: const Color(0xFF94A3B8),
                ),
                SizedBox(width: 6.w),
                CustomText(
                  title: 'Work Shift: $workShift',
                  fontColor: const Color(0xFF64748B),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
