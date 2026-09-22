import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/employee/widgets/employee_card.dart';

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
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Search by name, phone, national ID...',
                hintStyle: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: 16.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color(0xFF64748B),
                  size: 25.w,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28.r),
                  borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28.r),
                  borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
