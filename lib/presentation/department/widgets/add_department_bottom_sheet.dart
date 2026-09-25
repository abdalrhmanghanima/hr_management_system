import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/inputs/custom_text_form.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:uuid/uuid.dart';

class AddDepartmentBottomSheet extends ConsumerStatefulWidget {
  const AddDepartmentBottomSheet({super.key});

  @override
  ConsumerState<AddDepartmentBottomSheet> createState() =>
      _AddDepartmentBottomSheetState();
}

class _AddDepartmentBottomSheetState
    extends ConsumerState<AddDepartmentBottomSheet> {
  final TextEditingController departmentController =
  TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    departmentController.dispose();
    super.dispose();
  }

  Future<void> _saveDepartment() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final department = DepartmentEntity(
      id: const Uuid().v4(),
      name: departmentController.text.trim(),
    );

    try {
      await ref
          .read(departmentProvider.notifier)
          .addDepartment(department);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add department'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final departmentState = ref.watch(departmentProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16.w,
          12.h,
          16.w,
          16.h,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.gray,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              Text(
                'Add Department',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),

              SizedBox(height: 20.h),

              CustomTextFormField(
                controller: departmentController,
                label: 'Department',
                isRequired: true,
                hint: 'e.g. Human Resources',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Department is required';
                  }

                  if (value.trim().length < 2) {
                    return 'Department must be at least 2 characters';
                  }

                  return null;
                },
              ),

              SizedBox(height: 20.h),

              CustomButton(
                title: 'Save Department',
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                isLoading: departmentState.isLoading,
                onTap: _saveDepartment,
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