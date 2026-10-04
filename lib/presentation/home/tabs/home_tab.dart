import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/core/utils/delete_confirmation_dialog.dart';
import 'package:hr_management_system/core/utils/payroll_format.dart';
import 'package:hr_management_system/presentation/attendance/add_attendance_screen.dart';
import 'package:hr_management_system/presentation/attendance/edit_attendance_screen.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_record_card.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/department/widgets/add_department_bottom_sheet.dart';
import 'package:hr_management_system/presentation/employee/add_employee.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_status.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/home/provider/bottom_nav_provider.dart';
import 'package:hr_management_system/presentation/home/tabs/home_tab_item.dart';
import 'package:hr_management_system/presentation/home/widgets/dashboard_summary_card.dart';
import 'package:hr_management_system/presentation/home/widgets/quick_action_card.dart';
import 'package:hr_management_system/presentation/official_holiday/add_official_holiday_screen.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/payroll/provider/payroll_provider.dart';
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
    if (ref.read(authorizationStatusProvider) == AuthorizationStatus.failed) {
      await ref.read(authorizationProvider.notifier).reload();
    }

    await Future.wait([
      ref.read(employeeProvider.notifier).getEmployees(),
      ref.read(attendanceProvider.notifier).getAttendances(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final employeeState = ref.watch(employeeProvider);
    final attendanceState = ref.watch(attendanceProvider);
    final payrollMonth = ref.watch(currentPayrollMonthProvider);
    final payrollState = ref.watch(payrollSummariesProvider(payrollMonth));

    final canAddEmployees = ref.watch(
      modulePermissionProvider((module: GroupModules.employees, action: PermissionAction.add)),
    );
    final canAddDepartments = ref.watch(
      modulePermissionProvider((module: GroupModules.departments, action: PermissionAction.add)),
    );
    final canAddAttendance = ref.watch(
      modulePermissionProvider((module: GroupModules.attendance, action: PermissionAction.add)),
    );
    final canAddHolidays = ref.watch(
      modulePermissionProvider((module: GroupModules.officialHolidays, action: PermissionAction.add)),
    );
    final canViewPayroll = ref.watch(
      modulePermissionProvider((module: GroupModules.payroll, action: PermissionAction.view)),
    );
    final canViewAttendance = ref.watch(
      modulePermissionProvider((module: GroupModules.attendance, action: PermissionAction.view)),
    );
    final canEditAttendance = ref.watch(
      modulePermissionProvider((module: GroupModules.attendance, action: PermissionAction.edit)),
    );
    final canDeleteAttendance = ref.watch(
      modulePermissionProvider((module: GroupModules.attendance, action: PermissionAction.delete)),
    );
    final authorizationStatus = ref.watch(authorizationStatusProvider);
    final isResolved =
        authorizationStatus == AuthorizationStatus.authenticated;
    final hasAnyModuleAccess = ref.watch(authorizationEntityProvider).hasAnyModuleAccess;
    final accessMessage = switch (authorizationStatus) {
      AuthorizationStatus.loading => 'home.access.loading'.tr(),
      AuthorizationStatus.missingUserDocument =>
        'home.access.missing_user_document'.tr(),
      AuthorizationStatus.inactive => 'home.access.inactive'.tr(),
      AuthorizationStatus.withoutGroup => 'home.access.without_group'.tr(),
      AuthorizationStatus.groupNotFound =>
        'home.access.group_not_found'.tr(),
      AuthorizationStatus.failed => 'home.access.failed'.tr(),
      _ => 'home.access.no_modules'.tr(),
    };

    final quickActions = <Widget>[
      if (canAddEmployees)
        QuickActionCard(
          iconPath: AppIcons.addEmployee,
          title: 'home.quick_add_employee'.tr(),
          iconBackgroundColor: const Color(0xFFEFF6FF),
          onTap: () {
            NavigatorHandler.push(const AddEmployee());
          },
        ),
      if (canAddDepartments)
        QuickActionCard(
          iconPath: AppIcons.department,
          title: 'home.quick_add_department'.tr(),
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
      if (canAddAttendance)
        QuickActionCard(
          iconPath: AppIcons.attendance,
          title: 'home.quick_add_attendance'.tr(),
          iconBackgroundColor: const Color(0xFFECFDF5),
          onTap: () {
            NavigatorHandler.push(const AddAttendanceScreen());
          },
        ),
      if (canViewPayroll)
        QuickActionCard(
          iconPath: AppIcons.payroll,
          title: 'nav.payroll'.tr(),
          iconBackgroundColor: const Color(0xFFEFF6FF),
          onTap: () {
            ref.read(currentHomeTabProvider.notifier).state = HomeTabItem.payroll;
          },
        ),
      if (canAddHolidays)
        QuickActionCard(
          iconPath: AppIcons.addHoliday,
          title: 'home.quick_add_holiday'.tr(),
          iconBackgroundColor: const Color(0xFFF5F3FF),
          onTap: () => NavigatorHandler.push(AddOfficialHolidayScreen()),
        ),
    ];

    final employees = employeeState.value ?? [];
    final attendances = attendanceState.value ?? [];

    final payrollTotal = payrollState.value?.fold<double>(
      0,
      (total, summary) => total + summary.netSalary,
    );

    final payrollAmount = payrollTotal != null
        ? PayrollFormat.amount(payrollTotal)
        : payrollState.hasError
        ? '—'
        : '...';

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

    if (!isResolved || !hasAnyModuleAccess) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.r),
                      child: CustomText(
                        title: accessMessage,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        fontColor: AppColors.gray,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 25.h, 16.w, 0),
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
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              title: 'home.welcome_back'.tr(),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              fontColor: AppColors.gray,
                            ),
                            CustomText(
                              title: 'common.hr_administrator'.tr(),
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ],
                        ),
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
                              title: 'home.total_employees'.tr(),
                              topText: '',
                              topTextColor: AppColors.green,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: DashboardSummaryCard(
                              iconPath: AppIcons.greenCalender,
                              value: '$presentToday / ${employees.length}',
                              title: 'home.present_today'.tr(),
                              topText: 'home.absent_today'.tr(
                                namedArgs: {'count': '$absentToday'},
                              ),
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
                                    title: 'home.current_month_payroll'.tr(),
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
                                        title: payrollAmount,
                                        fontColor: AppColors.white,
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      SizedBox(width: 6.w),
                                      CustomText(
                                        title: 'common.egp'.tr(),
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
                            Flexible(
                              child: CustomText(
                                title: AppLocalization.monthYear(
                                  context,
                                  payrollMonth,
                                ),
                                fontColor: AppColors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: InkWell(
                                onTap: () {
                                  ref
                                      .read(
                                        currentHomeTabProvider.notifier,
                                      )
                                      .state = HomeTabItem.payroll;
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: CustomText(
                                        title: 'home.view_details'.tr(),
                                        fontColor: AppColors.primary,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Transform.scale(
                                      scaleX:
                                          Directionality.of(context) ==
                                                  TextDirection.rtl
                                              ? -1
                                              : 1,
                                      child: Icon(
                                        Icons.chevron_right,
                                        color: AppColors.primary,
                                        size: 22.w,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  CustomText(
                    title: 'home.quick_actions'.tr(),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),

                  SizedBox(height: 12.h),

                  SizedBox(
                    height: 120.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: quickActions.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(width: 8.w);
                      },
                      itemBuilder: (context, index) {
                        return quickActions[index];
                      },
                    ),
                  ),

                  if (canViewAttendance) ...[
                    SizedBox(height: 24.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: CustomText(
                            title: 'home.recent_attendance'.tr(),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: InkWell(
                            onTap: () {
                              ref.read(currentHomeTabProvider.notifier).state =
                                  HomeTabItem.attendance;
                            },
                            child: CustomText(
                              title: 'home.view_all'.tr(),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              fontColor: AppColors.primary,
                            ),
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
                            title: 'home.no_attendance_records'.tr(),
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
                            onEdit: canEditAttendance
                                ? () {
                                    NavigatorHandler.push(
                                      EditAttendanceScreen(
                                        attendance: attendance,
                                      ),
                                    );
                                  }
                                : null,
                            onDelete: canDeleteAttendance
                                ? () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return DeleteConfirmationDialog(
                                          title: 'attendance.delete_title'.tr(),
                                          message:
                                              'common.delete_attendance_confirmation'.tr(),
                                          onDelete: () async {
                                            await ref
                                                .read(
                                                  attendanceProvider.notifier,
                                                )
                                                .deleteAttendance(
                                                  attendance.id,
                                                );

                                            if (dialogContext.mounted) {
                                              Navigator.pop(dialogContext);
                                            }
                                          },
                                        );
                                      },
                                    );
                                  }
                                : null,
                          );
                        },
                      ),

                    SizedBox(height: 20.h),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
