import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/responsive/breakpoints.dart';
import 'package:hr_management_system/core/responsive/responsive_widgets.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/core/utils/date_parser.dart';
import 'package:hr_management_system/core/utils/delete_confirmation_dialog.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/attendance/attendance_import_screen.dart';
import 'package:hr_management_system/presentation/attendance/add_attendance_screen.dart';
import 'package:hr_management_system/presentation/attendance/edit_attendance_screen.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/selected_attendance_month_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/today_attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_record_card.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/components/month_filter_row/month_filter_row.dart';
import 'package:hr_management_system/presentation/department/provider/department_by_id_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_floating_action_button.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_search_field.dart';

class AttendanceTab extends ConsumerStatefulWidget {
  const AttendanceTab({super.key});

  @override
  ConsumerState<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<AttendanceTab> {
  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(todayAttendanceProvider);

    await Future.wait([
      ref.read(attendanceProvider.notifier).getAttendances(),
      ref.read(employeeProvider.notifier).getEmployees(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(attendanceProvider);
    final employeesAsync = ref.watch(employeeProvider);
    final selectedMonth = ref.watch(selectedAttendanceMonthProvider);

    final canAddAttendances = ref.watch(
      modulePermissionProvider((
        module: GroupModules.attendance,
        action: PermissionAction.add,
      )),
    );
    final canEditAttendances = ref.watch(
      modulePermissionProvider((
        module: GroupModules.attendance,
        action: PermissionAction.edit,
      )),
    );
    final canDeleteAttendances = ref.watch(
      modulePermissionProvider((
        module: GroupModules.attendance,
        action: PermissionAction.delete,
      )),
    );

    final attendances = attendanceAsync.value ?? [];
    final employees = employeesAsync.value ?? [];

    final monthAttendances = attendances.where((attendance) {
      return attendance.attendanceDate.year == selectedMonth.year &&
          attendance.attendanceDate.month == selectedMonth.month;
    });

    final searchedAttendances = monthAttendances.where((attendance) {
      if (searchQuery.isEmpty) {
        return true;
      }

      final employee = employees
          .where((employee) => employee.id == attendance.employeeId)
          .firstOrNull;

      if (employee == null) {
        return false;
      }

      final employeeName = employee.fullName.toLowerCase();

      final attendanceDate = DateParser.toDisplayDate(
        attendance.attendanceDate,
      ).toLowerCase();

      return employeeName.contains(searchQuery) ||
          attendanceDate.contains(searchQuery);
    }).toList();

    final filteredAttendances = _sortedByDateDesc(searchedAttendances);

    // TODO(hr-session-diagnostics): temporary debug logging.
    debugPrint(
      '[ATTENDANCE-RELOGIN] attendanceTab.build recordsBeforeFilter=${attendances.length} '
      'selectedMonth=${selectedMonth.year}-${selectedMonth.month} '
      'afterMonthFilter=${monthAttendances.length} '
      'afterSearch=${searchedAttendances.length} '
      'searchQuery="$searchQuery" '
      'dates=${attendances.take(3).map((a) => a.attendanceDate.toIso8601String()).join(', ')}',
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: CustomText(
          title: 'attendance.records_title'.tr(),
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontColor: const Color(0xFF111827),
        ),
        actions: [
          if (canAddAttendances)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: InkWell(
                onTap: () {
                  NavigatorHandler.push(const AttendanceImportScreen());
                },
                child: Row(
                  children: [
                    CustomSvgIcon(
                      assetName: AppIcons.file,
                      width: 16.w,
                      height: 16.w,
                    ),
                    SizedBox(width: 4.w),
                    CustomText(
                      title: 'attendance_import.title'.tr(),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.primary,
                    ),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(height: 1.h, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            MaxWidthBox(
              maxWidth: AppBreakpoints.searchMaxWidth,
              center: false,
              applyFromWidth: AppBreakpoints.desktopMinWidth,
              child: AppSearchField(
                controller: searchController,
                hintText: 'attendance.search_hint'.tr(),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim().toLowerCase();
                  });
                },
              ),
            ),

            SizedBox(height: 12.h),

            MonthFilterRow(
              selectedMonth: selectedMonth,
              onMonthChanged: (month) {
                ref.read(selectedAttendanceMonthProvider.notifier).state =
                    month;
              },
            ),

            SizedBox(height: 16.h),

            Expanded(
              child: filteredAttendances.isEmpty
                  ? Center(
                      child: CustomText(
                        title: searchQuery.isEmpty
                            ? 'attendance.empty'.tr()
                            : 'attendance.empty_search'.tr(),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontColor: const Color(0xFF64748B),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: AdaptiveCardList(
                        spacing: 16.h,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          for (final attendance in filteredAttendances)
                            Builder(
                              builder: (context) {
                                final employee = employees
                                    .where(
                                      (employee) =>
                                          employee.id ==
                                          attendance.employeeId,
                                    )
                                    .firstOrNull;

                                if (employee == null) {
                                  return const SizedBox.shrink();
                                }

                                final departmentState = ref.watch(
                                  departmentByIdProvider(
                                    employee.departmentId,
                                  ),
                                );

                                final departmentName =
                                    departmentState.value?.name ??
                                    'common.unknown_department'.tr();

                                return AttendanceRecordCard(
                                  name: employee.fullName,
                                  department: departmentName,
                                  date: attendance.attendanceDate,
                                  status: attendance.status,
                                  checkIn: attendance.checkInTime,
                                  checkOut: attendance.checkOutTime,
                                  onEdit: canEditAttendances
                                      ? () {
                                          NavigatorHandler.push(
                                            EditAttendanceScreen(
                                              attendance: attendance,
                                            ),
                                          );
                                        }
                                      : null,
                                  onDelete: canDeleteAttendances
                                      ? () {
                                          showDialog(
                                            context: context,
                                            builder: (dialogContext) {
                                              return DeleteConfirmationDialog(
                                                title:
                                                    'attendance.delete_title'
                                                        .tr(),
                                                message:
                                                    'attendance.delete_confirmation'
                                                        .tr(),
                                                isLoading:
                                                    attendanceAsync.isLoading,
                                                onDelete: () async {
                                                  await ref
                                                      .read(
                                                        attendanceProvider
                                                            .notifier,
                                                      )
                                                      .deleteAttendance(
                                                        attendance.id,
                                                      );

                                                  if (dialogContext.mounted) {
                                                    Navigator.pop(
                                                      dialogContext,
                                                    );
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
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: canAddAttendances
          ? AppFloatingActionButton(
              onPressed: () {
                NavigatorHandler.push(const AddAttendanceScreen());
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

List<AttendanceEntity> _sortedByDateDesc(List<AttendanceEntity> records) {
  final indexed = records.indexed.toList()
    ..sort((a, b) {
      final byDate = b.$2.attendanceDate.compareTo(a.$2.attendanceDate);

      return byDate != 0 ? byDate : a.$1.compareTo(b.$1);
    });

  return [for (final entry in indexed) entry.$2];
}
