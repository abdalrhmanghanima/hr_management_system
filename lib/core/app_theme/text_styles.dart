import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

String get currentLang =>
    navigatorKey.currentContext?.locale.languageCode ?? 'ar';

class AppTextStyles {
  static const String fontFamily = 'DMSerifDisplay';

  TextStyle normalText({
    double fontSize = 14,
    TextDecoration decoration = TextDecoration.none,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: fontFamily,
      decoration: decoration,
      decorationColor: AppColors.gray,
    );
  }

  TextStyle italicText({
    double fontSize = 14,
    TextDecoration decoration = TextDecoration.none,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontStyle: FontStyle.italic,
      decoration: decoration,
      decorationColor: AppColors.gray,
    );
  }
}

extension TextStyleExtension on TextStyle {
  TextStyle textColorNormal(Color color) => copyWith(
    color: color,
    fontFamily: AppTextStyles.fontFamily,
  );

  TextStyle textColorBold(Color color) => copyWith(
    color: color,
    fontFamily: AppTextStyles.fontFamily,
    fontWeight: FontWeight.bold,
  );

  TextStyle textColorNormalDecoration(
      Color color,
      Color decoration,
      ) =>
      copyWith(
        color: color,
        fontFamily: AppTextStyles.fontFamily,
        decorationColor: decoration,
        decoration: TextDecoration.underline,
      );

  TextStyle textColorBoldDecoration(
      Color color,
      Color decoration,
      ) =>
      copyWith(
        color: color,
        fontFamily: AppTextStyles.fontFamily,
        fontWeight: FontWeight.bold,
        decorationColor: decoration,
        decoration: TextDecoration.underline,
      );
}