import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border.all(
          color: AppColors.white,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Center(
        child: CustomText(
          title: 'HA',
          fontColor: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20.sp,
        ),
      ),
    );
  }
}