import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';

class DashboardSummaryCard extends StatelessWidget {
  final String iconPath;
  final String value;
  final String title;
  final String topText;
  final Color topTextColor;

  const DashboardSummaryCard({
    super.key,
    required this.iconPath,
    required this.value,
    required this.title,
    required this.topText,
    required this.topTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: CustomSvgIcon(
                    assetName: iconPath,
                    width: 18.w,
                    height: 18.w,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Text(
                    topText,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: topTextColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              height: 0.95,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}