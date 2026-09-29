import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/core/utils/date_parser.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class OfficialHolidayCard extends StatelessWidget {
  final OfficialHolidayEntity holiday;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const OfficialHolidayCard({
    super.key,
    required this.holiday,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EEFF),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: CustomSvgIcon(
                assetName: AppIcons.calendar,
                width: 22.w,
                height: 22.w,
              ),
            ),
          ),

          SizedBox(width: 16.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  title: holiday.name,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  fontColor: AppColors.black,
                  maxLines: 1,
                ),

                SizedBox(height: 8.h),

                CustomText(
                  title: 'Date: ${DateParser.toIsoDate(holiday.date)}',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  fontColor: AppColors.gray,
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          IconButton(
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
              size: 25.w,
            ),
          ),

          SizedBox(width: 2.w),

          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: IconButton(
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.delete_outline,
                color: AppColors.red,
                size: 22.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
