import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_summary.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class AttendanceImportResultDialog extends StatelessWidget {
  final AttendanceImportSummary summary;

  const AttendanceImportResultDialog({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420.w,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      summary.hasFailures
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color: _accentColor,
                      size: 28.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomText(
                      title: summary.hasFailures
                          ? 'Import completed with issues'
                          : 'Attendance imported',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _CountChip(
                    label: 'Rows: ${summary.totalRows}',
                    color: AppColors.gray,
                  ),
                  _CountChip(
                    label: 'New employees: ${summary.employeesCreated}',
                    color: AppColors.green,
                  ),
                  _CountChip(
                    label:
                        'Existing employees: ${summary.existingEmployeesUsed}',
                    color: const Color(0xFF0F766E),
                  ),
                  _CountChip(
                    label: 'Added: ${summary.added}',
                    color: AppColors.primary,
                  ),
                  _CountChip(
                    label: 'Updated: ${summary.updated}',
                    color: AppColors.darkGray,
                  ),
                  if (summary.skipped > 0)
                    _CountChip(
                      label: 'Skipped: ${summary.skipped}',
                      color: AppColors.darkGray,
                    ),
                  if (summary.failed > 0)
                    _CountChip(
                      label: 'Failed: ${summary.failed}',
                      color: AppColors.red,
                    ),
                ],
              ),
              if (summary.issues.isNotEmpty) ...[
                SizedBox(height: 16.h),
                CustomText(
                  title: 'Rows that need attention',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontColor: AppColors.black,
                ),
                SizedBox(height: 8.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: summary.issues.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 12.h, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final issue = summary.issues[index];

                      return CustomText(
                        title: 'Row ${issue.rowNumber}: ${issue.reason}',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        fontColor: AppColors.gray,
                      );
                    },
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              CustomButton(
                title: 'Done',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                bg: AppColors.primary,
                width: double.infinity,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _accentColor {
    return summary.hasFailures ? const Color(0xFFB45309) : AppColors.green;
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final Color color;

  const _CountChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: CustomText(
        title: label,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        fontColor: color,
      ),
    );
  }
}
