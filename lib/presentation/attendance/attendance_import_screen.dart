import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/enums/attendance_import_status.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_summary.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_import_provider.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_import_button.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_import_card.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_import_header.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_import_result_dialog.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_selected_file.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_snack_bar/custom_snack_bar.dart';

class AttendanceImportScreen extends ConsumerWidget {
  const AttendanceImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceImportProvider);

    ref.listen<AttendanceImportStatus>(
      attendanceImportProvider.select((state) => state.status),
      (previous, next) {
        if (next == AttendanceImportStatus.error) {
          _showError(context, state.message);
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(title: 'attendance_import.title'.tr()),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            const AttendanceImportHeader(),

            SizedBox(height: 20.h),

            AttendanceImportCard(
              onChooseFile: () {
                ref.read(attendanceImportProvider.notifier).selectFile();
              },
              isChoosingFile:
                  state.status == AttendanceImportStatus.selectingFile,
            ),

            if (state.file != null) ...[
              SizedBox(height: 16.h),

              AttendanceSelectedFile(
                fileName: state.file!.name,
                onChange: () {
                  ref.read(attendanceImportProvider.notifier).selectFile();
                },
                onRemove: () {
                  ref.read(attendanceImportProvider.notifier).removeFile();
                },
              ),
            ],

            SizedBox(height: 24.h),

            AttendanceImportButton(
              status: state.status,
              statusMessage: state.message,
              onPressed: state.file == null || state.isBusy
                  ? null
                  : () => _import(context, ref),
            ),

            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final summary = await ref
        .read(attendanceImportProvider.notifier)
        .importAttendance();

    if (summary == null || !context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AttendanceImportResultDialog(summary: summary);
      },
    );

    if (!context.mounted) {
      return;
    }

    _showSummaryMessage(context, summary);

    ref.read(attendanceImportProvider.notifier).clearResult();
  }

  void _showSummaryMessage(
    BuildContext context,
    AttendanceImportSummary summary,
  ) {
    final message = summary.added == 0 && summary.updated == 0
        ? 'attendance_import.none_imported'.tr()
        : 'attendance_import.summary'.tr(
            namedArgs: {
              'added': summary.added.toString(),
              'updated': summary.updated.toString(),
            },
          );

    if (summary.failed > 0) {
      final failedText = 'attendance_import.chip_failed'.tr(
        namedArgs: {'count': summary.failed.toString()},
      );
      CustomSnackBar.show(
        context,
        message: '$message, $failedText',
      );
      return;
    }

    CustomSnackBar.show(context, message: message, success: true);
  }

  void _showError(BuildContext context, String? message) {
    CustomSnackBar.show(
      context,
      message: message ?? 'attendance_import.status_error'.tr(),
    );
  }
}
