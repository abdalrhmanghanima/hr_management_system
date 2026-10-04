import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/constants/constants.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';
import 'package:hr_management_system/core/responsive/responsive_widgets.dart';
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
    final date = await DatePickerHelper.pickFormattedDate(
      context: context,
      firstDate: DateTime(companyStartYear),
    );

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
              title: "employee.personal_information".tr(),
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AdaptiveFormRow(
                      children: [
                        CustomTextFormField(
                          controller: fullNameController,
                          label: "employee.field.full_name".tr(),
                          isRequired: true,
                          hint: "employee.hint.full_name".tr(),
                          validator: AppLocalization.translateValidator(
                            EmployeeValidator.fullName,
                          ),
                        ),
                        CustomTextFormField(
                          controller: addressController,
                          label: "employee.field.address".tr(),
                          isRequired: true,
                          hint: "employee.hint.address".tr(),
                          validator: AppLocalization.translateValidator(
                            EmployeeValidator.address,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    AdaptiveFormRow(
                      children: [
                        CustomTextFormField(
                          controller: phoneNumberController,
                          label: "employee.field.phone_number".tr(),
                          isRequired: true,
                          hint: "employee.hint.phone_number".tr(),
                          textInputType: TextInputType.phone,
                          validator: AppLocalization.translateValidator(
                            EmployeeValidator.phoneNumber,
                          ),
                        ),
                        CustomTextFormField(
                          controller: birthDateController,
                          label: "employee.field.birth_date".tr(),
                          isRequired: true,
                          hint: "employee.hint.date".tr(),
                          readOnly: true,
                          onTap: () => _pickBirthDate(context),
                          validator: AppLocalization.translateValidator(
                            EmployeeValidator.birthDateText,
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
                      ],
                    ),

                    SizedBox(height: 16.h),

                    AdaptiveFormRow(
                      children: [
                        CustomDropdownField<String>(
                          label: "employee.field.gender".tr(),
                          isRequired: true,
                          hint: "employee.select_gender".tr(),
                          value: selectedGender,
                          items: genders.map((gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child:
                                  Text(AppLocalization.gender(context, gender)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            ref.read(genderProvider.notifier).state = value;
                          },
                          validator: AppLocalization.translateValidator(
                            EmployeeValidator.gender,
                          ),
                        ),
                        CustomTextFormField(
                          controller: nationalIdController,
                          label: "employee.field.national_id".tr(),
                          isRequired: true,
                          hint: "employee.hint.national_id".tr(),
                          textInputType: TextInputType.number,
                          validator: AppLocalization.translateValidator(
                            EmployeeValidator.nationalId,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    CustomTextFormField(
                      controller: nationalityController,
                      label: "employee.field.nationality".tr(),
                      isRequired: true,
                      hint: "employee.hint.nationality".tr(),
                      validator: AppLocalization.translateValidator(
                        EmployeeValidator.nationality,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12.h),

            CustomText(
              title: "employee.work_information".tr(),
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),

            SizedBox(height: 12.h),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AdaptiveFormRow(
                      children: [
                        departmentsState.when(
                          loading: () => const CircularProgressIndicator(),

                          error: (error, stackTrace) {
                            return CustomText(
                              title: 'department.load_failed'.tr(),
                              fontColor: AppColors.red,
                            );
                          },

                          data: (departments) {
                            return CustomDropdownField<String>(
                              label: 'employee.field.department'.tr(),
                              isRequired: true,
                              hint: 'employee.select_department'.tr(),
                              value: selectedDepartment,
                              items: departments.map((department) {
                                return DropdownMenuItem<String>(
                                  value: department.id,
                                  child: CustomText(title: department.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                ref
                                        .read(
                                          selectedDepartmentProvider.notifier,
                                        )
                                        .state =
                                    value;
                              },
                              validator: AppLocalization.translateValidator(
                                EmployeeValidator.department,
                              ),
                            );
                          },
                        ),
                        CustomTextFormField(
                          controller: contractDateController,
                          label: "employee.field.contract_date".tr(),
                          isRequired: true,
                          hint: "employee.hint.date".tr(),
                          readOnly: true,
                          onTap: () => _pickContractDate(context),
                          validator: AppLocalization.translateValidator(
                            EmployeeValidator.contractDateText,
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
                      ],
                    ),

                    SizedBox(height: 16.h),

                    CustomTextFormField(
                      controller: salaryController,
                      label: "employee.field.salary".tr(),
                      isRequired: true,
                      hint: "employee.hint.salary".tr(),
                      textInputType: TextInputType.number,
                      validator: AppLocalization.translateValidator(
                        EmployeeValidator.salaryText,
                      ),
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

