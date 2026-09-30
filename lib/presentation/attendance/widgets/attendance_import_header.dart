import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class AttendanceImportHeader extends StatelessWidget {
  final String title;
  final String description;

  const AttendanceImportHeader({
    super.key,
    this.title = 'attendance_import.title',
    this.description = 'attendance_import.header_description',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title: title.tr(),
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          fontColor: AppColors.black,
        ),

        SizedBox(height: 6.h),

        CustomText(
          title: description.tr(),
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          fontColor: AppColors.gray,
        ),
      ],
    );
  }
}
