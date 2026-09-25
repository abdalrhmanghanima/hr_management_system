import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/add_employee.dart';
import 'package:hr_management_system/presentation/employee/employee_details.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/employee/widgets/employee_card.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_floating_action_button.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_search_field.dart';

class EmployeesTab extends ConsumerStatefulWidget {
  const EmployeesTab({super.key});

  @override
  ConsumerState<EmployeesTab> createState() => _EmployeesTabState();
}

class _EmployeesTabState extends ConsumerState<EmployeesTab> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(employeeProvider.notifier).getEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeeState = ref.watch(employeeProvider);
    final departmentState = ref.watch(departmentProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: CustomText(
          title: "Employees",
          fontSize: 18.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSearchField(
              hintText: 'Search by name, phone, national ID...',
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: employeeState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Center(
                  child: CustomText(
                    title: error.toString(),
                    fontColor: AppColors.red,
                  ),
                ),
                data: (employees) {
                  if (employees.isEmpty) {
                    return const Center(
                      child: CustomText(
                        title: 'No employees found',
                      ),
                    );
                  }

                  final departments = departmentState.value ?? [];

                  final departmentNames = {
                    for (final department in departments)
                      department.id: department.name,
                  };

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: employees.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final employee = employees[index];

                      return EmployeeCard(
                        name: employee.fullName,
                        group:
                        departmentNames[employee.departmentId] ?? '',
                        phone: employee.phoneNumber,
                        salary: employee.salary.toStringAsFixed(0),
                        workShift: '09:00 - 17:00',
                        onTap: () {
                          NavigatorHandler.push(
                            EmployeeDetails(
                              employeeId: employee.id,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AppFloatingActionButton(
        onPressed: () {
          NavigatorHandler.push(
            const AddEmployee(),
          );
        },
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,
    );
  }
}