import 'package:flutter/material.dart';

/// Centralized responsive breakpoints for the HR Management System.
///
/// The layout reacts to the available width only — never to device models.
class AppBreakpoints {
  AppBreakpoints._();

  /// Mobile: widths below this value keep the approved mobile design.
  static const double mobileMaxWidth = 600;

  /// Tablet: widths from [mobileMaxWidth] up to this value.
  static const double tabletMaxWidth = 1024;

  /// Desktop/Web: widths of [tabletMaxWidth] and above.
  static const double desktopMinWidth = tabletMaxWidth;

  /// Maximum width of the whole app frame (navigation + content) on very
  /// wide windows. Prevents the UI from stretching across a huge display.
  static const double appMaxWidth = 1440;

  /// Width of the persistent desktop sidebar navigation.
  static const double sideNavWidth = 240;

  /// Max width for search fields on desktop so they are not stretched.
  static const double searchMaxWidth = 640;

  /// Max width for form screens/cards on desktop.
  static const double formMaxWidth = 840;

  /// Minimum width required before form fields are laid out in 2 columns.
  static const double formRowMinWidth = 520;

  /// Max width for menu-style content (More tab, settings) on desktop.
  static const double menuContentMaxWidth = 640;

  /// Max width for profile/details content on desktop.
  static const double detailsContentMaxWidth = 900;

  /// Max width for long documents (payroll details, salary slip) on desktop.
  static const double documentMaxWidth = 1000;

  /// Max width of confirmation/custom dialogs on large screens.
  static const double dialogMaxWidth = 460;

  /// Max width of bottom-sheet content on large screens.
  static const double bottomSheetMaxWidth = 560;

  /// Max width of the login card on large screens.
  static const double loginMaxWidth = 460;
}

/// Device class derived from the available width.
enum AppDeviceType { mobile, tablet, desktop }

extension ResponsiveContextX on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  AppDeviceType get deviceType {
    final width = screenWidth;
    if (width < AppBreakpoints.mobileMaxWidth) return AppDeviceType.mobile;
    if (width < AppBreakpoints.tabletMaxWidth) return AppDeviceType.tablet;
    return AppDeviceType.desktop;
  }

  bool get isMobileDevice => deviceType == AppDeviceType.mobile;

  bool get isTabletDevice => deviceType == AppDeviceType.tablet;

  bool get isDesktopDevice => deviceType == AppDeviceType.desktop;

  /// True for tablet + desktop widths (where the layout may use extra space).
  bool get isLargeScreenDevice => !isMobileDevice;

  /// Number of card columns that fit into [availableWidth] without making
  /// any card narrower than [minCardWidth].
  int cardColumnsFor(double availableWidth, {
    double minCardWidth = 340,
    double spacing = 16,
    int maxColumns = 3,
  }) {
    if (availableWidth.isInfinite || availableWidth <= 0) return 1;
    final fit =
        ((availableWidth + spacing) / (minCardWidth + spacing)).floor();
    return fit.clamp(1, maxColumns);
  }
}
