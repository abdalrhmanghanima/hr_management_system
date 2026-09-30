import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
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
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';

class EditAttendanceScreen extends ConsumerStatefulWidget {
  final AttendanceEntity attendance;

  const EditAttendanceScreen({super.key, required this.attendance});

  @override
  ConsumerState<EditAttendanceScreen> createState() =>
      _EditAttendanceScreenState();
}

class _EditAttendanceScreenState extends ConsumerState<EditAttendanceScreen> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController attendanceDateController =
      TextEditingController();

  final TextEditingController checkInTimeController = TextEditingController();

  final TextEditingController checkOutTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    attendanceDateController.text = DateParser.toDisplayDate(
      widget.attendance.attendanceDate,
    );

    final checkInTime = widget.attendance.checkInTime;

    if (checkInTime != null) {
      checkInTimeController.text = DateParser.toDisplayTime(checkInTime);
    }

    final checkOutTime = widget.attendance.checkOutTime;

    if (checkOutTime != null) {
      checkOutTimeController.text = DateParser.toDisplayTime(checkOutTime);
    }

    Future.microtask(() {
      ref.read(employeeProvider.notifier).getEmployees();

      ref.read(selectedEmployeeProvider.notifier).state =
          widget.attendance.employeeId;

      ref.read(selectedAttendanceStatusProvider.notifier).state =
          widget.attendance.status;
    });
  }

  @override
  void dispose() {
    attendanceDateController.dispose();
    checkInTimeController.dispose();
    checkOutTimeController.dispose();
    super.dispose();
  }

  Future<void> _updateAttendance() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final employeeId = ref.read(selectedEmployeeProvider);
    final attendanceStatus = ref.read(selectedAttendanceStatusProvider);

    if (employeeId == null || attendanceStatus == null) {
      return;
    }

    final attendanceDate = DateParser.fromDisplayDate(
      attendanceDateController.text,
    );

    final attendance = AttendanceEntity(
      id: widget.attendance.id,
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

    await ref.read(attendanceProvider.notifier).updateAttendance(attendance);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceProvider);

    return PermissionGuard(
      module: GroupModules.attendance,
      action: PermissionAction.edit,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(title: 'attendance.edit_title'.tr()),
        body: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AttendanceForm(
                  formKey: formKey,
                  attendanceDateController: attendanceDateController,
                  checkInTimeController: checkInTimeController,
                  checkOutTimeController: checkOutTimeController,
                ),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                title: 'attendance.update_button'.tr(),
                fontSize: 15.sp,
                isLoading: attendanceState.isLoading,
                fontWeight: FontWeight.w400,
                onTap: _updateAttendance,
                bg: AppColors.primary,
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
