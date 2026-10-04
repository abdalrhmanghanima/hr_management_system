import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/responsive/breakpoints.dart';
import 'package:hr_management_system/core/responsive/responsive_widgets.dart';
import 'package:hr_management_system/domain/application_user/entity/application_user_entity.dart';
import 'package:hr_management_system/domain/application_user/entity/application_user_exception.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/application_user/application_user_form_screen.dart';
import 'package:hr_management_system/presentation/application_user/provider/application_user_provider.dart';
import 'package:hr_management_system/presentation/application_user/widgets/application_user_card.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/authorization/widgets/permission_guard.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_snack_bar/custom_snack_bar.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/groups_permissions/provider/group_provider.dart';

class ApplicationUsersScreen extends ConsumerWidget {
  const ApplicationUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationUsersState = ref.watch(applicationUserProvider);
    final searchQuery = ref.watch(applicationUserSearchProvider);

    final canEdit = ref.watch(
      modulePermissionProvider((
        module: GroupModules.applicationUsers,
        action: PermissionAction.edit,
      )),
    );

    return PermissionGuard(
      module: GroupModules.applicationUsers,
      action: PermissionAction.view,
      popOnDenied: true,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(title: 'application_user.title'.tr()),
        body: Padding(
          padding: EdgeInsets.all(16.r),
          child: applicationUsersState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
error: (error, stackTrace) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    title: 'application_user.load_failed'.tr(),
                    fontColor: AppColors.red,
                  ),

                  SizedBox(height: 12.h),

                  CustomButton(
                    title: 'common.retry'.tr(),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    onTap: () {
                      ref
                          .read(applicationUserProvider.notifier)
                          .getApplicationUsers();
                    },
                    bg: AppColors.primary,
                  ),
                ],
              ),
            ),
            data: (applicationUsers) {
              return ApplicationUsersList(
                applicationUsers: applicationUsers,
                searchQuery: searchQuery,
                canEdit: canEdit,
                canChangeStatus: canEdit,
              );
            },
          ),
        ),
      ),
    );
  }
}

class ApplicationUsersList extends ConsumerWidget {
  final List<ApplicationUserEntity> applicationUsers;
  final String searchQuery;
  final bool canEdit;
  final bool canChangeStatus;

  const ApplicationUsersList({
    super.key,
    required this.applicationUsers,
    required this.searchQuery,
    this.canEdit = false,
    this.canChangeStatus = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(employeeProvider).valueOrNull ?? const [];
    final groups = ref.watch(groupProvider).valueOrNull ?? const [];

    final filtered = applicationUsers
        .where(
          (applicationUser) => _matches(
            applicationUser,
            _employeeName(employees, applicationUser.employeeId),
          ),
        )
        .toList()
      ..sort((a, b) => a.email.toLowerCase().compareTo(b.email.toLowerCase()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MaxWidthBox(
          maxWidth: AppBreakpoints.searchMaxWidth,
          center: false,
          applyFromWidth: AppBreakpoints.desktopMinWidth,
          child: TextField(
            onChanged: (value) {
              ref.read(applicationUserSearchProvider.notifier).state = value;
            },
            decoration: InputDecoration(
              hintText: 'application_user.search_hint'.tr(),
              prefixIcon:
                  Icon(Icons.search, size: 24.w, color: AppColors.gray),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: AppColors.primary, width: 1),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
          ),
        ),

        SizedBox(height: 20.h),

CustomText(
          title: 'application_user.count'.tr(
            namedArgs: {'count': filtered.length.toString()},
          ),
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          fontColor: AppColors.black,
        ),

        SizedBox(height: 12.h),

Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: CustomText(
                    title: searchQuery.isEmpty
                        ? 'application_user.empty'.tr()
                        : 'application_user.empty_search'.tr(),
                    fontSize: 15.sp,
                    fontColor: AppColors.gray,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(applicationUserProvider.notifier)
                        .getApplicationUsers();
                  },
                  child: AdaptiveCardList(
                    spacing: 12.h,
                    children: [
                      for (final applicationUser in filtered)
                        ApplicationUserCard(
                          applicationUser: applicationUser,
                          employeeName: _employeeName(
                            employees,
                            applicationUser.employeeId,
                          ),
                          groupName:
                              _groupName(groups, applicationUser.groupId),
                          canEdit: canEdit,
                          canChangeStatus: canChangeStatus,
                          onTap: () {
                            NavigatorHandler.push(
                              ApplicationUserFormScreen(
                                applicationUser: applicationUser,
                              ),
                            );
                          },
                          onStatusChanged: (isActive) {
                            _changeStatus(
                              context,
                              ref,
                              applicationUser,
                              isActive,
                            );
                          },
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  bool _matches(ApplicationUserEntity applicationUser, String employeeName) {
    if (searchQuery.isEmpty) {
      return true;
    }

    final query = searchQuery.toLowerCase();

    return applicationUser.email.toLowerCase().contains(query) ||
        employeeName.toLowerCase().contains(query) ||
        applicationUser.employeeId.toLowerCase().contains(query);
  }

  String _employeeName(List<EmployeeEntity> employees, String employeeId) {
    for (final employee in employees) {
      if (employee.id == employeeId) {
        return employee.fullName;
      }
    }
    return '';
  }

  String _groupName(List<GroupEntity> groups, String? groupId) {
    if (groupId == null || groupId.isEmpty) {
      return '';
    }

    for (final group in groups) {
      if (group.id == groupId) {
        return group.name;
      }
    }
    return '';
  }

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    ApplicationUserEntity applicationUser,
    bool isActive,
  ) async {
    final result = await ref
        .read(applicationUserOperationProvider.notifier)
        .setApplicationUserActive(applicationUser, isActive);

    if (!context.mounted || result == SaveResult.success) {
      return;
    }

    CustomSnackBar.show(
      context,
      message: ApplicationUserException.messageKeyOf(
          ref.read(applicationUserOperationProvider).error ?? '',
        ).tr(),
    );
  }
}

