import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class QuickActionCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;

  const QuickActionCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.iconBackgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 83.w,
        height: 91.h,
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 16.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomSvgIcon(
                  assetName: iconPath,
                  width: 18.w,
                  height: 18.w,
                ),
              ),
            ),
            SizedBox(height: 14.h),
            CustomText(
              title: title,
              fontColor: const Color(0xFF111827),
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}