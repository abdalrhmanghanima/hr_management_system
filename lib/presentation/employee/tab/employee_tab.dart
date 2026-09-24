import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/employee/add_employee.dart';
import 'package:hr_management_system/presentation/employee/employee_details.dart';
import 'package:hr_management_system/presentation/employee/widgets/employee_card.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_floating_action_button.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_search_field.dart';

class EmployeesTab extends StatelessWidget {
  const EmployeesTab({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: 5,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  return EmployeeCard(
                    name: 'Ahmed Mohamed',
                    group: 'Engineering',
                    phone: '01012345678',
                    salary: '14,500 EGP',
                    workShift: '09:00 - 17:00',
                    onTap: () => NavigatorHandler.push(EmployeeDetails()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AppFloatingActionButton(
        onPressed: () {
          NavigatorHandler.push(AddEmployee());
      },),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
