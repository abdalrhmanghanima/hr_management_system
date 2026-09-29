import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
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

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
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
              title: 'Attendance Information',
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
                          label: 'Employee',
                          isRequired: true,
                          hint: 'Select Employee',
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
                              return 'Employee is required';
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
                      label: 'Attendance Date',
                      isRequired: true,
                      hint: 'dd/mm/yyyy',
                      readOnly: true,
                      onTap: () => _pickAttendanceDate(context),
                      validator: (value) =>
                          _requiredValidator(value, 'Attendance Date'),
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
                      label: 'Attendance Status',
                      isRequired: true,
                      hint: 'Select Status',
                      value: selectedStatus,
                      items: statuses.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
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
                          return 'Attendance Status is required';
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
                            label: 'Check-In Time',
                            hint: 'e.g. 09:00 AM',
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
                            label: 'Check-Out Time',
                            hint: 'e.g. 05:00 PM',
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
