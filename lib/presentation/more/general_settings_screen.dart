import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/constants/constants.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/update_confirmation_dialog.dart';
import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';
import 'package:hr_management_system/domain/general_settings/validation/general_settings_validator.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_snack_bar/custom_snack_bar.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/more/provider/general_settings_provider.dart';
import 'package:hr_management_system/presentation/more/widgets/settings_card.dart';
import 'package:hr_management_system/presentation/more/widgets/settings_field_label.dart';
import 'package:hr_management_system/presentation/more/widgets/settings_section_title.dart';
import 'package:hr_management_system/presentation/more/widgets/settings_text_field.dart';
import 'package:hr_management_system/presentation/more/widgets/weekend_days_picker.dart';

class GeneralSettingsScreen extends ConsumerStatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  ConsumerState<GeneralSettingsScreen> createState() =>
      _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends ConsumerState<GeneralSettingsScreen> {
  late final TextEditingController multiplierController;
  late final TextEditingController workingHoursController;

  late List<String> selectedWeekendDays;

  bool isHydrated = false;

  final List<String> weekDays = weekDayNames;

  @override
  void initState() {
    super.initState();

    final defaults = GeneralSettingsEntity.defaults();

    multiplierController = TextEditingController(
      text: defaults.multiplier.toString(),
    );

    workingHoursController = TextEditingController(
      text: defaults.workingHoursPerDay.toString(),
    );

    selectedWeekendDays = List<String>.from(defaults.weekendDays);

    Future.microtask(() {
      ref.read(generalSettingsProvider.notifier).getGeneralSettings();
    });
  }

  @override
  void dispose() {
    multiplierController.dispose();
    workingHoursController.dispose();

    super.dispose();
  }

  void _hydrate(GeneralSettingsEntity settings) {
    if (isHydrated) {
      return;
    }

    isHydrated = true;

    multiplierController.text = settings.multiplier.toString();
    workingHoursController.text = settings.workingHoursPerDay.toString();

    selectedWeekendDays = List<String>.from(settings.weekendDays);
  }

  Future<void> _persistAfterConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return UpdateConfirmationDialog(
          title: 'settings.title'.tr(),
          message: 'settings.update_confirmation'.tr(),
          confirmLabel: 'settings.update_button'.tr(),
          onConfirm: () {
            Navigator.pop(dialogContext, true);
          },
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final saved = await ref
        .read(generalSettingsProvider.notifier)
        .updateGeneralSettings(
          GeneralSettingsEntity(
            multiplier: double.parse(multiplierController.text.trim()),
            workingHoursPerDay: double.parse(
              workingHoursController.text.trim(),
            ),
            weekendDays: List<String>.from(selectedWeekendDays),
          ),
        );

    if (!saved && mounted) {
      _showError('settings.save_failed'.tr());
    }
  }

  void _handleFieldChanged() {
    setState(() {});
  }

  Future<void> _handleFieldSubmitted() async {
    setState(() {});

    final multiplierError = GeneralSettingsValidator.multiplier(
      multiplierController.text,
    );

    final workingHoursError = GeneralSettingsValidator.workingHoursPerDay(
      workingHoursController.text,
    );

    final weekendError = GeneralSettingsValidator.weekendDays(
      selectedWeekendDays,
    );

    if (multiplierError != null ||
        workingHoursError != null ||
        weekendError != null) {
      return;
    }

    await _persistAfterConfirmation();
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    CustomSnackBar.show(context, message: message, success: false);
  }

  Future<void> _showWeekendDaysPicker() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return WeekendDaysPicker(
          days: weekDays,
          selectedDays: selectedWeekendDays,
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      selectedWeekendDays = result;
    });

    if (result.isEmpty) {
      return;
    }

    await _persistAfterConfirmation();
  }

  String get selectedDaysText {
    if (selectedWeekendDays.isEmpty) {
      return 'settings.select_weekend_days'.tr();
    }

    return selectedWeekendDays.join(' + ');
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(generalSettingsProvider);

    settingsState.whenData(_hydrate);

    final multiplierError = GeneralSettingsValidator.multiplier(
      multiplierController.text,
    );

    final workingHoursError = GeneralSettingsValidator.workingHoursPerDay(
      workingHoursController.text,
    );

    final weekendError = GeneralSettingsValidator.weekendDays(
      selectedWeekendDays,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(title: 'settings.title'.tr()),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.r, 20.r, 20.r, 30.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSectionTitle(
              title: 'settings.payroll_calculation'.tr(),
              subtitle: 'settings.payroll_calculation_subtitle'.tr(),
            ),
            SizedBox(height: 12.h),
            SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingsFieldLabel(
                    title: 'settings.multiplier'.tr(),
                    required: true,
                  ),
                  SizedBox(height: 8.h),
                  SettingsTextField(
                    controller: multiplierController,
                    hintText: 'settings.multiplier_hint'.tr(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _handleFieldChanged(),
                    onSubmitted: (_) => _handleFieldSubmitted(),
                  ),
                  if (multiplierError != null) ...[
                    SizedBox(height: 8.h),
                    CustomText(
                      title: multiplierError.tr(),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      fontColor: AppColors.red,
                    ),
                  ],
                  SizedBox(height: 20.h),
                  SettingsFieldLabel(
                    title: 'settings.working_hours_per_day'.tr(),
                    required: true,
                  ),
                  SizedBox(height: 8.h),
                  SettingsTextField(
                    controller: workingHoursController,
                    hintText: 'settings.working_hours_hint'.tr(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _handleFieldChanged(),
                    onSubmitted: (_) => _handleFieldSubmitted(),
                  ),
                  if (workingHoursError != null) ...[
                    SizedBox(height: 8.h),
                    CustomText(
                      title: workingHoursError.tr(),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      fontColor: AppColors.red,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24.h),
            SettingsSectionTitle(
              title: 'settings.weekly_holidays'.tr(),
              subtitle: 'settings.weekly_holidays_subtitle'.tr(),
            ),
            SizedBox(height: 12.h),
            SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingsFieldLabel(
                    title: 'settings.weekend_days'.tr(),
                    required: true,
                  ),
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: _showWeekendDaysPicker,
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 15.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFD9E1EC)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomText(
                              title: selectedDaysText,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              fontColor: selectedWeekendDays.isEmpty
                                  ? AppColors.gray
                                  : AppColors.black,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.black,
                            size: 24.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (weekendError != null) ...[
                    SizedBox(height: 8.h),
                    CustomText(
                      title: weekendError.tr(),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      fontColor: AppColors.red,
                    ),
                  ],
                  SizedBox(height: 18.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: CustomText(
                      title: 'settings.impact_note'.tr(),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      fontColor: AppColors.gray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
