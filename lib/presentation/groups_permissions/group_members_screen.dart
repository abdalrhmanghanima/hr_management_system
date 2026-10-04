import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/responsive/responsive_widgets.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/authorization/widgets/permission_guard.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_snack_bar/custom_snack_bar.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/groups_permissions/provider/group_provider.dart';
import 'package:hr_management_system/presentation/groups_permissions/widgets/selectable_employee_tile.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_search_field.dart';

class GroupMembersScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;
  final List<String> memberIds;

  const GroupMembersScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.memberIds,
  });

  @override
  ConsumerState<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends ConsumerState<GroupMembersScreen> {
  final TextEditingController searchController = TextEditingController();

  late final Set<String> selectedEmployeeIds;

  String searchQuery = '';

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    selectedEmployeeIds = widget.memberIds.toSet();
  }

  @override
  void dispose() {
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

  Future<void> _saveMembers() async {
    final granted = ref
        .read(permissionCheckerProvider)
        .authorization
        .isGranted(GroupModules.groups, PermissionAction.edit);

    if (!granted) {
      CustomSnackBar.show(context, message: 'group.edit_denied'.tr());
      return;
    }

    setState(() {
      isSaving = true;
    });

    final group = await ref
        .read(getGroupByIdUseCaseProvider)
        .call(widget.groupId);

    if (group == null) {
      if (!mounted) return;
      setState(() {
        isSaving = false;
      });
      CustomSnackBar.show(context, message: 'group.unavailable'.tr());
      return;
    }

    final result = await ref
        .read(groupProvider.notifier)
        .updateGroup(group.copyWith(employeeIds: selectedEmployeeIds.toList()));

    if (!mounted) {
      return;
    }

    setState(() {
      isSaving = false;
    });

    if (result == SaveResult.failure) {
      CustomSnackBar.show(context, message: 'group.members_save_failed'.tr());
      return;
    }

    if (result == SaveResult.duplicate) {
      CustomSnackBar.show(context, message: 'group.duplicate'.tr());
      return;
    }

    CustomSnackBar.show(
      context,
      message: 'group.members_saved'.tr(
        namedArgs: {
          'count': selectedEmployeeIds.length.toString(),
          'group': widget.groupName,
        },
      ),
      success: true,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final employeeState = ref.watch(employeeProvider);
    final departmentState = ref.watch(departmentProvider).value ?? [];

    final departmentNames = {
      for (final department in departmentState) department.id: department.name,
    };

    return PermissionGuard(
      module: GroupModules.groups,
      action: PermissionAction.edit,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(title: 'group.members'.tr()),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title: widget.groupName,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.black,
                    ),
                    SizedBox(height: 3.h),
                    CustomText(
                      title: 'group.members_count'.tr(
                        namedArgs: {
                          'count': selectedEmployeeIds.length.toString(),
                        },
                      ),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      fontColor: AppColors.gray,
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
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.r),
                  child: employeeState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Center(
                      child: CustomText(
                        title: error.toString(),
                        fontColor: AppColors.red,
                      ),
                    ),
                    data: (employees) {
                      final filteredEmployees = employees
                          .where(
                            (employee) => employee.fullName
                                .toLowerCase()
                                .contains(searchQuery.trim().toLowerCase()),
                          )
                          .toList();

                      if (filteredEmployees.isEmpty) {
                        return Center(
                          child: CustomText(
                            title: employees.isEmpty
                                ? 'group.empty'.tr()
                                : 'group.empty_search'.tr(),
                            fontSize: 14.sp,
                            fontColor: AppColors.gray,
                          ),
                        );
                      }

                      return AdaptiveCardList(
                        spacing: 0,
                        columnSpacing: 12.h,
                        children: filteredEmployees
                            .map(
                              (employee) => SelectableEmployeeTile(
                                employee: employee,
                                departmentName:
                                    departmentNames[employee.departmentId] ??
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
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(16.r, 8.h, 16.r, 16.h),
                child: CustomButton(
                  title: 'group.save_members'.tr(),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  onTap: isSaving ? null : _saveMembers,
                  isLoading: isSaving,
                  bg: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
