import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_checkbox/custom_checkbox.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class PermissionRow extends StatelessWidget {
  final String label;
  final bool isGranted;
  final ValueChanged<bool>? onChanged;

  const PermissionRow({
    super.key,
    required this.label,
    required this.isGranted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              title: label,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
            ),
          ),
          CustomCheckbox(value: isGranted, onChanged: onChanged),
        ],
      ),
    );
  }
}
