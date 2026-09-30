import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/domain/application_user/entity/application_user_entity.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class ApplicationUserCard extends StatelessWidget {
  final ApplicationUserEntity applicationUser;
  final String employeeName;
  final String groupName;
  final bool canEdit;
  final bool canChangeStatus;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onStatusChanged;

  const ApplicationUserCard({
    super.key,
    required this.applicationUser,
    this.employeeName = '',
    this.groupName = '',
    this.canEdit = false,
    this.canChangeStatus = false,
    this.onTap,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = applicationUser.isActive;

    return InkWell(
      onTap: canEdit ? onTap : null,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: CustomSvgIcon(
                  assetName: AppIcons.applicationUser,
                  width: 22.w,
                  height: 22.h,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    title: applicationUser.email.isEmpty
                        ? 'No email'
                        : applicationUser.email,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontColor: AppColors.black,
                    maxLines: 1,
                  ),

                  SizedBox(height: 4.h),

                  CustomText(
                    title: subtitle(),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    fontColor: AppColors.gray,
                    maxLines: 1,
                  ),

                  SizedBox(height: 6.h),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFEAF3FF)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: CustomText(
                      title: isActive ? 'Active' : 'Inactive',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      fontColor: isActive ? AppColors.primary : AppColors.gray,
                    ),
                  ),
                ],
              ),
            ),

            if (canChangeStatus)
              Switch(
                value: isActive,
                onChanged: onStatusChanged,
                activeThumbColor: AppColors.white,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: AppColors.white,
                inactiveTrackColor: AppColors.gray,
              ),
          ],
        ),
      ),
    );
  }

  String subtitle() {
    final parts = <String>[];

    if (employeeName.isNotEmpty) {
      parts.add(employeeName);
    }

    parts.add(groupName.isEmpty ? 'No group' : groupName);

    return parts.join(' - ');
  }
}
