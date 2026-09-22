import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';

class AttendanceRecordCard extends StatelessWidget {
  final String name;
  final String department;
  final String date;
  final String status;
  final String checkIn;
  final String checkOut;
  final String overtime;
  final Color statusColor;
  final Color statusBackgroundColor;

  const AttendanceRecordCard({
    super.key,
    required this.name,
    required this.department,
    required this.date,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.overtime,
    required this.statusColor,
    required this.statusBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
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
                    Text(
                      name,
                      style: TextStyle(
                        color: const Color(0xFF111827),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          department,
                          style: TextStyle(
                            color: const Color(0xFF94A3B8),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(
                            color: const Color(0xFF94A3B8),
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            color: const Color(0xFF94A3B8),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: statusBackgroundColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: statusColor,
                      size: 15.w,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-In',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      checkIn,
                      style: TextStyle(
                        color: const Color(0xFF111827),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-Out',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      checkOut,
                      style: TextStyle(
                        color: const Color(0xFF111827),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          Row(
            children: [
              Icon(
                Icons.access_time,
                color: AppColors.green,
                size: 16.w,
              ),
              SizedBox(width: 5.w),
              Text(
                overtime,
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 18.w,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 18.w),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: AppColors.red,
                      size: 18.w,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}