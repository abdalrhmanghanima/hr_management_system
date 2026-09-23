import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';

class AppSearchField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const AppSearchField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: const Color(0xFF94A3B8),
          fontSize: 16.sp,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: const Color(0xFF64748B),
          size: 25.w,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.r),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.r),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.r),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}