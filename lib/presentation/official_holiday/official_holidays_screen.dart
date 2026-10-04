import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/navigator/navigator.dart';
import 'package:hr_management_system/core/responsive/responsive_widgets.dart';
import 'package:hr_management_system/core/utils/delete_confirmation_dialog.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/authorization/widgets/permission_guard.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/official_holiday/add_official_holiday_screen.dart';
import 'package:hr_management_system/presentation/official_holiday/edit_official_holiday_screen.dart';
import 'package:hr_management_system/presentation/official_holiday/provider/official_holidays_provider.dart';
import 'package:hr_management_system/presentation/official_holiday/widgets/official_holiday_card.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_floating_action_button.dart';

class OfficialHolidaysScreen extends ConsumerWidget {
  const OfficialHolidaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holidaysState = ref.watch(officialHolidaysProvider);
    final canAddHolidays = ref.watch(
      modulePermissionProvider((
        module: GroupModules.officialHolidays,
        action: PermissionAction.add,
      )),
    );
    final canEditHolidays = ref.watch(
      modulePermissionProvider((
        module: GroupModules.officialHolidays,
        action: PermissionAction.edit,
      )),
    );
    final canDeleteHolidays = ref.watch(
      modulePermissionProvider((
        module: GroupModules.officialHolidays,
        action: PermissionAction.delete,
      )),
    );

    return PermissionGuard(
      module: GroupModules.officialHolidays,
      action: PermissionAction.view,
      popOnDenied: true,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(title: 'holiday.title'.tr()),
        floatingActionButton: canAddHolidays
            ? AppFloatingActionButton(
                onPressed: () {
                  NavigatorHandler.push(const AddOfficialHolidayScreen());
                },
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: Padding(
          padding: EdgeInsets.fromLTRB(20.r, 20.r, 20.r, 100.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                title: 'holiday.subtitle'.tr(),
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                fontColor: AppColors.gray,
              ),

              SizedBox(height: 18.h),

              Expanded(
                child: holidaysState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: CustomText(
                      title: 'holiday.load_failed'.tr(),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      fontColor: AppColors.red,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  data: (holidays) {
                    if (holidays.isEmpty) {
                      return Center(
                        child: CustomText(
                          title: 'holiday.empty'.tr(),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.gray,
                        ),
                      );
                    }

                    return AdaptiveCardList(
                      spacing: 14.h,
                      children: [
                        for (final holiday in holidays)
                          OfficialHolidayCard(
                            holiday: holiday,
                            onEdit: canEditHolidays
                                ? () {
                                    NavigatorHandler.push(
                                      EditOfficialHolidayScreen(
                                        holiday: holiday,
                                      ),
                                    );
                                  }
                                : null,
                            onDelete: canDeleteHolidays
                                ? () {
                                    _showDeleteDialog(
                                      context: context,
                                      holiday: holiday,
                                    );
                                  }
                                : null,
                          ),
                      ],
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

  void _showDeleteDialog({
    required BuildContext context,
    required OfficialHolidayEntity holiday,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final isLoading = ref.watch(officialHolidaysProvider).isLoading;

            return DeleteConfirmationDialog(
              title: 'holiday.delete_title'.tr(),
              message: 'holiday.delete_confirmation'.tr(),
              isLoading: isLoading,
              onDelete: () async {
                final success = await ref
                    .read(officialHolidaysProvider.notifier)
                    .deleteOfficialHoliday(holiday.id);

                if (success && dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
            );
          },
        );
      },
    );
  }
}

