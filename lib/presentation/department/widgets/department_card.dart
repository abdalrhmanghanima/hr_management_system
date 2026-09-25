import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/department/widgets/edit_department_bottom_sheet.dart';

class DepartmentCard extends ConsumerWidget {
  final DepartmentEntity department;

  const DepartmentCard({
    required this.department,
  });

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: CustomText(
            title: 'Delete Department',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            fontColor: AppColors.black,
          ),
          content: CustomText(
            title:
            'Are you sure you want to delete "${department.name}"?',
            fontSize: 14.sp,
            fontColor: AppColors.gray,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: CustomText(
                title: 'Cancel',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                fontColor: AppColors.gray,
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await ref
                    .read(departmentProvider.notifier)
                    .deleteDepartment(department.id);
              },
              child: CustomText(
                title: 'Delete',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontColor: AppColors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      builder: (_) => EditDepartmentBottomSheet(
        department: department,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: CustomSvgIcon(
                assetName: AppIcons.department,
                width: 28.w,
                height: 28.w,
              ),
            ),
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: CustomText(
              title: department.name,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
          ),

          IconButton(
            onPressed: () {
              _showEditBottomSheet(context);
            },
            icon: CustomSvgIcon(
              assetName: AppIcons.edit,
              width: 20.w,
              height: 20.w,
            ),
          ),

          IconButton(
            onPressed: () {
              _showDeleteDialog(context, ref);
            },
            icon: CustomSvgIcon(
              assetName: AppIcons.delete,
              width: 20.w,
              height: 20.w,
            ),
          ),
        ],
      ),
    );
  }
}