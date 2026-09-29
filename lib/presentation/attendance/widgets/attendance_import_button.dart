import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/enums/attendance_import_status.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class AttendanceImportButton extends StatelessWidget {
  final AttendanceImportStatus status;
  final VoidCallback? onPressed;
  final String title;
  final String? statusMessage;

  const AttendanceImportButton({
    super.key,
    this.status = AttendanceImportStatus.idle,
    this.onPressed,
    this.title = 'Import Attendance',
    this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading =
        status == AttendanceImportStatus.parsing ||
        status == AttendanceImportStatus.importing;

    final isDisabled = status == AttendanceImportStatus.selectingFile;

    final message = statusMessage ?? _defaultStatusMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: isLoading || isDisabled || onPressed == null ? 0.6 : 1,
          child: CustomButton(
            title: title,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            bg: AppColors.primary,
            width: double.infinity,
            radius: 14.r,
            isLoading: isLoading,
            onTap: isDisabled ? null : onPressed,
          ),
        ),

        if (message != null) ...[
          SizedBox(height: 12.h),

          CustomText(
            title: message,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            fontColor: _statusColor,
          ),
        ],
      ],
    );
  }

  String? get _defaultStatusMessage {
    switch (status) {
      case AttendanceImportStatus.parsing:
        return 'Reading the attendance file, please wait...';

      case AttendanceImportStatus.importing:
        return 'Importing attendance, please wait...';

      case AttendanceImportStatus.success:
        return 'Attendance imported successfully';

      case AttendanceImportStatus.partialSuccess:
        return 'Attendance imported with some rows skipped';

      case AttendanceImportStatus.error:
        return 'Failed to import attendance. Please try again';

      case AttendanceImportStatus.selectingFile:
      case AttendanceImportStatus.idle:
        return null;
    }
  }

  Color get _statusColor {
    switch (status) {
      case AttendanceImportStatus.success:
        return AppColors.green;

      case AttendanceImportStatus.partialSuccess:
        return const Color(0xFFB45309);

      case AttendanceImportStatus.error:
        return AppColors.red;

      case AttendanceImportStatus.selectingFile:
      case AttendanceImportStatus.parsing:
      case AttendanceImportStatus.importing:
      case AttendanceImportStatus.idle:
        return AppColors.gray;
    }
  }
}
