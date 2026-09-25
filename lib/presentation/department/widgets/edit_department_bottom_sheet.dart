import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/inputs/custom_text_form.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';

class EditDepartmentBottomSheet extends ConsumerStatefulWidget {
  final DepartmentEntity department;

  const EditDepartmentBottomSheet({
    super.key,
    required this.department,
  });

  @override
  ConsumerState<EditDepartmentBottomSheet> createState() =>
      _EditDepartmentBottomSheetState();
}

class _EditDepartmentBottomSheetState
    extends ConsumerState<EditDepartmentBottomSheet> {
  late final TextEditingController departmentController;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    departmentController = TextEditingController(
      text: widget.department.name,
    );
  }

  @override
  void dispose() {
    departmentController.dispose();
    super.dispose();
  }

  Future<void> _updateDepartment() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final department = DepartmentEntity(
      id: widget.department.id,
      name: departmentController.text.trim(),
    );

    try {
      await ref
          .read(departmentProvider.notifier)
          .updateDepartment(department);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update department'),
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
                'Edit Department',
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
                title: 'Save Changes',
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                isLoading: departmentState.isLoading,
                onTap: _updateDepartment,
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