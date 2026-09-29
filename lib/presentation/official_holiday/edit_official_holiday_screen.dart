import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/date_parser.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_snack_bar/custom_snack_bar.dart';
import 'package:hr_management_system/presentation/official_holiday/provider/official_holidays_provider.dart';
import 'package:hr_management_system/presentation/official_holiday/widgets/official_holiday_form.dart';

class EditOfficialHolidayScreen extends ConsumerStatefulWidget {
  final OfficialHolidayEntity holiday;

  const EditOfficialHolidayScreen({super.key, required this.holiday});

  @override
  ConsumerState<EditOfficialHolidayScreen> createState() =>
      _EditOfficialHolidayScreenState();
}

class _EditOfficialHolidayScreenState
    extends ConsumerState<EditOfficialHolidayScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    nameController.text = widget.holiday.name;

    dateController.text = DateParser.toDisplayDate(widget.holiday.date);
  }

  @override
  void dispose() {
    nameController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _updateHoliday() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final date = DateParser.fromDisplayDate(dateController.text);

    final holiday = OfficialHolidayEntity(
      id: widget.holiday.id,
      name: nameController.text.trim(),
      date: date,
    );

    final result = await ref
        .read(officialHolidaysProvider.notifier)
        .updateOfficialHoliday(holiday);

    if (!mounted) {
      return;
    }

    switch (result) {
      case SaveResult.success:
        Navigator.pop(context);
        break;
      case SaveResult.duplicate:
        CustomSnackBar.show(
          context,
          message: 'This holiday is already added on this date',
        );
        break;
      case SaveResult.failure:
        CustomSnackBar.show(
          context,
          message: 'Failed to update holiday. Please try again',
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final holidaysState = ref.watch(officialHolidaysProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const CustomAppBar(title: 'Edit Holiday'),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: OfficialHolidayForm(
                formKey: formKey,
                nameController: nameController,
                dateController: dateController,
                initialDate: widget.holiday.date,
              ),
            ),

            SizedBox(height: 16.h),

            CustomButton(
              title: 'Update Holiday',
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              isLoading: holidaysState.isLoading,
              onTap: _updateHoliday,
              bg: AppColors.primary,
            ),

            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
