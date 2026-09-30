import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class WeekendDaysPicker extends StatefulWidget {
  final List<String> days;
  final List<String> selectedDays;

  const WeekendDaysPicker({
    super.key,
    required this.days,
    required this.selectedDays,
  });

  @override
  State<WeekendDaysPicker> createState() => _WeekendDaysPickerState();
}

class _WeekendDaysPickerState extends State<WeekendDaysPicker> {
  late List<String> selectedDays;

  @override
  void initState() {
    super.initState();
    selectedDays = List<String>.from(widget.selectedDays);
  }

  void _toggleDay(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.r, 12.h, 20.r, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            CustomText(
              title: 'settings.select_weekend_days_title'.tr(),
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
            SizedBox(height: 5.h),
            CustomText(
              title: 'settings.select_weekend_days_hint'.tr(),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              fontColor: AppColors.gray,
            ),
            SizedBox(height: 14.h),
            ...widget.days.map((day) {
              final isSelected = selectedDays.contains(day);

              return InkWell(
                onTap: () => _toggleDay(day),
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  margin: EdgeInsets.only(bottom: 6.h),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.06)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        onChanged: (_) => _toggleDay(day),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: CustomText(
                          title: day,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          fontColor: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedDays.isEmpty
                    ? null
                    : () => Navigator.pop(context, selectedDays),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'common.done'.tr(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
