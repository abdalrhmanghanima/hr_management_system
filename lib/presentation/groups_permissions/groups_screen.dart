import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/authorization/widgets/permission_guard.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/groups_permissions/create_group_screen.dart';
import 'package:hr_management_system/presentation/groups_permissions/group_details_screen.dart';
import 'package:hr_management_system/presentation/groups_permissions/provider/group_provider.dart';
import 'package:hr_management_system/presentation/groups_permissions/widgets/group_card.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_floating_action_button.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(groupProvider);
    final canAddGroups = ref.watch(
      modulePermissionProvider((
        module: GroupModules.groups,
        action: PermissionAction.add,
      )),
    );

    return PermissionGuard(
      module: GroupModules.groups,
      action: PermissionAction.view,
      popOnDenied: true,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(title: 'group.title'.tr()),
        floatingActionButton: canAddGroups
            ? AppFloatingActionButton(
                onPressed: () =>
                    NavigatorHandler.push(const CreateGroupScreen()),
              )
            : null,
        body: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                title: 'group.count'.tr(namedArgs: {'count': (groupState.value?.length ?? 0).toString()}),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                fontColor: AppColors.black,
              ),

              SizedBox(height: 12.h),

              Expanded(
                child: groupState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: CustomText(
                      title: error.toString(),
                      fontColor: AppColors.red,
                    ),
                  ),
data: (groups) {
                      if (groups.isEmpty) {
                        return Center(
                          child: CustomText(
                            title: 'group.empty'.tr(),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            fontColor: AppColors.gray,
                          ),
                        );
                      }

                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.read(groupProvider.notifier).getGroups(),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: groups.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final group = groups[index];

                          return GroupCard(
                            group: group,
                            onTap: () => NavigatorHandler.push(
                              GroupDetailsScreen(groupId: group.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
