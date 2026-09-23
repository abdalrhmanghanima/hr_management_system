import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class MoreOptionRow extends StatelessWidget {
  final String iconPath;
  final String title;

  const MoreOptionRow({
    super.key,
    required this.iconPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64.h,
      child: Padding(
        padding: EdgeInsets.only(left: 16.w,right: 16.w,top: 14.h,bottom: 14.h),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 28.w,
              height: 28.w,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 18.w),
            Expanded(
              child: CustomText(
                title: title,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontColor: AppColors.black,
              ),
            ),
            CustomSvgIcon(
              assetName:
              AppIcons.rightArrow,
              width: 20.w,
              height: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}