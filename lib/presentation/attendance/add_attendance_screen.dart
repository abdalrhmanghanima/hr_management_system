import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/responsive/breakpoints.dart';
import 'package:hr_management_system/core/responsive/responsive_widgets.dart';
import 'package:hr_management_system/core/utils/date_parser.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/selected_attendance_status_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/selected_employee_provider.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_form.dart';
import 'package:hr_management_system/presentation/authorization/widgets/permission_guard.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_snack_bar/custom_snack_bar.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';

class AddAttendanceScreen extends ConsumerStatefulWidget {
  const AddAttendanceScreen({super.key});

  @override
  ConsumerState<AddAttendanceScreen> createState() =>
      _AddAttendanceScreenState();
}

class _AddAttendanceScreenState extends ConsumerState<AddAttendanceScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController attendanceDateController =
      TextEditingController();
  final TextEditingController checkInTimeController = TextEditingController();
  final TextEditingController checkOutTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(employeeProvider.notifier).getEmployees();
    });
  }

  @override
  void dispose() {
    attendanceDateController.dispose();
    checkInTimeController.dispose();
    checkOutTimeController.dispose();
    super.dispose();
  }

  Future<void> _saveAttendance() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final attendanceStatus = ref.read(selectedAttendanceStatusProvider);
    final employeeId = ref.read(selectedEmployeeProvider);

    if (attendanceStatus == null || employeeId == null) {
      return;
    }

    final attendanceDate = DateParser.fromDisplayDate(
      attendanceDateController.text,
    );

    final attendance = AttendanceEntity(
      id: AttendanceEntity.documentIdFor(employeeId, attendanceDate),
      employeeId: employeeId,
      attendanceDate: attendanceDate,
      status: attendanceStatus,
      checkInTime: DateParser.fromDisplayTime(
        checkInTimeController.text,
        date: attendanceDate,
      ),
      checkOutTime: DateParser.fromDisplayTime(
        checkOutTimeController.text,
        date: attendanceDate,
      ),
    );

    final result = await ref
        .read(attendanceProvider.notifier)
        .addAttendance(attendance);

    if (!mounted) {
      return;
    }

    switch (result) {
      case SaveResult.success:
        CustomSnackBar.show(
          context,
          message: 'attendance.add_success'.tr(),
          success: true,
        );
        Navigator.pop(context);
        break;
      case SaveResult.duplicate:
        CustomSnackBar.show(context, message: 'attendance.duplicate'.tr());
        break;
      case SaveResult.failure:
        CustomSnackBar.show(context, message: 'attendance.add_failed'.tr());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceProvider);
    return PermissionGuard(
      module: GroupModules.attendance,
      action: PermissionAction.add,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(title: "attendance.add_title".tr()),
        body: Padding(
          padding: EdgeInsets.all(16.r),
          child: MaxWidthBox(
            maxWidth: AppBreakpoints.formMaxWidth,
            applyFromWidth: AppBreakpoints.desktopMinWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AttendanceForm(
                  formKey: formKey,
                  attendanceDateController: attendanceDateController,
                  checkInTimeController: checkInTimeController,
                  checkOutTimeController: checkOutTimeController,
                ),
                SizedBox(height: 16.h),

                CustomButton(
                  title: 'attendance.save_button'.tr(),
                  fontSize: 15.sp,
                  isLoading: attendanceState.isLoading,
                  fontWeight: FontWeight.w400,
                  onTap: _saveAttendance,
                  bg: AppColors.primary,
                ),

                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
