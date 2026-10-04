import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/domain/group/entity/group_entity.dart';

class GroupCard extends StatelessWidget {
  final GroupEntity group;
  final VoidCallback onTap;

  const GroupCard({super.key, required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: CustomSvgIcon(
                  assetName: AppIcons.permission,
                  width: 26.w,
                  height: 26.w,
                ),
              ),
            ),

            SizedBox(width: 14.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    title: group.name,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontColor: AppColors.black,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    title: '${group.membersCount} Employees',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    fontColor: AppColors.primary,
                  ),
                  SizedBox(height: 3.h),
                  CustomText(
                    title: group.description,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    fontColor: AppColors.gray,
                    maxLines: 1,
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
      ),
    );
  }
}
