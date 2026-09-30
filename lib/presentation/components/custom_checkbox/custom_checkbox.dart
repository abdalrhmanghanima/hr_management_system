import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const CustomCheckbox({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      activeColor: AppColors.primary,
      checkColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.r),
      ),
      side: const BorderSide(
        color: AppColors.gray,
        width: 1.4,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      onChanged: onChanged == null
          ? null
          : (changed) => onChanged!(changed ?? false),
    );
  }
}
