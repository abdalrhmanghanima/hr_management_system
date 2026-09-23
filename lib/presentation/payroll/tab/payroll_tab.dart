import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/payroll/widgets/payroll_card.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_search_field.dart';

class PayrollTab extends StatelessWidget {
  const PayrollTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: CustomText(
          title: 'Payroll & Salary',
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontColor: const Color(0xFF111827),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(height: 1.h, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            AppSearchField(hintText: 'Search payroll by employee name...'),
            SizedBox(height: 16.h),

            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: 5,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  return PayrollCard(
                    employeeName: 'Ahmed Mohamed',
                    department: 'Engineering',
                    month: 'September 2026',
                    netSalary: '15,070',
                    basicSalary: '14,500',
                    attendanceAbsence: '21d / 1d',
                    overtime: '+660',
                    deduction: '-90',
                    onDetails: () {},
                    onSalarySlip: () {},
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
