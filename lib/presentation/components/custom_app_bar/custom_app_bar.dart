import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/resources/font_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/dimens/dimens.dart';
import '../custom_text/custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final double? fontSize;
  final Color? fontColor;
  final bool? showBackArrow;
  final bool? centerTitle;
  final List<Widget>? actions;
  final bool? showToolBar;
  final double? elevation;
  final double? leadingHeight;
  final double? leadingWidth;
  final Color? bgColor;
  final SystemUiOverlayStyle? systemUiOverlayStyle;
  final String? iconPath;
  final VoidCallback? onPressed;
  final double? spacing;

  const CustomAppBar({
    super.key,
    this.title,
    this.fontSize,
    this.fontColor,
    this.showBackArrow,
    this.centerTitle,
    this.actions,
    this.showToolBar,
    this.elevation,
    this.bgColor,
    this.systemUiOverlayStyle,
    this.iconPath,
    this.onPressed,
    this.spacing,
    this.leadingHeight,
    this.leadingWidth,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 70.w,
      titleSpacing: spacing ?? 0,
      backgroundColor: AppColors.backgroundColor,
      leading: iconPath != null
          ? Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsetsDirectional.only(start: 22.w, top: 12.h),
                width: 41.w,
                height: 41.w,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.all(9.r),
                  child: InkWell(
                    onTap: () => NavigatorHandler.pop(),
                    child: SvgPicture.asset(
                      iconPath!,
                      width: 19.w,
                      height: 19.w,
                    ),
                  ),
                ),
              ),
            )
          : null,
      elevation: elevation,
      systemOverlayStyle: systemUiOverlayStyle,
      scrolledUnderElevation: 0,
      title: Padding(
        padding: EdgeInsetsDirectional.only(start: 8.w),
        child: CustomText(
          title: title ?? '',
          fontSize: fontSize ?? AppFonts.font_18,
          fontColor: fontColor ?? AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle ?? false,
      actions: actions,
      automaticallyImplyLeading: showBackArrow ?? true,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size(Dimens.width, showToolBar == true ? 60.h : 0);
}
