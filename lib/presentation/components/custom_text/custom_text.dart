import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../core/app_theme/text_styles.dart';

class CustomText extends StatelessWidget {
  final String? title;
  final Color fontColor;
  final double fontSize;
  final FontWeight fontWeight;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextDecoration decoration;

  const CustomText({
    super.key,
    required this.title,
    this.fontColor = AppColors.black,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.maxLines,
    this.textAlign,
    this.decoration = TextDecoration.none,
  });

  @override
  Widget build(BuildContext context) {
    return fontWeight == FontWeight.normal
        ? Text(
            title ?? '',
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
            style: AppTextStyles()
                .normalText(fontSize: fontSize, decoration: decoration)
                .textColorNormal(fontColor),
            textAlign: textAlign,
          )
        : Text(
            title ?? '',
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
            style: AppTextStyles()
                .normalText(fontSize: fontSize)
                .textColorBold(fontColor),
            textAlign: textAlign,
          );
  }
}
