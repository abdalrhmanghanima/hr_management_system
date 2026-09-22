import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/core/utils/app_images.dart';
import 'package:hr_management_system/domain/auth/entity/user_entity.dart';
import 'package:hr_management_system/presentation/auth/providers/login_provider.dart';
import 'package:hr_management_system/presentation/auth/providers/password_visibility_provider.dart';
import 'package:hr_management_system/presentation/components/custom_asset_image/custom_asset_image.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_snack_bar/custom_snack_bar.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/components/inputs/custom_text_form.dart';
import 'package:hr_management_system/presentation/home/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    ref.listenManual<AsyncValue<UserEntity?>>(loginProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) {
            NavigatorHandler.pushAndRemoveUntil(HomeScreen());
          }
        },
        error: (error, stackTrace) {
          debugPrint('LOGIN ERROR TYPE: ${error.runtimeType}');
          debugPrint('LOGIN ERROR: $error');

          if (error is FirebaseAuthException) {
            debugPrint('FIREBASE CODE: ${error.code}');
            debugPrint('FIREBASE MESSAGE: ${error.message}');
          }

          String message = 'An error occurred while signing in';

          if (error is FirebaseAuthException) {
            switch (error.code) {
              case 'invalid-credential':
              case 'user-not-found':
              case 'wrong-password':
                message = 'Incorrect email or password';
                break;

              case 'invalid-email':
                message = 'Invalid email address';
                break;

              case 'operation-not-allowed':
                message = 'Email/password sign-in is not enabled';
                break;

              case 'network-request-failed':
                message = 'Please check your internet connection and try again';
                break;

              case 'too-many-requests':
                message = 'Too many attempts. Please try again later';
                break;

              default:
                message = 'Firebase error: ${error.code}';
            }
          }

          CustomSnackBar.show(
            context,
            message: message,
          );
        },
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 90.h, bottom: 35.h),
                  child: SizedBox(
                    width: Dimens.width,
                    child: Column(
                      children: [
                        CustomAssetImage(
                          assetName: AppImages.appLogo,
                          width: 80.w,
                          height: 80.w,
                        ),
                        SizedBox(height: 4.h),
                        CustomText(
                          title: "Human Resources Management System",
                          fontWeight: FontWeight.w600,
                          fontColor: AppColors.gray,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: Dimens.width,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          title: "Welcome back",
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        SizedBox(height: 4.h),
                        CustomText(
                          title: "Sign in to access your HR portal",
                          fontSize: 13.sp,
                          fontColor: AppColors.gray,
                          fontWeight: FontWeight.w700,
                        ),
                        SizedBox(height: 12.h),
                        CustomTextFormField(
                          controller: emailController,
                          label: 'Email',
                          isRequired: true,
                          prefix: Padding(
                            padding: EdgeInsets.all(14.r),
                            child: CustomSvgIcon(
                              assetName: AppIcons.person,
                              width: 18.w,
                              height: 21.h,
                            ),
                          ),
                          hint: "ENTER YOUR EMAIL",
                          validator: (value) {
                            final email = value?.trim() ?? '';

                            if (email.isEmpty) {
                              return "Email is required";
                            }

                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(email)) {
                              return "Please enter a valid email address";
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 14.h),
                        CustomTextFormField(
                          controller: passwordController,
                          label: 'Password',
                          isRequired: true,
                          obscureText: ref.watch(passwordVisibilityProvider)
                              ? false
                              : true,
                          suffix: Padding(
                            padding: EdgeInsets.all(14.r),
                            child: InkWell(
                              onTap: () {
                                ref
                                    .read(passwordVisibilityProvider.notifier)
                                    .state = !ref.read(
                                  passwordVisibilityProvider,
                                );
                              },
                              child: Icon(
                                ref.watch(passwordVisibilityProvider)
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                              ),
                            ),
                          ),
                          hint: "ENTER YOUR Password",
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Password is required";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24.h),
                        CustomButton(
                          title: "Sign in",
                          fontWeight: FontWeight.w400,
                          bg: AppColors.primary,
                          isLoading: loginState.isLoading,
                          onTap: () async {
                            if (!formKey.currentState!.validate()) return;
                            await ref
                                .read(loginProvider.notifier)
                                .login(
                                  email: emailController.text,
                                  password: passwordController.text,
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
