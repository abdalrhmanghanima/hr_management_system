import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';
import 'package:flutter/material.dart';

String get currentLang => AppLocalization.languageCode;

class AppTextStyles {
  static const String fontFamily = AppTextFontFamily.display;

  static String? get resolvedFontFamily => AppLocalization.fontFamily();

  static List<String>? get resolvedFontFamilyFallback =>
      AppLocalization.fontFamilyFallback();

  TextStyle normalText({
    double fontSize = 14,
    TextDecoration decoration = TextDecoration.none,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: resolvedFontFamily,
      fontFamilyFallback: resolvedFontFamilyFallback,
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
      fontFamily: resolvedFontFamily,
      fontFamilyFallback: resolvedFontFamilyFallback,
      decoration: decoration,
      decorationColor: AppColors.gray,
      fontStyle: FontStyle.italic,
    );
  }
}

extension TextStyleExtension on TextStyle {
  TextStyle textColorNormal(Color color) => copyWith(
    color: color,
    fontFamily: AppTextStyles.resolvedFontFamily,
    fontFamilyFallback: AppTextStyles.resolvedFontFamilyFallback,
  );

  TextStyle textColorBold(Color color) => copyWith(
    color: color,
    fontFamily: AppTextStyles.resolvedFontFamily,
    fontFamilyFallback: AppTextStyles.resolvedFontFamilyFallback,
    fontWeight: FontWeight.bold,
  );

  TextStyle textColorNormalDecoration(
      Color color,
      Color decoration,
      ) =>
      copyWith(
        color: color,
        fontFamily: AppTextStyles.resolvedFontFamily,
        fontFamilyFallback: AppTextStyles.resolvedFontFamilyFallback,
        decorationColor: decoration,
        decoration: TextDecoration.underline,
      );

  TextStyle textColorBoldDecoration(
      Color color,
      Color decoration,
      ) =>
      copyWith(
        color: color,
        fontFamily: AppTextStyles.resolvedFontFamily,
        fontFamilyFallback: AppTextStyles.resolvedFontFamilyFallback,
        fontWeight: FontWeight.bold,
        decorationColor: decoration,
        decoration: TextDecoration.underline,
      );
}