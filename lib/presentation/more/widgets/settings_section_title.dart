import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class SettingsSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const SettingsSectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title: title,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          fontColor: AppColors.black,
        ),
        SizedBox(height: 3.h),
        CustomText(
          title: subtitle,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          fontColor: AppColors.gray,
        ),
      ],
    );
  }
}
