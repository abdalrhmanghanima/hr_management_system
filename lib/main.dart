import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/firebase_options.dart';

import 'core/app_theme/theme.dart';
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
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/languages',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        saveLocale: true,
        child: const HRManagementSystemApp(),
      ),
    ),
  );
  await init();
}

class HRManagementSystemApp extends StatelessWidget {
  const HRManagementSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HR Management System',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme().themeLight(),
      home: const SplashScreen(),
    );
  }
}
