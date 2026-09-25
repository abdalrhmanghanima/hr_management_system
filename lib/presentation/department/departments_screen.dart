import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/department/widgets/add_department_bottom_sheet.dart';
import 'package:hr_management_system/presentation/department/widgets/department_card.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_floating_action_button.dart';

final departmentSearchProvider =
StateProvider.autoDispose<String>((ref) => '');

class DepartmentsScreen extends ConsumerWidget {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentState = ref.watch(departmentProvider);
    final searchQuery = ref.watch(departmentSearchProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const CustomAppBar(
        title: 'Departments',
      ),
      floatingActionButton: AppFloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24.r),
              ),
            ),
            builder: (_) => const AddDepartmentBottomSheet(),
          );
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: departmentState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: CustomText(
              title: 'Failed to load departments',
              fontColor: AppColors.red,
            ),
          ),
          data: (departments) {
            final filteredDepartments = departments
                .where(
                  (department) => department.name
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()),
            )
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (value) {
                    ref.read(departmentSearchProvider.notifier).state =
                        value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search departments...',
                    prefixIcon: Icon(
                      Icons.search,
                      size: 24.w,
                      color: AppColors.gray,
                    ),
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
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                Row(
                  children: [
                    CustomText(
                      title: '${filteredDepartments.length} Departments',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.black,
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                Expanded(
                  child: filteredDepartments.isEmpty
                      ? Center(
                    child: CustomText(
                      title: searchQuery.isEmpty
                          ? 'No departments found'
                          : 'No departments match your search',
                      fontSize: 15.sp,
                      fontColor: AppColors.gray,
                    ),
                  )
                      : ListView.separated(
                    itemCount: filteredDepartments.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final department = filteredDepartments[index];

                      return DepartmentCard(
                        department: department,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}