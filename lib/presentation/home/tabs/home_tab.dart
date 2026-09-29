import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/core/utils/delete_confirmation_dialog.dart';
import 'package:hr_management_system/presentation/attendance/add_attendance_screen.dart';
import 'package:hr_management_system/presentation/attendance/edit_attendance_screen.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_record_card.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/department/widgets/add_department_bottom_sheet.dart';
import 'package:hr_management_system/presentation/employee/add_employee.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/home/provider/bottom_nav_provider.dart';
import 'package:hr_management_system/presentation/home/widgets/dashboard_summary_card.dart';
import 'package:hr_management_system/presentation/home/widgets/quick_action_card.dart';
import 'package:hr_management_system/presentation/official_holiday/add_official_holiday_screen.dart';
import 'package:hr_management_system/presentation/shared_widgets/user_avatar.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  @override
  void initState() {
    super.initState();

    Future.microtask(_refresh);
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(employeeProvider.notifier).getEmployees(),
      ref.read(attendanceProvider.notifier).getAttendances(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final employeeState = ref.watch(employeeProvider);
    final attendanceState = ref.watch(attendanceProvider);

    final employees = employeeState.value ?? [];
    final attendances = attendanceState.value ?? [];

    final today = DateTime.now();

    final todayAttendances = attendances.where((attendance) {
      return attendance.attendanceDate.year == today.year &&
          attendance.attendanceDate.month == today.month &&
          attendance.attendanceDate.day == today.day;
    }).toList();

    final presentToday = todayAttendances.where((attendance) {
      return attendance.status == 'Present';
    }).length;

    final absentToday = employees.length - presentToday;

    final recentAttendances = [...attendances]
      ..sort(
        (a, b) => (b.checkInTime ?? b.attendanceDate).compareTo(
          a.checkInTime ?? a.attendanceDate,
        ),
      );

    final latestThree = recentAttendances.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 25.h),
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                            title: 'Welcome back 👋',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            fontColor: AppColors.gray,
                          ),
                          CustomText(
                            title: 'HR Administrator',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ],
                      ),
                      const UserAvatar(),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  employeeState.when(
                    data: (data) {
                      return Row(
                        children: [
                          Expanded(
                            child: DashboardSummaryCard(
                              iconPath: AppIcons.blueEmployee,
                              value: '${employees.length}',
                              title: 'Total Employees',
                              topText: '',
                              topTextColor: AppColors.green,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: DashboardSummaryCard(
                              iconPath: AppIcons.greenCalender,
                              value: '$presentToday / ${employees.length}',
                              title: 'Present Today',
                              topText: '$absentToday absent',
                              topTextColor: AppColors.gray,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Center(
                      child: CustomText(
                        title: error.toString(),
                        fontColor: AppColors.red,
                      ),
                    ),
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
                    title: 'Quick Actions',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),

                  SizedBox(height: 12.h),

                  SizedBox(
                    height: 120.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      separatorBuilder: (context, index) {
                        return SizedBox(width: 8.w);
                      },
                      itemBuilder: (context, index) {
                        final quickActions = [
                          QuickActionCard(
                            iconPath: AppIcons.addEmployee,
                            title: 'Add Employee',
                            iconBackgroundColor: const Color(0xFFEFF6FF),
                            onTap: () {
                              NavigatorHandler.push(const AddEmployee());
                            },
                          ),
                          QuickActionCard(
                            iconPath: AppIcons.department,
                            title: 'Add Department',
                            iconBackgroundColor: const Color(0xFFEFF6FF),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24.r),
                                  ),
                                ),
                                builder: (_) {
                                  return const AddDepartmentBottomSheet();
                                },
                              );
                            },
                          ),
                          QuickActionCard(
                            iconPath: AppIcons.attendance,
                            title: 'Add Attendance',
                            iconBackgroundColor: const Color(0xFFECFDF5),
                            onTap: () {
                              NavigatorHandler.push(
                                const AddAttendanceScreen(),
                              );
                            },
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
                            onTap: () => NavigatorHandler.push(
                              AddOfficialHolidayScreen(),
                            ),
                          ),
                        ];

                        return quickActions[index];
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        title: 'Recent Attendance',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      InkWell(
                        onTap: () =>
                            ref.read(bottomNavProvider.notifier).state = 2,
                        child: CustomText(
                          title: 'View All',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          fontColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  if (latestThree.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Center(
                        child: CustomText(
                          title: 'No attendance records yet',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.gray,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: latestThree.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 16.h);
                      },
                      itemBuilder: (context, index) {
                        final attendance = latestThree[index];

                        final employee = employees
                            .where(
                              (employee) =>
                                  employee.id == attendance.employeeId,
                            )
                            .firstOrNull;

                        if (employee == null) {
                          return const SizedBox.shrink();
                        }

                        return AttendanceRecordCard(
                          name: employee.fullName,
                          department: '',
                          date: attendance.attendanceDate,
                          status: attendance.status,
                          checkIn: attendance.checkInTime,
                          checkOut: attendance.checkOutTime,
                          onEdit: () {
                            NavigatorHandler.push(
                              EditAttendanceScreen(attendance: attendance),
                            );
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) {
                                return DeleteConfirmationDialog(
                                  title: 'Delete Attendance',
                                  message:
                                      'Are you sure you want to delete this attendance record? This action cannot be undone.',
                                  onDelete: () async {
                                    await ref
                                        .read(attendanceProvider.notifier)
                                        .deleteAttendance(attendance.id);

                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                    }
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
