import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/presentation/components/custom_checkbox/custom_checkbox.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class SelectableEmployeeTile extends StatelessWidget {
  final EmployeeEntity employee;
  final String departmentName;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableEmployeeTile({
    super.key,
    required this.employee,
    this.departmentName = '',
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.person, size: 20.w, color: AppColors.primary),
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    title: employee.fullName,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontColor: AppColors.black,
                  ),
                  SizedBox(height: 2.h),
                  CustomText(
                    title: departmentName,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    fontColor: AppColors.gray,
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            CustomCheckbox(value: isSelected, onChanged: (_) => onTap()),
          ],
        ),
      ),
    );
  }
}
