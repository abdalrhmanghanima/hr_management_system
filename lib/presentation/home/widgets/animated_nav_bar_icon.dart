import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';

class AnimatedNavBarIcon extends StatelessWidget {
  final String assetName;
  final String filledAssetName;
  final bool isSelected;

  const AnimatedNavBarIcon({
    super.key,
    required this.assetName,
    required this.filledAssetName,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      tween: Tween<double>(end: isSelected ? 1.0 : 0.0),
      builder: (context, progress, child) {
        final scale = 1.0 + (0.10 * progress);

        return Transform.scale(
          scale: scale,
          child: SizedBox(
            height: 24.w,
            width: 24.w,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: 1.0 - progress,
                  child: SvgPicture.asset(
                    assetName,
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Opacity(
                  opacity: progress,
                  child: SvgPicture.asset(
                    filledAssetName,
                    colorFilter: ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}