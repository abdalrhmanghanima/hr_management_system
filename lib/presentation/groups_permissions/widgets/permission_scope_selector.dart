import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/domain/group/entity/permission_scope.dart';

class PermissionScopeSelector extends StatelessWidget {
  final PermissionScope selectedScope;
  final ValueChanged<PermissionScope> onChanged;

  const PermissionScopeSelector({
    super.key,
    required this.selectedScope,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h, top: 2.h),
      child: Row(
        children: [
          SizedBox(
            width: 56.w,
            child: CustomText(
              title: 'Scope',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: PermissionScope.values.map((scope) {
                  final isSelected = scope == selectedScope;

                  return Expanded(
                    child: InkWell(
                      onTap: () => onChanged(scope),
                      borderRadius: BorderRadius.circular(9.r),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 7.h),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : null,
                          borderRadius: BorderRadius.circular(9.r),
                        ),
                        child: CustomText(
                          title: scope.label,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          fontColor: isSelected
                              ? AppColors.white
                              : AppColors.gray,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
