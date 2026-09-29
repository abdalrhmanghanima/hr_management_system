import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/core/utils/date_parser.dart';
import 'package:hr_management_system/core/utils/delete_confirmation_dialog.dart';
import 'package:hr_management_system/presentation/attendance/attendance_import_screen.dart';
import 'package:hr_management_system/presentation/attendance/add_attendance_screen.dart';
import 'package:hr_management_system/presentation/attendance/edit_attendance_screen.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/today_attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_record_card.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
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

    final attendances = attendanceAsync.value ?? [];
    final employees = employeesAsync.value ?? [];

    final filteredAttendances = attendances.where((attendance) {
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

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: CustomText(
          title: 'Attendance Records',
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontColor: const Color(0xFF111827),
        ),
        actions: [
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
                    title: 'Import',
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
            AppSearchField(
              controller: searchController,
              hintText: 'Search by employee or date...',
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),

            SizedBox(height: 16.h),

            Expanded(
              child: filteredAttendances.isEmpty
                  ? Center(
                      child: CustomText(
                        title: searchQuery.isEmpty
                            ? 'No attendance records found'
                            : 'No attendance records match your search',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontColor: const Color(0xFF64748B),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredAttendances.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 16.h);
                        },
                        itemBuilder: (context, index) {
                          final attendance = filteredAttendances[index];

                          final employee = employees
                              .where(
                                (employee) =>
                                    employee.id == attendance.employeeId,
                              )
                              .firstOrNull;

                          if (employee == null) {
                            return const SizedBox.shrink();
                          }

                          final departmentState = ref.watch(
                            departmentByIdProvider(employee.departmentId),
                          );

                          final departmentName =
                              departmentState.value?.name ??
                              'Unknown Department';

                          return AttendanceRecordCard(
                            name: employee.fullName,
                            department: departmentName,
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
                                        'Are you sure you want to delete this attendance record?',
                                    isLoading: attendanceAsync.isLoading,
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
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: AppFloatingActionButton(
        onPressed: () {
          NavigatorHandler.push(const AddAttendanceScreen());
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
