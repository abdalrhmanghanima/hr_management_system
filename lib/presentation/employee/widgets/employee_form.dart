import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/date_picker_helper.dart';
import 'package:hr_management_system/domain/employee/validation/employee_validator.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/components/inputs/custom_dropdown_field.dart';
import 'package:hr_management_system/presentation/components/inputs/custom_text_form.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/selected_department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/gender_provider.dart';

class EmployeeForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController fullNameController;
  final TextEditingController addressController;
  final TextEditingController phoneNumberController;
  final TextEditingController birthDateController;
  final TextEditingController nationalIdController;
  final TextEditingController nationalityController;
  final TextEditingController contractDateController;
  final TextEditingController salaryController;

  const EmployeeForm({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.addressController,
    required this.phoneNumberController,
    required this.birthDateController,
    required this.nationalIdController,
    required this.nationalityController,
    required this.contractDateController,
    required this.salaryController,
  });

  static const List<String> genders = EmployeeValidator.genders;

  Future<void> _pickBirthDate(BuildContext context) async {
    final date = await DatePickerHelper.pickFormattedDate(context: context);

    if (date != null) {
      birthDateController.text = date;
    }
  }

  Future<void> _pickContractDate(BuildContext context) async {
    final date = await DatePickerHelper.pickFormattedDate(context: context);

    if (date != null) {
      contractDateController.text = date;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentsState = ref.watch(departmentProvider);
    final selectedDepartment = ref.watch(selectedDepartmentProvider);
    final selectedGender = ref.watch(genderProvider);

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              title: "Personal Information",
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
                    CustomTextFormField(
                      controller: fullNameController,
                      label: "Full Name",
                      isRequired: true,
                      hint: "e.g. Ahmed Mohamed",
                      validator: EmployeeValidator.fullName,
                    ),

                    SizedBox(height: 16.h),

                    CustomTextFormField(
                      controller: addressController,
                      label: "Address",
                      isRequired: true,
                      hint: "home address",
                      validator: EmployeeValidator.address,
                    ),

                    SizedBox(height: 16.h),

                    CustomTextFormField(
                      controller: phoneNumberController,
                      label: "Phone Number",
                      isRequired: true,
                      hint: "e.g. 01012345678",
                      textInputType: TextInputType.phone,
                      validator: EmployeeValidator.phoneNumber,
                    ),

                    SizedBox(height: 16.h),

                    CustomTextFormField(
                      controller: birthDateController,
                      label: "Birth Date",
                      isRequired: true,
                      hint: "dd/mm/yyyy",
                      readOnly: true,
                      onTap: () => _pickBirthDate(context),
                      validator: EmployeeValidator.birthDateText,
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
                      label: "Gender",
                      isRequired: true,
                      hint: "Select Gender",
                      value: selectedGender,
                      items: genders.map((gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        ref.read(genderProvider.notifier).state = value;
                      },
                      validator: EmployeeValidator.gender,
                    ),

                    SizedBox(height: 16.h),

                    CustomTextFormField(
                      controller: nationalIdController,
                      label: "National ID",
                      isRequired: true,
                      hint: "14 digits national ID",
                      textInputType: TextInputType.number,
                      validator: EmployeeValidator.nationalId,
                    ),

                    SizedBox(height: 16.h),

                    CustomTextFormField(
                      controller: nationalityController,
                      label: "Nationality",
                      isRequired: true,
                      hint: "Egyptian",
                      validator: EmployeeValidator.nationality,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12.h),

            CustomText(
              title: "Work Information",
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
                    departmentsState.when(
                      loading: () => const CircularProgressIndicator(),

                      error: (error, stackTrace) {
                        return CustomText(
                          title: 'Failed to load departments',
                          fontColor: AppColors.red,
                        );
                      },

                      data: (departments) {
                        return CustomDropdownField<String>(
                          label: 'Department',
                          isRequired: true,
                          hint: 'Select Department',
                          value: selectedDepartment,
                          items: departments.map((department) {
                            return DropdownMenuItem<String>(
                              value: department.id,
                              child: CustomText(title: department.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            ref
                                    .read(selectedDepartmentProvider.notifier)
                                    .state =
                                value;
                          },
                          validator: EmployeeValidator.department,
                        );
                      },
                    ),

                    SizedBox(height: 16.h),

                    CustomTextFormField(
                      controller: contractDateController,
                      label: "Contract Date",
                      isRequired: true,
                      hint: "dd/mm/yyyy",
                      readOnly: true,
                      onTap: () => _pickContractDate(context),
                      validator: EmployeeValidator.contractDateText,
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

                    CustomTextFormField(
                      controller: salaryController,
                      label: "Salary (EGP)",
                      isRequired: true,
                      hint: "Monthly Salary",
                      textInputType: TextInputType.number,
                      validator: EmployeeValidator.salaryText,
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
