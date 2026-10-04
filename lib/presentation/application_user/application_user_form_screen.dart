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
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/application_user/provider/application_user_provider.dart';
import 'package:hr_management_system/presentation/authorization/widgets/permission_guard.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_checkbox/custom_checkbox.dart';
import 'package:hr_management_system/presentation/components/custom_snack_bar/custom_snack_bar.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/components/inputs/custom_dropdown_field.dart';
import 'package:hr_management_system/presentation/components/inputs/custom_text_form.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/groups_permissions/provider/group_provider.dart';

class ApplicationUserFormScreen extends ConsumerStatefulWidget {
  final ApplicationUserEntity applicationUser;

  const ApplicationUserFormScreen({super.key, required this.applicationUser});

  @override
  ConsumerState<ApplicationUserFormScreen> createState() =>
      _ApplicationUserFormScreenState();
}

class _ApplicationUserFormScreenState
    extends ConsumerState<ApplicationUserFormScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController readonlyEmployeeController =
      TextEditingController();

  final formKey = GlobalKey<FormState>();

  late String groupId;
  late bool isActive;

  @override
  void initState() {
    super.initState();

    final applicationUser = widget.applicationUser;

    groupId = applicationUser.groupId ?? '';
    isActive = applicationUser.isActive;

    emailController.text = applicationUser.email;
  }

  @override
  void dispose() {
    emailController.dispose();
    readonlyEmployeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationUsersState = ref.watch(applicationUserOperationProvider);
    final allEmployees = ref.watch(employeeProvider).valueOrNull ?? const [];
    final groups = ref.watch(groupProvider).valueOrNull ?? const [];

    return PermissionGuard(
      module: GroupModules.applicationUsers,
      action: PermissionAction.edit,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(title: 'application_user.edit_title'.tr()),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Form(
            key: formKey,
            child: MaxWidthBox(
              maxWidth: AppBreakpoints.formMaxWidth,
              applyFromWidth: AppBreakpoints.desktopMinWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextFormField(
                    controller: emailController,
                    label: 'application_user.email_label'.tr(),
                    readOnly: true,
                    hint: 'application_user.email_locked'.tr(),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'application_user.email_required'.tr();
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  CustomTextFormField(
                    controller: readonlyEmployeeController
                      ..text = _findEmployeeName(allEmployees),
                    label: 'application_user.employee_label'.tr(),
                    readOnly: true,
                    hint: 'application_user.employee_locked'.tr(),
                  ),

                  SizedBox(height: 16.h),

                  CustomDropdownField<String>(
                    label: 'application_user.group_label'.tr(),
                    isRequired: true,
                    hint: 'application_user.select_group_hint'.tr(),
                    value: groupId.isEmpty ? null : groupId,
                    items: groups
                        .map(
                          (group) => DropdownMenuItem<String>(
                            value: group.id,
                            child: Text(
                              group.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => groupId = value ?? '');
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'application_user.group_required'.tr();
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  _ActiveToggle(
                    value: isActive,
                    onChanged: (value) => setState(() => isActive = value),
                  ),

                  SizedBox(height: 24.h),

                  CustomButton(
                    title: 'application_user.save_changes'.tr(),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    isLoading: applicationUsersState.isLoading,
                    onTap: _save,
                    bg: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _findEmployeeName(List<EmployeeEntity> employees) {
    for (final employee in employees) {
      if (employee.id == widget.applicationUser.employeeId) {
        return employee.fullName;
      }
    }
    return '';
  }

  Future<void> _save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final result = await ref
        .read(applicationUserOperationProvider.notifier)
        .updateApplicationUser(
          widget.applicationUser.copyWith(
            email: emailController.text.trim(),
            groupId: groupId,
            clearGroup: groupId.isEmpty,
            isActive: isActive,
          ),
        );

    if (!mounted) {
      return;
    }

    if (result == SaveResult.success) {
      CustomSnackBar.show(
        context,
        message: 'application_user.update_success'.tr(),
        success: true,
      );
      NavigatorHandler.pop();
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

class _ActiveToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ActiveToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CustomCheckbox(value: value, onChanged: onChanged),

          SizedBox(width: 10.w),

          Expanded(
            child: CustomText(
              title: 'application_user.account_active'.tr(),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
