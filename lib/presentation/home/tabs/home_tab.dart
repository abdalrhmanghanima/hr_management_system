import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_record_card.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/employee/add_employee.dart';
import 'package:hr_management_system/presentation/home/widgets/dashboard_summary_card.dart';
import 'package:hr_management_system/presentation/home/widgets/quick_action_card.dart';
import 'package:hr_management_system/presentation/shared_widgets/user_avatar.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<Widget> quickActions = [
    QuickActionCard(
      iconPath: AppIcons.addEmployee,
      title: 'Add Employee',
      iconBackgroundColor: const Color(0xFFEFF6FF),
      onTap: () => NavigatorHandler.push(AddEmployee()),
    ),
    QuickActionCard(
      iconPath: AppIcons.attendance,
      title: 'Attendance',
      iconBackgroundColor: const Color(0xFFECFDF5),
    ),
    QuickActionCard(
      iconPath: AppIcons.payroll,
      title: 'Payroll',
      iconBackgroundColor: const Color(0xFFEFF6FF),
    ),
    QuickActionCard(
      iconPath: AppIcons.addHoliday,
      title: 'Add Holiday',
      iconBackgroundColor: const Color(0xFFF5F3FF),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 25.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          title: "Welcome back 👋",
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.gray,
                        ),
                        CustomText(
                          title: "HR Administrator",
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ],
                    ),
                    const UserAvatar(),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DashboardSummaryCard(
                        iconPath: AppIcons.blueEmployee,
                        value: '5',
                        title: 'Total Employees',
                        topText: '+4 this mo',
                        topTextColor: AppColors.green,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: DashboardSummaryCard(
                        iconPath: AppIcons.greenCalender,
                        value: '3 / 5',
                        title: 'Present Today',
                        topText: '1 absent',
                        topTextColor: AppColors.gray,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Container(
                  width: Dimens.width,
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  title: 'CURRENT MONTH PAYROLL',
                                  fontColor: AppColors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    CustomText(
                                      title: '61,565',
                                      fontColor: AppColors.white,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    SizedBox(width: 6.w),
                                    CustomText(
                                      title: 'EGP',
                                      fontColor: AppColors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF29364E),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Center(
                              child: CustomSvgIcon(
                                assetName: AppIcons.payroll,
                                width: 20.w,
                                height: 20.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            title: 'September 2026',
                            fontColor: AppColors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          Row(
                            children: [
                              CustomText(
                                title: 'View Details',
                                fontColor: AppColors.primary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.primary,
                                size: 22.w,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                CustomText(
                  title: "Quick Actions",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 120.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (context, index) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      return quickActions[index];
                    },
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      title: "Recent Attendance",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    CustomText(
                      title: "View All",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      fontColor: AppColors.primary,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    return AttendanceRecordCard(
                      name: 'Ahmed Mohamed',
                      department: 'Engineering',
                      date: '2026-09-21',
                      status: 'Present',
                      checkIn: '08:55',
                      checkOut: '18:30',
                      overtime: 'Overtime: +1.5 hrs',
                      statusColor: AppColors.green,
                      statusBackgroundColor: const Color(0xFFE8F8F1),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
