import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_status.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class AuthorizationDeniedView extends StatelessWidget {
  final String message;

  const AuthorizationDeniedView({
    super.key,
    this.message = 'You do not have access to this section.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: CustomText(
            title: message,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            fontColor: AppColors.gray,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class PermissionGuard extends ConsumerWidget {
  final GroupModule module;
  final PermissionAction action;
  final Widget child;
  final String deniedMessage;
  final bool popOnDenied;

  const PermissionGuard({
    super.key,
    required this.module,
    required this.action,
    required this.child,
    this.deniedMessage = 'You do not have access to this section.',
    this.popOnDenied = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authorizationStatusProvider);

    if (status == AuthorizationStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final granted = ref.watch(
      modulePermissionProvider((module: module, action: action)),
    );

    if (granted) return child;

    if (popOnDenied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }

    return AuthorizationDeniedView(message: deniedMessage);
  }
}
