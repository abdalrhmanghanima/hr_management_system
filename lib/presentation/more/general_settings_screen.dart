import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
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

  final List<String> weekDays = const [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

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

  Future<void> _persist() async {
    final multiplier = double.tryParse(multiplierController.text.trim());
    final workingHours = double.tryParse(workingHoursController.text.trim());

    if (multiplier == null || workingHours == null) {
      return;
    }

    await ref
        .read(generalSettingsProvider.notifier)
        .updateGeneralSettings(
          GeneralSettingsEntity(
            multiplier: multiplier,
            workingHoursPerDay: workingHours,
            weekendDays: List<String>.from(selectedWeekendDays),
          ),
        );
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

    await _persist();
  }

  String get selectedDaysText {
    if (selectedWeekendDays.isEmpty) {
      return 'Select weekend days';
    }

    return selectedWeekendDays.join(' + ');
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(generalSettingsProvider);

    settingsState.whenData(_hydrate);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const CustomAppBar(title: 'General Settings'),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.r, 20.r, 20.r, 30.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSectionTitle(
              title: 'Payroll Calculation',
              subtitle: 'Configure standard payroll calculation settings',
            ),
            SizedBox(height: 12.h),
            SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SettingsFieldLabel(title: 'Multiplier', required: true),
                  SizedBox(height: 8.h),
                  SettingsTextField(
                    controller: multiplierController,
                    hintText: 'Enter multiplier',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) => _persist(),
                  ),
                  SizedBox(height: 20.h),
                  const SettingsFieldLabel(
                    title: 'Working Hours Per Day',
                    required: true,
                  ),
                  SizedBox(height: 8.h),
                  SettingsTextField(
                    controller: workingHoursController,
                    hintText: 'Enter working hours',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) => _persist(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            SettingsSectionTitle(
              title: 'Weekly Holidays',
              subtitle: 'Select the weekly days excluded from attendance',
            ),
            SizedBox(height: 12.h),
            SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SettingsFieldLabel(
                    title: 'Weekend Days',
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
                  SizedBox(height: 18.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      'Impact Note: Weekly holiday days are automatically excluded from working days when calculating monthly payroll and absence deductions.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.5,
                        color: AppColors.gray,
                      ),
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
