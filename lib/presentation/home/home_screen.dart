import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_entity.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_status.dart';
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

class HomeScreen extends ConsumerStatefulWidget {
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
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _moduleDataLoaded = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(_ensureModuleDataLoaded);
  }

  void _ensureModuleDataLoaded() {
    if (!mounted || _moduleDataLoaded) return;

    // Flush the authorization -> permission chain before reloading.
    // `_notifyListeners` marks provider-dependents dirty only *after* it has
    // invoked `ref.listen` callbacks, so without this flush the scoped
    // repository would still be built from the previous (unauthorized) scope
    // and would return an empty list that nothing ever refreshes.
    ref.read(permissionCheckerProvider);

    // Read the source `authorizationProvider` instead of the derived
    // `authorizationStatusProvider`.
    final status =
        ref.read(authorizationProvider).valueOrNull?.status ??
        AuthorizationStatus.loading;

    // TODO(hr-session-diagnostics): temporary debug logging.
    debugPrint(
      '[hr-session] home.ensure status=$status alreadyLoaded=$_moduleDataLoaded',
    );
    debugPrint('[ATTENDANCE-RELOGIN] home.ensure status=$status alreadyLoaded=$_moduleDataLoaded');

    if (status != AuthorizationStatus.authenticated) {
      debugPrint('[ATTENDANCE-RELOGIN] home.ensure skipped (not authenticated)');
      return;
    }

    _moduleDataLoaded = true;

    debugPrint('[hr-session] home.ensure -> reloadModuleData');
    debugPrint('[ATTENDANCE-RELOGIN] home.ensure -> reloadModuleData');

    reloadModuleData(ref);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthorizationEntity>>(authorizationProvider, (
      previous,
      next,
    ) {
      if (next.valueOrNull?.isResolved ?? false) {
        // Yield to the event loop. Riverpod invalidates provider-dependents
        // only after every `ref.listen` callback has returned, so reloading
        // synchronously from inside the callback would run against a stale
        // permission scope.
        Future.microtask(_ensureModuleDataLoaded);
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
        children: tabs.map(HomeScreen.screenFor).toList(),
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
