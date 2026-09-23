import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/presentation/attendance/tab/attendance_tab.dart';
import 'package:hr_management_system/presentation/employee/tab/employee_tab.dart';

import 'package:hr_management_system/presentation/home/provider/bottom_nav_provider.dart';
import 'package:hr_management_system/presentation/home/tabs/home_tab.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScreen = ref.watch(bottomNavProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentScreen,
        children: screens,
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
              currentIndex: currentScreen,
              onTap: (index) {
                ref.read(bottomNavProvider.notifier).state = index;
              },
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.black,
              selectedFontSize: 13.sp,
              unselectedFontSize: 12.sp,
              items: [
                BottomNavigationBarItem(
                  icon: Transform.translate(
                    offset: Offset(0, -1.h),
                    child: AnimatedNavBarIcon(
                      assetName: AppIcons.home,
                      filledAssetName: AppIcons.homeFilled,
                      isSelected: currentScreen == 0,
                    ),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Transform.translate(
                    offset: Offset(0, -1.h),
                    child: AnimatedNavBarIcon(
                      assetName: AppIcons.employees,
                      filledAssetName: AppIcons.employeesFilled,
                      isSelected: currentScreen == 1,
                    ),
                  ),
                  label: 'Employees',
                ),
                BottomNavigationBarItem(
                  icon: Transform.translate(
                    offset: Offset(0, -1.h),
                    child: AnimatedNavBarIcon(
                      assetName: AppIcons.attendance,
                      filledAssetName: AppIcons.attendanceFilled,
                      isSelected: currentScreen == 2,
                    ),
                  ),
                  label: 'Attendance',
                ),
                BottomNavigationBarItem(
                  icon: Transform.translate(
                    offset: Offset(0, -1.h),
                    child: AnimatedNavBarIcon(
                      assetName: AppIcons.payroll,
                      filledAssetName: AppIcons.payrollFilled,
                      isSelected: currentScreen == 3,
                    ),
                  ),
                  label: 'Payroll',
                ),
                BottomNavigationBarItem(
                  icon: Transform.translate(
                    offset: Offset(0, -1.h),
                    child: AnimatedNavBarIcon(
                      assetName: AppIcons.more,
                      filledAssetName: AppIcons.moreFilled,
                      isSelected: currentScreen == 4,
                    ),
                  ),
                  label: 'More',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}