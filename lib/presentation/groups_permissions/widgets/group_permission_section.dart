import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/group_permission_entity.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/domain/group/entity/permission_scope.dart';
import 'package:hr_management_system/presentation/groups_permissions/widgets/permission_row.dart';
import 'package:hr_management_system/presentation/groups_permissions/widgets/permission_scope_selector.dart';

class GroupPermissionSection extends StatelessWidget {
  final GroupModule module;
  final GroupPermissionEntity permission;
  final ValueChanged<PermissionAction> onActionToggled;
  final ValueChanged<PermissionScope> onScopeChanged;

  const GroupPermissionSection({
    super.key,
    required this.module,
    required this.permission,
    required this.onActionToggled,
    required this.onScopeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            title: module.label,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            fontColor: AppColors.black,
          ),

          SizedBox(height: 12.h),

          Divider(height: 1, thickness: 1, color: const Color(0xFFE2E8F0)),

          SizedBox(height: 8.h),

          ...PermissionAction.values.map((action) {
            return PermissionRow(
              label: action.label,
              isGranted: permission.isGranted(action),
              onChanged: (_) => onActionToggled(action),
            );
          }),

          if (module.supportsScope) ...[
            SizedBox(height: 6.h),
            PermissionScopeSelector(
              selectedScope: permission.scope ?? PermissionScope.own,
              onChanged: onScopeChanged,
            ),
          ],
        ],
      ),
    );
  }
}
