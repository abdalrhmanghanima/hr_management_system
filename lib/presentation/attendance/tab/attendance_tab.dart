import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_record_card.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_floating_action_button.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_search_field.dart';

class AttendanceTab extends StatelessWidget {
  const AttendanceTab({super.key});

  @override
  Widget build(BuildContext context) {
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
            AppSearchField(hintText: 'Search by employee or date...'),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
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
            ),
          ],
        ),
      ),
      floatingActionButton: AppFloatingActionButton(onPressed: () {

      },),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
