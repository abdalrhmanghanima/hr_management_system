import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/employee/providers/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/gender_provider.dart';
import 'package:hr_management_system/presentation/employee/widgets/employee_form.dart';

class EditEmployee extends ConsumerStatefulWidget {
  final String employeeId;

  const EditEmployee({
    super.key,
    required this.employeeId,
  });

  @override
  ConsumerState<EditEmployee> createState() => _EditEmployeeState();
}

class _EditEmployeeState extends ConsumerState<EditEmployee> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController nationalityController =
  TextEditingController();
  final TextEditingController contractDateController =
  TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadEmployee();
  }

  void _loadEmployee() {
    // Firebase employee data will be loaded here.
  }

  @override
  void dispose() {
    fullNameController.dispose();
    addressController.dispose();
    phoneNumberController.dispose();
    birthDateController.dispose();
    nationalIdController.dispose();
    nationalityController.dispose();
    contractDateController.dispose();
    salaryController.dispose();

    super.dispose();
  }

  void _updateEmployee() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final gender = ref.read(genderProvider);
    final department = ref.read(departmentProvider);

    if (gender == null || department == null) {
      return;
    }

    // Update employee logic will be added here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const CustomAppBar(
        title: "Edit Employee",
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            Expanded(
              child: EmployeeForm(
                formKey: formKey,
                fullNameController: fullNameController,
                addressController: addressController,
                phoneNumberController: phoneNumberController,
                birthDateController: birthDateController,
                nationalIdController: nationalIdController,
                nationalityController: nationalityController,
                contractDateController: contractDateController,
                salaryController: salaryController,
              ),
            ),

            SizedBox(height: 16.h),

            CustomButton(
              title: "Update Employee",
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              onTap: _updateEmployee,
              bg: AppColors.primary,
            ),

            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}