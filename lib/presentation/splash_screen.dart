import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/utils/app_images.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_status.dart';
import 'package:hr_management_system/presentation/auth/screens/login_screen.dart';
import 'package:hr_management_system/presentation/components/custom_asset_image/custom_asset_image.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/home/home_screen.dart';

import 'auth/providers/auth_state_provider.dart';
import 'auth/providers/login_notifier.dart';
import 'authorization/provider/authorization_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  void _navigate(Widget screen) {
    Future.delayed(
      const Duration(seconds: 3),
          () {
        NavigatorHandler.pushReplacement(screen);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<User?>>(
      authStateProvider,
          (previous, next) {
        next.whenOrNull(
          data: (user) {
            if (user == null) {
              _navigate(const LoginScreen());
              return;
            }

            ref.invalidate(authorizationProvider);

            ref.read(authorizationProvider.notifier).reload().whenComplete(() {
              final status = ref.read(authorizationStatusProvider);

              if (status == AuthorizationStatus.unauthenticated ||
                  status == AuthorizationStatus.missingUserDocument) {
                _navigate(const LoginScreen());
                return;
              }

              if (status == AuthorizationStatus.inactive) {
                ref.read(authRepoProvider).logout();

                _navigate(const LoginScreen());
                return;
              }

              _navigate(const HomeScreen());
            });
          },
        );
      },
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomAssetImage(
              assetName: AppImages.appLogo,
              width: 110.w,
              height: 130.h,
            ),
            SizedBox(width: 10.w),
            CustomText(
              title: 'splash.app_name'.tr(),
              fontColor: const Color(0xFF00658A),
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
            ),
          ],
        ),
      ),
    );
  }
}