import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';

class CustomSvgIcon extends StatelessWidget {
  final String assetName;
  final double? width;
  final double? height;
  final Color? color;
  final ColorFilter? colorFilter;
  final bool mirrorInRtl;

  const CustomSvgIcon({
    super.key,
    required this.assetName,
    this.width,
    this.height,
    this.color,
    this.colorFilter,
    this.mirrorInRtl = false,
  });

  @override
  Widget build(BuildContext context) {
    final picture = SvgPicture.asset(
      assetName,
      width: width ?? 20.w,
      height: height ?? 20.w,
      color: color,
      colorFilter: colorFilter,
    );

    if (mirrorInRtl && Directionality.of(context) == TextDirection.rtl) {
      return Transform.scale(scaleX: -1, child: picture);
    }

    return picture;
  }
}
