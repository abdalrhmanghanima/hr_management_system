import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class EmployeeInfoRow extends StatelessWidget {
  final String icon;
  final String title;
  final String value;

  const EmployeeInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: CustomSvgIcon(
            assetName: icon,
            width: 18.w,
            height: 18.w,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                title: title,
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                fontColor: AppColors.gray,
              ),
              SizedBox(height: 4.h),
              CustomText(
                title: value,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ],
    );
  }
}