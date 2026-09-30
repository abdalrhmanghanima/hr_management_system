import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/firebase_options.dart';

import 'core/app_theme/theme.dart';
import 'core/localization/app_localization.dart';
import 'injection.dart';
import 'presentation/splash_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: AppLocalization.supportedLocales,
        path: AppLocalization.path,
        fallbackLocale: AppLocalization.fallbackLocale,
        startLocale: AppLocalization.en,
        saveLocale: true,
        child: const AppLocaleSync(child: HRManagementSystemApp()),
      ),
    ),
  );
  await init();
}

class AppLocaleSync extends StatelessWidget {
  final Widget child;

  const AppLocaleSync({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    AppLocalization.update(context.locale);

    return child;
  }
}

class HRManagementSystemApp extends StatelessWidget {
  const HRManagementSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => context.tr('app.name'),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalization.delegates(context),
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme().themeLight(),
      home: const SplashScreen(),
    );
  }
}
