import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';

class AppFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 4,
      shape: const CircleBorder(),
      child: CustomSvgIcon(
        assetName: AppIcons.add,
        width: 24.w,
      ),
    );
  }
}