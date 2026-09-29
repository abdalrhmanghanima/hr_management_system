import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/date_parser.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class AttendanceRecordCard extends StatelessWidget {
  final String name;
  final String department;
  final DateTime date;
  final String status;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AttendanceRecordCard({
    super.key,
    required this.name,
    required this.department,
    required this.date,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                      title: name,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      fontColor: AppColors.black,
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      title: department,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      fontColor: const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: status),
            ],
          ),

          SizedBox(height: 14.h),

          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 15.w,
                color: const Color(0xFF64748B),
              ),
              SizedBox(width: 6.w),
              CustomText(
                title: DateParser.toDisplayDate(date),
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                fontColor: const Color(0xFF475569),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: _TimeInfo(
                  label: 'Check In',
                  value: _formatTime(checkIn),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _TimeInfo(
                  label: 'Check Out',
                  value: _formatTime(checkOut),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          SizedBox(height: 10.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 17.w,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 5.w),
                      CustomText(
                        title: 'Edit',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        fontColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 17.w,
                        color: AppColors.red,
                      ),
                      SizedBox(width: 5.w),
                      CustomText(
                        title: 'Delete',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        fontColor: AppColors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) {
      return '--';
    }

    return DateParser.toDisplayTime(time);
  }
}

class _TimeInfo extends StatelessWidget {
  final String label;
  final String value;

  const _TimeInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title: label,
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            fontColor: const Color(0xFF64748B),
          ),
          SizedBox(height: 5.h),
          CustomText(
            title: value,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            fontColor: AppColors.black,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color background;

    switch (status) {
      case 'Present':
        color = AppColors.green;
        background = const Color(0xFFE8F8F1);
        break;

      case 'Late':
        color = const Color(0xFFD97706);
        background = const Color(0xFFFFF7E6);
        break;

      case 'Absent':
        color = AppColors.red;
        background = const Color(0xFFFEECEC);
        break;

      default:
        color = const Color(0xFF64748B);
        background = const Color(0xFFF1F5F9);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: CustomText(
        title: status,
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        fontColor: color,
      ),
    );
  }
}
