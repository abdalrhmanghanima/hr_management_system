import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_snack_bar/custom_snack_bar.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/components/inputs/custom_text_form.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/authorization/widgets/permission_guard.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/groups_permissions/provider/group_provider.dart';
import 'package:hr_management_system/presentation/groups_permissions/widgets/selectable_employee_tile.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_search_field.dart';
import 'package:uuid/uuid.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  final GroupEntity? group;

  const CreateGroupScreen({super.key, this.group});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  late final Set<String> selectedEmployeeIds;

  String searchQuery = '';

  bool isSaving = false;

  bool get isEditing => widget.group != null;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.group?.name ?? '';
    selectedEmployeeIds = {...?widget.group?.employeeIds};
  }

  @override
  void dispose() {
    nameController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _toggleEmployee(String employeeId) {
    setState(() {
      if (!selectedEmployeeIds.add(employeeId)) {
        selectedEmployeeIds.remove(employeeId);
      }
    });
  }

  Future<void> _saveGroup() async {
    final action = isEditing ? PermissionAction.edit : PermissionAction.add;

    final granted = ref
        .read(permissionCheckerProvider)
        .authorization
        .isGranted(GroupModules.groups, action);

    if (!granted) {
      CustomSnackBar.show(
        context,
        message: 'group.action_denied'.tr(namedArgs: {'action': action.label.toLowerCase()}),
      );
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    final name = nameController.text.trim();

    setState(() {
      isSaving = true;
    });

    final group = GroupEntity(
      id: widget.group?.id ?? const Uuid().v4(),
      name: name,
      description: widget.group?.description ?? '',
      employeeIds: selectedEmployeeIds.toList(),
      permissions: widget.group?.permissions ?? const {},
    );

    final notifier = ref.read(groupProvider.notifier);

    final result = isEditing
        ? await notifier.updateGroup(group)
        : await notifier.addGroup(group);

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
          message: isEditing
              ? 'group.updated'.tr(namedArgs: {'name': name})
              : 'group.created'.tr(namedArgs: {'name': name}),
          success: true,
        );
        Navigator.pop(context, true);
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
          message: 'group.save_failed'.tr(),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeState = ref.watch(employeeProvider);
    final departmentState = ref.watch(departmentProvider).value ?? [];

    final departmentNames = {
      for (final department in departmentState) department.id: department.name,
    };

    final action = isEditing ? PermissionAction.edit : PermissionAction.add;

    return PermissionGuard(
      module: GroupModules.groups,
      action: action,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(title: isEditing ? 'group.edit_title'.tr() : 'group.create_title'.tr()),

        body: SafeArea(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextFormField(
                          controller: nameController,
                          label: 'group.name_label'.tr(),
                          isRequired: true,
                          hint: 'group.name_hint'.tr(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'group.name_required'.tr();
                            }

                            if (value.trim().length < 3) {
                              return 'group.name_min_length'.tr();
                            }

                            return null;
                          },
                        ),

                        SizedBox(height: 24.h),

Row(
                            children: [
                              CustomText(
                                title: 'group.members'.tr(),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                fontColor: AppColors.black,
                              ),
                              SizedBox(width: 8.w),
                              CustomText(
                                title: 'group.selected_count'.tr(namedArgs: {'count': selectedEmployeeIds.length.toString()}),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                fontColor: AppColors.primary,
                              ),
                            ],
                          ),

                        SizedBox(height: 12.h),

                        AppSearchField(
                          hintText: 'group.search_employees'.tr(),
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                        ),

                        SizedBox(height: 12.h),

                        employeeState.when(
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (error, stackTrace) => Center(
                            child: CustomText(
                              title: error.toString(),
                              fontColor: AppColors.red,
                            ),
                          ),
                          data: (employees) {
                            final filteredEmployees = employees
                                .where(
                                  (employee) =>
                                      employee.fullName.toLowerCase().contains(
                                        searchQuery.trim().toLowerCase(),
                                      ),
                                )
                                .toList();

                            if (filteredEmployees.isEmpty) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.h),
                                child: Center(
                                  child: CustomText(
                                    title: employees.isEmpty
                                        ? 'group.empty'.tr()
                                        : 'group.empty_search'.tr(),
                                    fontSize: 14.sp,
                                    fontColor: AppColors.gray,
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: filteredEmployees
                                  .map(
                                    (employee) => SelectableEmployeeTile(
                                      employee: employee,
                                      departmentName:
                                          departmentNames[employee
                                              .departmentId] ??
                                          '',
                                      isSelected: selectedEmployeeIds.contains(
                                        employee.id,
                                      ),
                                      onTap: () => _toggleEmployee(employee.id),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.r, 8.h, 16.r, 16.h),
                  child: CustomButton(
                    title: isEditing ? 'group.update_button'.tr() : 'group.save_button'.tr(),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    onTap: isSaving ? null : _saveGroup,
                    isLoading: isSaving,
                    bg: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
