import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/core/utils/delete_confirmation_dialog.dart';
import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/group_permission_entity.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/domain/group/entity/permission_scope.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_snack_bar/custom_snack_bar.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/groups_permissions/create_group_screen.dart';
import 'package:hr_management_system/presentation/groups_permissions/group_members_screen.dart';
import 'package:hr_management_system/presentation/groups_permissions/provider/group_provider.dart';
import 'package:hr_management_system/presentation/groups_permissions/widgets/group_permission_section.dart';

class GroupDetailsScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends ConsumerState<GroupDetailsScreen> {
  Map<String, GroupPermissionEntity> permissions = {};

  String? initializedGroupId;

  bool isSaving = false;

  void _syncLocalPermissions(GroupEntity group) {
    if (initializedGroupId == group.id) return;
    initializedGroupId = group.id;
    permissions = {
      for (final module in GroupModules.all)
        module.key: group.permissionFor(module.key),
    };
  }

  void _toggleAction(String moduleKey, PermissionAction action) {
    setState(() {
      permissions = {
        ...permissions,
        moduleKey: (permissions[moduleKey] ?? const GroupPermissionEntity())
            .toggleAction(action),
      };
    });
  }

  void _changeScope(String moduleKey, PermissionScope scope) {
    setState(() {
      permissions = {
        ...permissions,
        moduleKey: (permissions[moduleKey] ?? const GroupPermissionEntity())
            .withScope(scope),
      };
    });
  }

  bool _isAllowed(PermissionAction action) {
    final granted = ref
        .read(permissionCheckerProvider)
        .authorization
        .isGranted(GroupModules.groups, action);

    if (!granted) {
      CustomSnackBar.show(
        context,
        message: 'group.action_denied'.tr(namedArgs: {'action': action.label.toLowerCase()}),
      );
    }

    return granted;
  }

  Future<void> _savePermissions(GroupEntity group) async {
    if (!_isAllowed(PermissionAction.edit)) return;

    final hasAnyPermission = permissions.values.any(
      (permission) => permission.hasAnyGrant,
    );

    if (!hasAnyPermission) {
      CustomSnackBar.show(
        context,
        message: 'group.permissions_required'.tr(),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final result = await ref
        .read(groupProvider.notifier)
        .updateGroup(group.copyWith(permissions: permissions));

    if (!mounted) {
      return;
    }

    setState(() {
      isSaving = false;
    });

    switch (result) {
      case SaveResult.success:
        CustomSnackBar.show(
          context,
          message: 'group.permissions_updated'.tr(),
          success: true,
        );
        break;
      case SaveResult.duplicate:
        CustomSnackBar.show(
          context,
          message: 'group.duplicate'.tr(),
        );
        break;
      case SaveResult.failure:
        CustomSnackBar.show(
          context,
          message: 'group.permissions_save_failed'.tr(),
        );
        break;
    }
  }

  Future<void> _openEdit(GroupEntity group) async {
    await NavigatorHandler.push(CreateGroupScreen(group: group));

    ref.invalidate(groupByIdProvider(group.id));
  }

  void _showDeleteDialog(GroupEntity group) {
    if (!_isAllowed(PermissionAction.delete)) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final isLoading = ref.watch(groupProvider).isLoading;

            return DeleteConfirmationDialog(
              title: 'group.delete_title'.tr(),
              message:
                  'group.delete_confirmation'.tr(namedArgs: {'name': group.name}),
              isLoading: isLoading,
              onDelete: () async {
                final success = await ref
                    .read(groupProvider.notifier)
                    .deleteGroup(group.id);

                if (success && dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupByIdProvider(widget.groupId));

    final canEditGroups = ref.watch(
      modulePermissionProvider((
        module: GroupModules.groups,
        action: PermissionAction.edit,
      )),
    );
    final canDeleteGroups = ref.watch(
      modulePermissionProvider((
        module: GroupModules.groups,
        action: PermissionAction.delete,
      )),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: 'group.details_title'.tr(),
        actions: [
          if (groupState.value != null) ...[
            if (canDeleteGroups)
              IconButton(
                onPressed: () => _showDeleteDialog(groupState.value!),
                icon: CustomSvgIcon(
                  assetName: AppIcons.delete,
                  width: 20.w,
                  height: 20.w,
                ),
              ),
            if (canEditGroups)
              IconButton(
                onPressed: () => _openEdit(groupState.value!),
                icon: CustomSvgIcon(
                  assetName: AppIcons.edit,
                  width: 20.w,
                  height: 20.w,
                ),
              ),
            SizedBox(width: 8.w),
          ],
        ],
      ),
      body: groupState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: CustomText(title: error.toString(), fontColor: AppColors.red),
        ),
        data: (group) {
          if (group == null) {
            return Center(
              child: CustomText(
                title: 'group.unavailable'.tr(),
                fontSize: 14.sp,
                fontColor: AppColors.gray,
              ),
            );
          }

          _syncLocalPermissions(group);

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          title: group.name,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          fontColor: AppColors.black,
                        ),
                        SizedBox(height: 3.h),
                        CustomText(
                          title: group.description,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          fontColor: AppColors.gray,
                        ),

                        SizedBox(height: 24.h),

                        CustomText(
                          title: 'group.members'.tr(),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          fontColor: AppColors.black,
                        ),

                        SizedBox(height: 12.h),

                        InkWell(
                          onTap: canEditGroups
                              ? () => NavigatorHandler.push(
                                  GroupMembersScreen(
                                    groupId: group.id,
                                    groupName: group.name,
                                    memberIds: group.employeeIds,
                                  ),
                                )
                              : null,
                          borderRadius: BorderRadius.circular(20.r),
                          child: Container(
                            width: Dimens.width,
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
                                  width: 48.w,
                                  height: 48.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  child: Center(
                                    child: CustomSvgIcon(
                                      assetName: AppIcons.applicationUser,
                                      width: 24.w,
                                      height: 24.w,
                                    ),
                                  ),
                                ),

                                SizedBox(width: 14.w),

                                Expanded(
                                  child: CustomText(
                                    title: 'group.members_count'.tr(
                                      namedArgs: {'count': group.membersCount.toString()},
                                    ),
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    fontColor: AppColors.black,
                                  ),
                                ),

                                CustomSvgIcon(
                                  assetName: AppIcons.rightArrow,
                                  width: 18.w,
                                  height: 18.w,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 24.h),

                        CustomText(
                          title: 'group.permissions'.tr(),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          fontColor: AppColors.black,
                        ),

                        SizedBox(height: 12.h),

                        ...GroupModules.all.map((module) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: GroupPermissionSection(
                              module: module,
                              permission:
                                  permissions[module.key] ??
                                  const GroupPermissionEntity(),
                              onActionToggled: (action) =>
                                  _toggleAction(module.key, action),
                              onScopeChanged: (scope) =>
                                  _changeScope(module.key, scope),
                            ),
                          );
                        }),

                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                ),
              ),

              if (canEditGroups)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.r, 8.h, 16.r, 16.h),
                  child: CustomButton(
                    title: 'group.save_permissions'.tr(),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    onTap: isSaving ? null : () => _savePermissions(group),
                    isLoading: isSaving,
                    bg: AppColors.primary,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
