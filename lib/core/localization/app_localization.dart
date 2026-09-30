import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hr_management_system/core/constants/constants.dart';

class AppLocalization {
  const AppLocalization._();

  static const String path = 'assets/languages';
  static const Locale en = Locale('en');
  static const Locale ar = Locale('ar');
  static const List<Locale> supportedLocales = [en, ar];
  static const Locale fallbackLocale = en;

  static Locale _locale = en;

  static Locale get locale => _locale;

  static String get languageCode => _locale.languageCode;

  static bool get isArabic => _locale.languageCode == ar.languageCode;

  static bool isRtl(Locale value) {
    return value.languageCode == ar.languageCode;
  }

  static void update(Locale value) {
    _locale = value;
  }

  static List<LocalizationsDelegate<dynamic>> delegates(BuildContext context) {
    return [
      ...context.localizationDelegates,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];
  }

  static String? fontFamily() {
    return isArabic ? null : AppTextFontFamily.display;
  }

  static List<String>? fontFamilyFallback() {
    if (!isArabic) {
      return null;
    }

    return AppTextFontFamily.arabicFallback;
  }

  static TextDirection textDirectionOf(BuildContext context) {
    return isRtl(Localizations.localeOf(context))
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  static String translate(String key) {
    return tr(key);
  }

  static String translateArgs(String key, Map<String, String> args) {
    return tr(key, namedArgs: args);
  }

  static String? Function(String?) translateValidator(
    String? Function(String?) validator,
  ) {
    return (value) {
      final key = validator(value);

      if (key == null) {
        return null;
      }

      return trExists(key) ? tr(key) : key;
    };
  }

  static String gender(BuildContext context, String value) {
    return _mapped(context, 'common.gender', genderValues, value);
  }

  static String attendanceStatus(BuildContext context, String value) {
    return _mapped(
      context,
      'common.attendance_status',
      attendanceStatusValues,
      value,
    );
  }

  static String weekDay(BuildContext context, String value) {
    return _mapped(
      context,
      'common.week_day',
      weekDayNames,
      value,
    );
  }

  static String month(BuildContext context, int monthNumber) {
    final index = monthNumber - 1;

    if (index < 0 || index > 11) {
      return '$monthNumber';
    }

    return context.tr('common.month.${_keySegment(index)}');
  }

  static String monthYear(BuildContext context, DateTime value) {
    return '${month(context, value.month)} ${value.year}';
  }

  static String _mapped(
    BuildContext context,
    String keyPrefix,
    List<String> canonicalValues,
    String value,
  ) {
    final index = canonicalValues.indexOf(value);

    if (index < 0) {
      return value;
    }

    return context.tr('$keyPrefix.${_keySegment(index)}');
  }

  static String _keySegment(int index) {
    const segments = [
      'first',
      'second',
      'third',
      'fourth',
      'fifth',
      'sixth',
      'seventh',
      'eighth',
      'ninth',
      'tenth',
      'eleventh',
      'twelfth',
    ];

    return segments[index];
  }
}

class AppTextFontFamily {
  const AppTextFontFamily._();

  static const String display = 'DMSerifDisplay';

  static const List<String> arabicFallback = [
    'Noto Naskh Arabic',
    'Noto Sans Arabic',
    'Geeza Pro',
    'Tahoma',
    'Arial',
  ];
}
