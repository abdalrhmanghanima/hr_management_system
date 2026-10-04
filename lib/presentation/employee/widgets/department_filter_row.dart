import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class DepartmentFilterRow extends StatelessWidget {
  final List<DepartmentEntity> departments;
  final String? selectedDepartmentId;
  final ValueChanged<String?> onDepartmentSelected;

  const DepartmentFilterRow({
    super.key,
    required this.departments,
    required this.selectedDepartmentId,
    required this.onDepartmentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _DepartmentChip(
            chipKey: 'department-filter-chip-all',
            label: 'common.all'.tr(),
            selected: selectedDepartmentId == null,
            onTap: () => onDepartmentSelected(null),
          ),
          for (final department in departments) ...[
            SizedBox(width: 8.w),
            _DepartmentChip(
              chipKey: 'department-filter-chip-${department.id}',
              label: department.name,
              selected: selectedDepartmentId == department.id,
              onTap: () => onDepartmentSelected(department.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _DepartmentChip extends StatelessWidget {
  final String chipKey;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DepartmentChip({
    required this.chipKey,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey(chipKey),
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: CustomText(
          title: label,
          fontSize: 12.sp,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontColor: selected ? AppColors.white : AppColors.gray,
        ),
      ),
    );
  }
}
