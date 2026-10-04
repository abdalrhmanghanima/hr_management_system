import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/responsive/breakpoints.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/home/tabs/home_tab_item.dart';
import 'package:hr_management_system/presentation/home/widgets/animated_nav_bar_icon.dart';

/// Desktop/Web counterpart of the mobile bottom navigation.
///
/// Uses the same destinations, icons, labels and colors as the existing
/// `BottomNavigationBar` so it reads as the same navigation, not a new one.
class DesktopSideNav extends StatelessWidget {
  const DesktopSideNav({
    super.key,
    required this.tabs,
    required this.currentTab,
    required this.onSelect,
  });

  final List<HomeTabItem> tabs;
  final HomeTabItem currentTab;
  final ValueChanged<HomeTabItem> onSelect;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: AppBreakpoints.sideNavWidth,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(isRtl ? -3 : 3, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.h),
            for (final tab in tabs)
              _DesktopNavTile(
                tab: tab,
                isSelected: tab == currentTab,
                onTap: () => onSelect(tab),
              ),
          ],
        ),
      ),
    );
  }
}

class _DesktopNavTile extends StatelessWidget {
  const _DesktopNavTile({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final HomeTabItem tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: [
            AnimatedNavBarIcon(
              assetName: tab.iconPath,
              filledAssetName: tab.filledIconPath,
              isSelected: isSelected,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomText(
                title: tab.labelKey.tr(),
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontColor: isSelected ? AppColors.primary : Colors.black,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
