import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/resources/font_size.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import '../custom_text/custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final double? fontSize;
  final Color? fontColor;

  final bool showBackArrow;
  final bool centerTitle;

  final List<Widget>? actions;

  final String? actionIconPath;
  final String? actionText;
  final VoidCallback? onActionPressed;

  final Color? bgColor;
  final SystemUiOverlayStyle? systemUiOverlayStyle;
  final VoidCallback? onPressed;

  final double? elevation;
  final double? spacing;

  const CustomAppBar({
    super.key,
    this.title,
    this.fontSize,
    this.fontColor,
    this.showBackArrow = true,
    this.centerTitle = false,
    this.actions,
    this.actionIconPath,
    this.actionText,
    this.onActionPressed,
    this.bgColor,
    this.systemUiOverlayStyle,
    this.onPressed,
    this.elevation,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: bgColor ?? AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: elevation ?? 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: systemUiOverlayStyle,

      automaticallyImplyLeading: false,

      leading: showBackArrow
          ? IconButton(
        onPressed: onPressed ?? () => Navigator.pop(context),
        padding: EdgeInsets.zero,
        icon: SvgPicture.asset(
          AppIcons.leftArrow,
          width: 22.w,
          height: 22.w,
        ),
      )
          : null,

      titleSpacing: spacing ?? 0,

      title: CustomText(
        title: title ?? '',
        fontSize: fontSize ?? AppFonts.font_18,
        fontColor: fontColor ?? AppColors.black,
        fontWeight: FontWeight.bold,
      ),

      centerTitle: centerTitle,

      actions: [
        if (actionText != null || actionIconPath != null)
          InkWell(
            onTap: onActionPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (actionIconPath != null) ...[
                    SvgPicture.asset(
                      actionIconPath!,
                      width: 16.w,
                    ),
                    if (actionText != null)
                      SizedBox(width: 4.w),
                  ],
                  if (actionText != null)
                    CustomText(
                      title: actionText!,
                      fontSize: 16.sp,
                      fontColor: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                ],
              ),
            ),
          ),

        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}