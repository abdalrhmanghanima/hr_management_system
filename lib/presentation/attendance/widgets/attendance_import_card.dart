import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class AttendanceImportCard extends StatelessWidget {
  final VoidCallback? onChooseFile;
  final bool isChoosingFile;

  const AttendanceImportCard({
    super.key,
    this.onChooseFile,
    this.isChoosingFile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomSvgIcon(
                assetName: AppIcons.file,
                width: 26.w,
                height: 26.w,
                color: AppColors.primary,
              ),
            ),
          ),

          SizedBox(height: 14.h),

          CustomText(
            title: 'attendance_import.title'.tr(),
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            fontColor: AppColors.black,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 6.h),

          CustomText(
            title: 'attendance_import.card_description'.tr(),
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            fontColor: AppColors.gray,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16.h),

          CustomButton(
            title: 'attendance_import.choose_file'.tr(),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            bg: AppColors.primary,
            width: double.infinity,
            height: 48.h,
            radius: 14.r,
            isLoading: isChoosingFile,
            onTap: onChooseFile,
          ),
        ],
      ),
    );
  }
}
