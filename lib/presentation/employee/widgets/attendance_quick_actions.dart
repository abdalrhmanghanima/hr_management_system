import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/date_parser.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_action_result.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_action_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/today_attendance_provider.dart';
import 'package:hr_management_system/presentation/components/custom_snack_bar/custom_snack_bar.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/more/provider/general_settings_provider.dart';

class AttendanceQuickActions extends ConsumerWidget {
  final String employeeId;
  final double monthlySalary;

  const AttendanceQuickActions({
    super.key,
    required this.employeeId,
    required this.monthlySalary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayState = ref.watch(
      todayAttendanceProvider((employeeId: employeeId, date: todayKey())),
    );
    final isLoading = ref.watch(
      attendanceActionProvider.select((state) => state.isLoading),
    );

    final attendance = todayState.value;

    final hasCheckedIn = attendance?.checkInTime != null;
    final hasCheckedOut = attendance?.checkOutTime != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title: "Today's Attendance",
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),

        SizedBox(height: 12.h),

        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                label: 'Check In',
                time: attendance?.checkInTime,
                icon: Icons.login_rounded,
                color: AppColors.green,
                isEnabled: !hasCheckedIn && !isLoading,
                isLoading: isLoading && !hasCheckedIn,
                onTap: () => _checkIn(context, ref),
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: _QuickActionCard(
                label: 'Check Out',
                time: attendance?.checkOutTime,
                icon: Icons.logout_rounded,
                color: AppColors.red,
                isEnabled: hasCheckedIn && !hasCheckedOut && !isLoading,
                isLoading: isLoading && hasCheckedIn && !hasCheckedOut,
                onTap: () => _checkOut(context, ref),
              ),
            ),
          ],
        ),

        if (hasCheckedIn) ...[
          SizedBox(height: 10.h),
          _StatusMessage(attendance: attendance!),
        ],

        if (hasCheckedIn && hasCheckedOut) ...[
          SizedBox(height: 10.h),
          _WorkedHoursSummary(
            attendance: attendance!,
            monthlySalary: monthlySalary,
          ),
        ],
      ],
    );
  }

  Future<void> _checkIn(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(attendanceActionProvider.notifier)
        .checkIn(employeeId);

    if (!context.mounted) {
      return;
    }

    final message = switch (result) {
      AttendanceActionResult.success => 'Checked in successfully',
      AttendanceActionResult.alreadyCheckedIn =>
        'You have already checked in today',
      AttendanceActionResult.alreadyCheckedOut =>
        'You have already checked out today',
      AttendanceActionResult.checkInRequired =>
        'Check in first before checking out',
      AttendanceActionResult.failure => 'Failed to check in. Please try again',
    };

    CustomSnackBar.show(
      context,
      message: message,
      success: result == AttendanceActionResult.success,
    );
  }

  Future<void> _checkOut(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(attendanceActionProvider.notifier)
        .checkOut(employeeId);

    if (!context.mounted) {
      return;
    }

    final message = switch (result) {
      AttendanceActionResult.success => 'Checked out successfully',
      AttendanceActionResult.alreadyCheckedOut =>
        'You have already checked out today',
      AttendanceActionResult.checkInRequired =>
        'Check in first before checking out',
      AttendanceActionResult.alreadyCheckedIn =>
        'You have already checked in today',
      AttendanceActionResult.failure => 'Failed to check out. Please try again',
    };

    CustomSnackBar.show(
      context,
      message: message,
      success: result == AttendanceActionResult.success,
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final DateTime? time;
  final IconData icon;
  final Color color;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
    required this.isEnabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isEnabled ? color : AppColors.gray;

    return Opacity(
      opacity: isEnabled || isLoading ? 1 : 0.6,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isEnabled
                  ? activeColor.withValues(alpha: 0.35)
                  : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: activeColor,
                          ),
                        ),
                      )
                    : Icon(icon, color: activeColor, size: 20.w),
              ),

              SizedBox(height: 10.h),

              CustomText(
                title: label,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontColor: activeColor,
              ),

              SizedBox(height: 4.h),

              CustomText(
                title: time == null
                    ? 'Not recorded'
                    : DateParser.toDisplayTime(time!),
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                fontColor: AppColors.gray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final AttendanceEntity attendance;

  const _StatusMessage({required this.attendance});

  @override
  Widget build(BuildContext context) {
    final hasCheckedOut = attendance.checkOutTime != null;

    return CustomText(
      title: hasCheckedOut
          ? 'Attendance completed for today'
          : 'Checked in. Check out is now available',
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      fontColor: AppColors.gray,
    );
  }
}

class _WorkedHoursSummary extends ConsumerWidget {
  final AttendanceEntity attendance;
  final double monthlySalary;

  const _WorkedHoursSummary({
    required this.attendance,
    required this.monthlySalary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(generalSettingsProvider);

    return Container(
      width: Dimens.width,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: settingsState.when(
        loading: () => Center(
          child: SizedBox(
            width: 18.w,
            height: 18.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.gray,
            ),
          ),
        ),
        error: (error, stackTrace) => CustomText(
          title: 'Unable to load working hours settings',
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          fontColor: AppColors.red,
        ),
        data: (settings) {
          final calculation = ref
              .read(calculateAttendanceHoursUseCaseProvider)
              .call(
                monthlySalary: monthlySalary,
                checkInTime: attendance.checkInTime,
                checkOutTime: attendance.checkOutTime,
                workingHoursPerDay: settings.workingHoursPerDay,
                multiplier: settings.multiplier,
              );

          return Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Worked',
                  value: '${calculation.actualWorkedHours} hrs',
                  color: AppColors.black,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Overtime',
                  value: '${calculation.overtimeHours} hrs',
                  color: AppColors.green,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Deduction',
                  value: '${calculation.deductionHours} hrs',
                  color: AppColors.red,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.color = AppColors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title: label,
          fontSize: 11.sp,
          fontWeight: FontWeight.w400,
          fontColor: AppColors.gray,
        ),
        SizedBox(height: 4.h),
        CustomText(
          title: value,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          fontColor: color,
        ),
      ],
    );
  }
}
