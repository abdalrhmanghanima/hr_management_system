import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/app_theme/text_styles.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hint;
  final TextInputType? textInputType;
  final TextEditingController controller;
  final String? label;
  final bool isRequired;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;

  final bool readOnly;
  final Color? bgColor;
  final double? borderRadius;

  final ValueChanged<String>? onChange;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    required this.controller,
    this.hint,
    this.textInputType,
    this.label,
    this.isRequired = false,
    this.prefix,
    this.suffix,
    this.readOnly = false,
    this.bgColor,
    this.borderRadius,
    this.onChange,
    this.focusNode,
    this.onTap,
    this.validator,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 14.r;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: AppTextStyles()
                      .normalText(fontSize: 13.sp)
                      .textColorNormal(AppColors.black),
                ),
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: AppTextStyles()
                        .normalText()
                        .textColorNormal(AppColors.red),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],

        TextFormField(
          obscureText: obscureText,
          controller: controller,
          focusNode: focusNode,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChange,
          validator: validator,
          keyboardType: textInputType ?? TextInputType.text,
          cursorColor: AppColors.primary,
          textAlignVertical: TextAlignVertical.center,
          style: AppTextStyles()
              .normalText()
              .textColorNormal(AppColors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles()
                .normalText()
                .textColorNormal(AppColors.gray),

            filled: true,
            fillColor: bgColor ?? AppColors.backgroundColor,

            prefixIcon: prefix,
            suffixIcon: suffix,

            prefixIconConstraints: BoxConstraints(
              minWidth: 48.w,
              maxWidth: 56.w,
              minHeight: 56.h,
              maxHeight: 56.h,
            ),

            suffixIconConstraints: BoxConstraints(
              minWidth: 48.w,
              maxWidth: 56.w,
              minHeight: 56.h,
              maxHeight: 56.h,
            ),

            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimens.padding_16h,
              vertical: 16.h,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: AppColors.border,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: AppColors.border,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: AppColors.red,
              ),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: AppColors.red,
                width: 1.5,
              ),
            ),

            errorStyle: AppTextStyles()
                .normalText()
                .textColorNormal(AppColors.red)
                .copyWith(
              fontSize: 12.sp,
              height: 1.2,
            ),

            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}