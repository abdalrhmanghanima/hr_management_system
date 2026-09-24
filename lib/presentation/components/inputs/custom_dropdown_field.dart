import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.isRequired = false,
    this.hint = 'Select',
    this.value,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          borderRadius: BorderRadius.circular(16.r),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 22.w,
            color: AppColors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.gray,
              fontSize: 12.sp,
            ),
            filled: true,
            fillColor: AppColors.backgroundColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 15.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}