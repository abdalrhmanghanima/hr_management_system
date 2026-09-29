import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/date_picker_helper.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/components/inputs/custom_text_form.dart';

class OfficialHolidayForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController dateController;
  final DateTime? initialDate;

  const OfficialHolidayForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.dateController,
    this.initialDate,
  });

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  Future<void> _pickHolidayDate(BuildContext context) async {
    final date = await DatePickerHelper.pickFormattedDate(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      dateController.text = date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              title: 'Holiday Information',
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
                      controller: nameController,
                      label: 'Holiday Name',
                      isRequired: true,
                      hint: 'Enter holiday name',
                      validator: (value) =>
                          _requiredValidator(value, 'Holiday Name'),
                    ),

                    SizedBox(height: 16.h),

                    CustomTextFormField(
                      controller: dateController,
                      label: 'Date',
                      isRequired: true,
                      hint: 'dd/mm/yyyy',
                      readOnly: true,
                      onTap: () => _pickHolidayDate(context),
                      validator: (value) => _requiredValidator(value, 'Date'),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
