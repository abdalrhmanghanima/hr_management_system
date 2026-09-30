import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';
import 'package:hr_management_system/core/utils/date_picker_helper.dart';
import 'package:hr_management_system/presentation/attendance/provider/selected_attendance_status_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/selected_employee_provider.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/components/inputs/custom_dropdown_field.dart';
import 'package:hr_management_system/presentation/components/inputs/custom_text_form.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';

class AttendanceForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController attendanceDateController;
  final TextEditingController checkInTimeController;
  final TextEditingController checkOutTimeController;

  const AttendanceForm({
    super.key,
    required this.formKey,
    required this.attendanceDateController,
    required this.checkInTimeController,
    required this.checkOutTimeController,
  });

  static const List<String> statuses = ['Present', 'Absent', 'Late', 'Leave'];

  String? _requiredValidator(String? value, String errorKey) {
    if (value == null || value.trim().isEmpty) {
      return errorKey.tr();
    }

    return null;
  }

  Future<void> _pickAttendanceDate(BuildContext context) async {
    final date = await DatePickerHelper.pickFormattedDate(context: context);

    if (date != null) {
      attendanceDateController.text = date;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeState = ref.watch(employeeProvider);
    final selectedEmployee = ref.watch(selectedEmployeeProvider);
    final selectedStatus = ref.watch(selectedAttendanceStatusProvider);
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              title: 'attendance.form_title'.tr(),
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),

            SizedBox(height: 12.h),

            Container(
              width: Dimens.width,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    employeeState.when(
                      data: (data) {
                        return CustomDropdownField<String>(
                          label: 'attendance.employee'.tr(),
                          isRequired: true,
                          hint: 'attendance.select_employee'.tr(),
                          value: selectedEmployee,
                          items: data.map((employee) {
                            return DropdownMenuItem<String>(
                              value: employee.id,
                              child: CustomText(title: employee.fullName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            ref.read(selectedEmployeeProvider.notifier).state =
                                value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'validation.attendance.employee_required'
                                  .tr();
                            }

                            return null;
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) => Center(
                        child: CustomText(
                          title: error.toString(),
                          fontColor: AppColors.red,
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    CustomTextFormField(
                      controller: attendanceDateController,
                      label: 'attendance.date'.tr(),
                      isRequired: true,
                      hint: 'attendance.date_hint'.tr(),
                      readOnly: true,
                      onTap: () => _pickAttendanceDate(context),
                      validator: (value) => _requiredValidator(
                        value,
                        'validation.attendance.date_required',
                      ),
                      suffix: Padding(
                        padding: EdgeInsets.all(14.r),
                        child: Icon(
                          Icons.calendar_month_outlined,
                          size: 20.w,
                          color: AppColors.black,
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    CustomDropdownField<String>(
                      label: 'attendance.status'.tr(),
                      isRequired: true,
                      hint: 'attendance.select_status'.tr(),
                      value: selectedStatus,
                      items: statuses.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            AppLocalization.attendanceStatus(
                              context,
                              status,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        ref
                                .read(selectedAttendanceStatusProvider.notifier)
                                .state =
                            value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'validation.attendance.status_required'.tr();
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 16.h),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            controller: checkInTimeController,
                            label: 'attendance.check_in'.tr(),
                            hint: 'attendance.check_in_hint'.tr(),
                            readOnly: true,
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (time != null) {
                                checkInTimeController.text = time.format(
                                  context,
                                );
                              }
                            },
                          ),
                        ),

                        SizedBox(width: 14.w),

                        Expanded(
                          child: CustomTextFormField(
                            controller: checkOutTimeController,
                            label: 'attendance.check_out'.tr(),
                            hint: 'attendance.check_out_hint'.tr(),
                            readOnly: true,
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (time != null) {
                                checkOutTimeController.text = time.format(
                                  context,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
