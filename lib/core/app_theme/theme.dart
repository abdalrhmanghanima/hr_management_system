import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';
import 'package:hr_management_system/core/utils/preferences.dart';
import 'package:flutter/material.dart';
class AppTheme {
  static const String fontFamily = AppTextFontFamily.display;

  static bool isDarkMode() {
    Preferences preferences = Preferences();
    return preferences.isDarkMode();
  }

  ThemeData themeLight() {
    final fontFamily = AppLocalization.fontFamily();
    final fontFamilyFallback = AppLocalization.fontFamilyFallback();

    final baseTextTheme = Typography.material2021().black.apply(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
    );

    return ThemeData(
        brightness:  Brightness.light,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        textTheme: baseTextTheme,
        primaryColor: AppColors.primary,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        scaffoldBackgroundColor: AppColors.white,
        canvasColor: AppColors.white,
        textSelectionTheme:  const TextSelectionThemeData(cursorColor: AppColors.primary,selectionHandleColor: AppColors.primary,selectionColor: AppColors.primary),
        cardTheme: const CardThemeData(surfaceTintColor: Colors.transparent),
        bottomSheetTheme:  BottomSheetThemeData(backgroundColor:Colors.white,surfaceTintColor: Colors.transparent,shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r),topRight: Radius.circular(24.r)))),
      dialogTheme: DialogThemeData(backgroundColor: AppColors.white),


    );
  }
}
