import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_entity.dart';
import 'package:hr_management_system/presentation/attendance/tab/attendance_tab.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/authorization/provider/module_data_invalidation.dart';
import 'package:hr_management_system/presentation/employee/tab/employee_tab.dart';

import 'package:hr_management_system/presentation/home/provider/bottom_nav_provider.dart';
import 'package:hr_management_system/presentation/home/tabs/home_tab.dart';
import 'package:hr_management_system/presentation/home/tabs/home_tab_item.dart';
import 'package:hr_management_system/presentation/home/widgets/animated_nav_bar_icon.dart';
import 'package:hr_management_system/presentation/more/tab/more_tab.dart';
import 'package:hr_management_system/presentation/payroll/tab/payroll_tab.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static List<Widget> screens = [
    HomeTab(),
    EmployeesTab(),
    AttendanceTab(),
    PayrollTab(),
    MoreTab(),
  ];

  static Widget screenFor(HomeTabItem tab) {
    switch (tab) {
      case HomeTabItem.home:
        return screens[0];
      case HomeTabItem.employees:
        return screens[1];
      case HomeTabItem.attendance:
        return screens[2];
      case HomeTabItem.payroll:
        return screens[3];
      case HomeTabItem.more:
        return screens[4];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<AuthorizationEntity>>(authorizationProvider, (
      previous,
      next,
    ) {
      final resolved = next.valueOrNull?.isResolved ?? false;

      if (resolved && (previous?.valueOrNull?.isResolved ?? false) == false) {
        Future.microtask(() => reloadModuleData(ref));
      }
    });

    final tabs = ref.watch(visibleHomeTabsProvider);
    final currentTab = ref.watch(currentHomeTabProvider);

    ref.listen<List<HomeTabItem>>(visibleHomeTabsProvider, (previous, next) {
      if (next.length < alwaysVisibleHomeTabs.length) return;
      if (next.contains(ref.read(currentHomeTabProvider))) return;

      ref.read(currentHomeTabProvider.notifier).state = next.first;
    });

    final currentIndex = tabs.indexOf(currentTab);
    final selectedIndex = currentIndex == -1 ? 0 : currentIndex;

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: tabs.map(screenFor).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 65.h,
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              currentIndex: selectedIndex,
              onTap: (index) {
                ref.read(currentHomeTabProvider.notifier).state = tabs[index];
              },
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.black,
              selectedFontSize: 13.sp,
              unselectedFontSize: 12.sp,
              items: tabs
                  .map(
                    (tab) => BottomNavigationBarItem(
                      icon: Transform.translate(
                        offset: Offset(0, -1.h),
                        child: AnimatedNavBarIcon(
                          assetName: tab.iconPath,
                          filledAssetName: tab.filledIconPath,
                          isSelected: selectedIndex == tabs.indexOf(tab),
                        ),
                      ),
                      label: tab.labelKey.tr(),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
