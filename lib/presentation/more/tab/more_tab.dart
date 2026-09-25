import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/presentation/auth/providers/auth_state_provider.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/department/departments_screen.dart';
import 'package:hr_management_system/presentation/more/widgets/more_option_row.dart';
import 'package:hr_management_system/presentation/shared_widgets/user_avatar.dart';

class MoreTab extends ConsumerWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: CustomText(
          title: 'More',
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
            Container(
              padding: EdgeInsets.all(20.r),
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
              child: Row(
                children: [
                  const UserAvatar(),

                  SizedBox(width: 16.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          title: 'HR Administrator',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          fontColor: const Color(0xFF111827),
                        ),

                        SizedBox(height: 4.h),

                        CustomText(
                          title: user?.email??"",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          fontColor: const Color(0xFF64748B),
                        ),

                        SizedBox(height: 8.h),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF3FF),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: CustomText(
                            title: 'Role: HR',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            fontColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h,),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  MoreOptionRow(
                    iconPath: AppIcons.applicationUser,
                    title: 'Application Users',
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.border,
                  ),
                  MoreOptionRow(
                    iconPath: AppIcons.department,
                    title: 'Departments',
                    onTap: () => NavigatorHandler.push(DepartmentsScreen()),
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.border,
                  ),
                  MoreOptionRow(
                    iconPath: AppIcons.permission,
                    title: 'User Groups & Permissions',
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.border,
                  ),
                  MoreOptionRow(
                    iconPath: AppIcons.greenCalender,
                    title: 'Official Holidays',
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.border,
                  ),
                  MoreOptionRow(
                    iconPath: AppIcons.settings,
                    title: 'General System Settings',
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h,),
            Container(
              height: 54.h,
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2F2),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: const Color(0xFFFFC7C7),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.signOut,
                    width: 20.w,
                    height: 20.w,
                    colorFilter: const ColorFilter.mode(
                      AppColors.red,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: CustomText(
                      title: 'Sign Out Account',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      fontColor: AppColors.red,
                    ),
                  ),
                  SvgPicture.asset(
                    AppIcons.rightArrow,
                    width: 20.w,
                    height: 20.w,
                    colorFilter: const ColorFilter.mode(
                      AppColors.red,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}