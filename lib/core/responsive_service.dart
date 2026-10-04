import 'dart:math';

import 'package:flutter/material.dart';

class ResponsiveService {
  // static const Size _designSize = Size(360, 716);
  static const Size _designSize = Size(375, 812);
  static const bool _splitScreenMode = false;

  /// Width below which the original mobile design-size scaling is used
  /// unchanged (mobile is the approved reference design).
  static const double largeScreenMinWidth = 600;

  /// Upper bound applied to the proportional scale factors on tablet/desktop
  /// so the mobile UI is never stretched to fit very large windows.
  static const double largeScreenMaxScale = 1.1;

  static MediaQueryData get _mediaQueryData {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view == null) {
      return const MediaQueryData();
    }
    return MediaQueryData.fromView(view);
  }

  static Size _switchableDesignSize() {
    return _mediaQueryData.orientation == Orientation.portrait
        ? _designSize
        : const Size(716, 360);
  }

  static double fullScreenHeight({double ratio = 1}) =>
      _mediaQueryData.size.height * ratio;

  static double fullScreenWidth({double ratio = 1}) =>
      _mediaQueryData.size.width * ratio;

  static double availableScreenHeight({double ratio = 1}) =>
      (_mediaQueryData.size.height - _mediaQueryData.viewPadding.vertical) *
      ratio;

  static double availableScreenWidth({double ratio = 1}) =>
      (_mediaQueryData.size.width - _mediaQueryData.viewPadding.horizontal) *
      ratio;

  static Orientation orientation() => _mediaQueryData.orientation;

  static double deviceTopPadding() => _mediaQueryData.padding.top;

  static double deviceBottomPadding() => _mediaQueryData.padding.bottom;

  static double deviceBottomViewPadding() => _mediaQueryData.viewPadding.bottom;

  static double deviceKeyboardHeight() => _mediaQueryData.viewInsets.bottom;

  static double textScaleFactor() => _mediaQueryData.textScaler.scale(1.0);

  static double devicePixelRatio() => _mediaQueryData.devicePixelRatio;

  /// Caps the raw design-size scale on large screens so typography, spacing
  /// and radii keep their approved mobile proportions instead of growing
  /// linearly with the window width.
  static double _capLargeScreenScale(double scale) {
    if (_mediaQueryData.size.width < largeScreenMinWidth) {
      return scale;
    }
    return min(scale, largeScreenMaxScale);
  }

  static double scaleWidth() =>
      _capLargeScreenScale(availableScreenWidth() / _switchableDesignSize().width);

  static double scaleHeight() => _capLargeScreenScale(
    (_splitScreenMode ? max(availableScreenHeight(), 700) : availableScreenHeight()) /
        _switchableDesignSize().height,
  );

  static double scaleRadius() => min(scaleWidth(), scaleHeight());

  static double scaleText() => min(scaleWidth(), scaleHeight());
}
