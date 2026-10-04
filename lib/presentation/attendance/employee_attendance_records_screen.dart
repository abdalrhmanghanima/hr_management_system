import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_record_card.dart';
import 'package:hr_management_system/presentation/authorization/widgets/permission_guard.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/components/month_filter_row/month_filter_row.dart';
import 'package:hr_management_system/presentation/department/provider/department_by_id_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_details_provider.dart';
import 'package:hr_management_system/presentation/more/provider/general_settings_provider.dart';

class EmployeeAttendanceRecordsScreen extends ConsumerStatefulWidget {
  final String employeeId;

  const EmployeeAttendanceRecordsScreen({
    super.key,
    required this.employeeId,
  });

  @override
  ConsumerState<EmployeeAttendanceRecordsScreen> createState() =>
      _EmployeeAttendanceRecordsScreenState();
}

class _EmployeeAttendanceRecordsScreenState
    extends ConsumerState<EmployeeAttendanceRecordsScreen> {
  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedMonth = DateTime(now.year, now.month);

    Future.microtask(
      () => ref.read(attendanceProvider.notifier).getAttendances(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeeAsync = ref.watch(employeeDetailsProvider(widget.employeeId));
    final attendancesAsync = ref.watch(attendanceProvider);
    final settings = ref.watch(generalSettingsProvider).valueOrNull;

    return PermissionGuard(
      module: GroupModules.attendance,
      action: PermissionAction.view,
      popOnDenied: true,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(
          title: 'employee.attendance_records_title'.tr(),
          fontSize: 18.sp,
        ),
        body: employeeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: CustomText(
              title: error.toString(),
              fontColor: AppColors.red,
            ),
          ),
          data: (employee) {
            final departmentAsync = ref.watch(
              departmentByIdProvider(employee.departmentId),
            );

            final departmentName =
                departmentAsync.value?.name ??
                'common.unknown_department'.tr();

            final records = _sortedByDateDesc(
              (attendancesAsync.value ?? const []).where((attendance) {
                return attendance.employeeId == widget.employeeId &&
                    attendance.attendanceDate.year == selectedMonth.year &&
                    attendance.attendanceDate.month == selectedMonth.month;
              }).toList(),
            );

            return Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EmployeeHeaderCard(
                    name: employee.fullName,
                    department: departmentName,
                  ),
                  SizedBox(height: 16.h),
                  MonthFilterRow(
                    selectedMonth: selectedMonth,
                    onMonthChanged: (month) {
                      setState(() {
                        selectedMonth = month;
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: records.isEmpty
                        ? Center(
                            child: CustomText(
                              title: 'attendance.empty'.tr(),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              fontColor: const Color(0xFF64748B),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: records.length,
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 16.h);
                            },
                            itemBuilder: (context, index) {
                              final attendance = records[index];

                              final calculation = settings == null
                                  ? null
                                  : ref
                                        .read(
                                          calculateAttendanceHoursUseCaseProvider,
                                        )
                                        .call(
                                          monthlySalary: employee.salary,
                                          checkInTime: attendance.checkInTime,
                                          checkOutTime: attendance.checkOutTime,
                                          workingHoursPerDay:
                                              settings.workingHoursPerDay,
                                          multiplier: settings.multiplier,
                                        );

                              return AttendanceRecordCard(
                                name: employee.fullName,
                                department: departmentName,
                                date: attendance.attendanceDate,
                                status: attendance.status,
                                checkIn: attendance.checkInTime,
                                checkOut: attendance.checkOutTime,
                                workedHours: calculation?.actualWorkedHours,
                                overtimeHours: calculation?.overtimeHours,
                                deductionHours: calculation?.deductionHours,
                                onEdit: null,
                                onDelete: null,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmployeeHeaderCard extends StatelessWidget {
  final String name;
  final String department;

  const _EmployeeHeaderCard({
    required this.name,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title: name,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            fontColor: AppColors.black,
          ),
          SizedBox(height: 6.h),
          CustomText(
            title: department,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            fontColor: const Color(0xFF64748B),
          ),
        ],
      ),
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
