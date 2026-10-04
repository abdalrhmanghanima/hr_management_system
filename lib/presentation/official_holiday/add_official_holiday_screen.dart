import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/responsive/breakpoints.dart';
import 'package:hr_management_system/core/responsive/responsive_widgets.dart';
import 'package:hr_management_system/core/utils/date_parser.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/presentation/authorization/widgets/permission_guard.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_snack_bar/custom_snack_bar.dart';
import 'package:hr_management_system/presentation/official_holiday/provider/official_holidays_provider.dart';
import 'package:hr_management_system/presentation/official_holiday/widgets/official_holiday_form.dart';
import 'package:uuid/uuid.dart';

class AddOfficialHolidayScreen extends ConsumerStatefulWidget {
  const AddOfficialHolidayScreen({super.key});

  @override
  ConsumerState<AddOfficialHolidayScreen> createState() =>
      _AddOfficialHolidayScreenState();
}

class _AddOfficialHolidayScreenState
    extends ConsumerState<AddOfficialHolidayScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _saveHoliday() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final date = DateParser.fromDisplayDate(dateController.text);

    final holiday = OfficialHolidayEntity(
      id: const Uuid().v4(),
      name: nameController.text.trim(),
      date: date,
    );

    final result = await ref
        .read(officialHolidaysProvider.notifier)
        .addOfficialHoliday(holiday);

    if (!mounted) {
      return;
    }

    switch (result) {
      case SaveResult.success:
        CustomSnackBar.show(
          context,
          message: 'holiday.add_success'.tr(),
          success: true,
        );
        Navigator.pop(context);
        break;
      case SaveResult.duplicate:
        CustomSnackBar.show(context, message: 'holiday.duplicate'.tr());
        break;
      case SaveResult.failure:
        CustomSnackBar.show(context, message: 'holiday.add_failed'.tr());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final holidaysState = ref.watch(officialHolidaysProvider);

    return PermissionGuard(
      module: GroupModules.officialHolidays,
      action: PermissionAction.add,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(title: 'holiday.add_title'.tr()),
        body: Padding(
          padding: EdgeInsets.all(16.r),
          child: MaxWidthBox(
            maxWidth: AppBreakpoints.formMaxWidth,
            applyFromWidth: AppBreakpoints.desktopMinWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: OfficialHolidayForm(
                    formKey: formKey,
                    nameController: nameController,
                    dateController: dateController,
                  ),
                ),

                SizedBox(height: 16.h),

                CustomButton(
                  title: 'holiday.save_button'.tr(),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  isLoading: holidaysState.isLoading,
                  onTap: _saveHoliday,
                  bg: AppColors.primary,
                ),

                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
