import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this.data);

  final Map<String, Map<String, dynamic>> data;

  @override
  Future<Map<String, dynamic>?> load(String basePath, Locale locale) async {
    return data[locale.languageCode];
  }
}

Map<String, Map<String, dynamic>> _loadTranslations() {
  final result = <String, Map<String, dynamic>>{};

  for (final entry in Directory('assets/languages').listSync()) {
    if (entry is! File || !entry.path.endsWith('.json')) {
      continue;
    }

    final code = entry.uri.pathSegments.last.replaceAll('.json', '');
    result[code] = json.decode(entry.readAsStringSync()) as Map<String, dynamic>;
  }

  return result;
}

class TestApp extends StatelessWidget {
  final Widget home;
  final GlobalKey<NavigatorState>? navigatorKey;
  final Locale locale;

  const TestApp({
    super.key,
    required this.home,
    this.navigatorKey,
    this.locale = AppLocalization.en,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalization.delegates(context),
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: home,
    );
  }
}

Widget wrapWithLocalization(
  Widget child, {
  Locale locale = AppLocalization.en,
}) {
  return EasyLocalization(
    path: AppLocalization.path,
    supportedLocales: AppLocalization.supportedLocales,
    fallbackLocale: AppLocalization.fallbackLocale,
    startLocale: locale,
    saveLocale: false,
    assetLoader: _InMemoryAssetLoader(_loadTranslations()),
    child: child,
  );
}

Future<void> pumpLocalized(
  WidgetTester tester,
  Widget home, {
  GlobalKey<NavigatorState>? navigatorKey,
  Locale locale = AppLocalization.en,
}) async {
  await tester.pumpWidget(
    wrapWithLocalization(
      TestApp(home: home, navigatorKey: navigatorKey, locale: locale),
      locale: locale,
    ),
  );
  await tester.pumpAndSettle();
}
