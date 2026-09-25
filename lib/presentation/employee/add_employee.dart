import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/date_parser.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/selected_department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/gender_provider.dart';
import 'package:hr_management_system/presentation/employee/widgets/employee_form.dart';
import 'package:uuid/uuid.dart';

class AddEmployee extends ConsumerStatefulWidget {
  const AddEmployee({super.key});

  @override
  ConsumerState<AddEmployee> createState() => _AddEmployeeState();
}

class _AddEmployeeState extends ConsumerState<AddEmployee> {
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

    Future.microtask(() {
      ref.read(departmentProvider.notifier).getDepartments();
    });
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

  Future<void> _saveEmployee() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final gender = ref.read(genderProvider);
    final departmentId = ref.read(selectedDepartmentProvider);

    if (gender == null || departmentId == null) {
      return;
    }

    final employee = EmployeeEntity(
      id: const Uuid().v4(),
      fullName: fullNameController.text.trim(),
      address: addressController.text.trim(),
      phoneNumber: phoneNumberController.text.trim(),
      birthDate: DateParser.fromDisplayDate(
        birthDateController.text.trim(),
      ),
      nationalId: nationalIdController.text.trim(),
      nationality: nationalityController.text.trim(),
      gender: gender,
      departmentId: departmentId,
      contractDate: DateParser.fromDisplayDate(
        contractDateController.text.trim(),
      ),
      salary: double.parse(
        salaryController.text.trim(),
      ),
    );

    await ref.read(employeeProvider.notifier).addEmployee(employee);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeState = ref.watch(employeeProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const CustomAppBar(
        title: "Add New Employee",
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
              title: "Save Employee",
              fontSize: 15.sp,
              isLoading: employeeState.isLoading,
              fontWeight: FontWeight.w400,
              onTap: _saveEmployee,
              bg: AppColors.primary,
            ),

            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}