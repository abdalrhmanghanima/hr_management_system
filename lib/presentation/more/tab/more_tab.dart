import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/core/utils/delete_confirmation_dialog.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/auth/providers/auth_state_provider.dart';
import 'package:hr_management_system/presentation/auth/providers/logout_provider.dart';
import 'package:hr_management_system/presentation/auth/screens/login_screen.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/application_user/application_users_screen.dart';
import 'package:hr_management_system/presentation/components/custom_snack_bar/custom_snack_bar.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/department/departments_screen.dart';
import 'package:hr_management_system/presentation/employee/employee_details.dart';
import 'package:hr_management_system/presentation/groups_permissions/groups_screen.dart';
import 'package:hr_management_system/presentation/more/general_settings_screen.dart';
import 'package:hr_management_system/presentation/more/widgets/language_selector_sheet.dart';
import 'package:hr_management_system/presentation/more/widgets/more_option_row.dart';
import 'package:hr_management_system/presentation/official_holiday/official_holidays_screen.dart';
import 'package:hr_management_system/presentation/shared_widgets/user_avatar.dart';

class MoreTab extends ConsumerWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    final canViewApplicationUsers = ref.watch(
      modulePermissionProvider((
        module: GroupModules.applicationUsers,
        action: PermissionAction.view,
      )),
    );
    final canViewDepartments = ref.watch(
      modulePermissionProvider((
        module: GroupModules.departments,
        action: PermissionAction.view,
      )),
    );
    final canViewGroups = ref.watch(
      modulePermissionProvider((
        module: GroupModules.groups,
        action: PermissionAction.view,
      )),
    );
    final canViewHolidays = ref.watch(
      modulePermissionProvider((
        module: GroupModules.officialHolidays,
        action: PermissionAction.view,
      )),
    );
    final canViewProfile = ref.watch(
      modulePermissionProvider((
        module: GroupModules.profile,
        action: PermissionAction.view,
      )),
    );
    final currentEmployeeId = ref.watch(currentEmployeeIdProvider);
    final groupName = ref.watch(currentGroupNameProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: CustomText(
          title: 'more.title'.tr(),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const UserAvatar(),

                    SizedBox(width: 16.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            title: 'common.hr_administrator'.tr(),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            fontColor: const Color(0xFF111827),
                          ),

                          SizedBox(height: 4.h),

                          CustomText(
                            title: user?.email ?? "",
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            fontColor: const Color(0xFF64748B),
                          ),

                          SizedBox(height: 8.h),

                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF3FF),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: CustomText(
                              title: groupName.isEmpty
                                  ? 'more.role_hr'.tr()
                                  : 'more.role'.tr(namedArgs: {'name': groupName}),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              fontColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  children: [
                    if (canViewApplicationUsers) ...[
                      MoreOptionRow(
                        iconPath: AppIcons.applicationUser,
                        title: 'more.application_users'.tr(),
                        onTap: () =>
                            NavigatorHandler.push(const ApplicationUsersScreen()),
                      ),
                      Divider(height: 1, color: AppColors.border),
                    ],
                    if (canViewDepartments) ...[
                      MoreOptionRow(
                        iconPath: AppIcons.department,
                        title: 'more.departments'.tr(),
                        onTap: () =>
                            NavigatorHandler.push(DepartmentsScreen()),
                      ),
                      Divider(height: 1, color: AppColors.border),
                    ],
                    if (canViewGroups) ...[
                      MoreOptionRow(
                        iconPath: AppIcons.permission,
                        title: 'more.groups_permissions'.tr(),
                        onTap: () => NavigatorHandler.push(const GroupsScreen()),
                      ),
                      Divider(height: 1, color: AppColors.border),
                    ],
                    if (canViewHolidays) ...[
                      MoreOptionRow(
                        iconPath: AppIcons.greenCalender,
                        title: 'more.official_holidays'.tr(),
                        onTap: () => NavigatorHandler.push(
                          const OfficialHolidaysScreen(),
                        ),
                      ),
                      Divider(height: 1, color: AppColors.border),
                    ],
                    if (canViewProfile && currentEmployeeId != null) ...[
                      MoreOptionRow(
                        iconPath: AppIcons.applicationUser,
                        title: 'more.my_profile'.tr(),
                        onTap: () => NavigatorHandler.push(
                          EmployeeDetails(employeeId: currentEmployeeId),
                        ),
                      ),
                      Divider(height: 1, color: AppColors.border),
                    ],
                    MoreOptionRow(
                      iconPath: AppIcons.settings,
                      title: 'more.general_settings'.tr(),
                      onTap: () => NavigatorHandler.push(GeneralSettingsScreen()),
                    ),
                    Divider(height: 1, color: AppColors.border),
                    MoreOptionRow(
                      iconPath: AppIcons.language,
                      title: 'more.languages'.tr(),
                      onTap: () => LanguageSelectorSheet.show(context),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              InkWell(
                onTap: () => _confirmSignOut(context, ref),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  height: 54.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2F2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFFFFC7C7), width: 1),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.signOut,
                        width: 20.w,
                        height: 20.h,
                        colorFilter: const ColorFilter.mode(
                          AppColors.red,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: CustomText(
                          title: 'more.sign_out_account'.tr(),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          fontColor: AppColors.red,
                        ),
                      ),
                      CustomSvgIcon(
                        assetName: AppIcons.rightArrow,
                        width: 20.w,
                        height: 20.h,
                        colorFilter: const ColorFilter.mode(
                          AppColors.red,
                          BlendMode.srcIn,
                        ),
                        mirrorInRtl: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final pageContext = context;

    await showDialog(
      context: pageContext,
      builder: (dialogContext) {
        return Consumer(
          builder: (dialogScopeContext, dialogRef, child) {
            return DeleteConfirmationDialog(
              title: 'more.sign_out'.tr(),
              message: 'more.sign_out_confirmation'.tr(),
              isLoading: dialogRef.watch(logoutProvider).isLoading,
              onDelete: () => _signOut(pageContext, ref, dialogContext),
            );
          },
        );
      },
    );
  }

  Future<void> _signOut(
    BuildContext pageContext,
    WidgetRef ref,
    BuildContext dialogContext,
  ) async {
    await ref.read(logoutProvider.notifier).logout();

    final logoutState = ref.read(logoutProvider);

    if (!dialogContext.mounted) {
      return;
    }

    Navigator.pop(dialogContext);

    if (logoutState.hasError) {
      CustomSnackBar.show(
        pageContext,
        message: 'more.sign_out_failed'.tr(),
      );

      return;
    }

    NavigatorHandler.pushAndRemoveUntil(LoginScreen());
  }
}
