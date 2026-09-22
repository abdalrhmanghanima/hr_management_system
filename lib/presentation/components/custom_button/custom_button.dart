import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/custom_loading.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import '../../../core/dimens/dimens.dart';
import '../custom_text/custom_text.dart';
import 'dart:async';

class CustomButton extends StatelessWidget {
  final String title;
  final double? fontSize;
  final Color? fontColor;
  final FontWeight? fontWeight;
  final Color? bg;
  final FutureOr<void> Function()? onTap;
  final double? width;
  final double? height;
  final double? radius;
  final double? elevation;

  final bool isLoading;

  const CustomButton({
    super.key,
    required this.title,
    this.fontSize,
    this.fontWeight,
    this.fontColor,
    this.bg,
    required this.onTap,
    this.width,
    this.height,
    this.radius,
    this.elevation,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: isLoading ? null : onTap,
      child: Container(
        width: width ?? Dimens.width,
        height: height ?? 56.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius ?? 14.r),
        ),
        child: isLoading
            ? const CustomLoading()
            : CustomText(
          title: title,
          fontSize: fontSize ?? 15.sp,
          fontColor: fontColor ?? AppColors.white,
          fontWeight: fontWeight ?? FontWeight.normal,
        ),
      ),
    );
  }
}