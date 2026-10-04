import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

import 'month_year_picker_dialog.dart';

class MonthFilterRow extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final DateTime? currentMonth;

  const MonthFilterRow({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
    this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final selected = _normalize(selectedMonth);
    final current = currentMonth == null ? _nowMonth() : _normalize(currentMonth!);
    final previous = DateTime(current.year, current.month - 1);

    final isSelectedCurrent = selected.year == current.year && selected.month == current.month;
    final isSelectedPrevious = selected.year == previous.year && selected.month == previous.month;
    final isSelectedChosen = !isSelectedCurrent && !isSelectedPrevious;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _MonthFilterChip(
            chipKey: 'month-filter-chip-current',
            label: 'common.current_month'.tr(),
            selected: isSelectedCurrent,
            onTap: () => onMonthChanged(current),
          ),
          SizedBox(width: 8.w),
          _MonthFilterChip(
            chipKey: 'month-filter-chip-previous',
            label: 'common.previous_month'.tr(),
            selected: isSelectedPrevious,
            onTap: () => onMonthChanged(previous),
          ),
          SizedBox(width: 8.w),
          _MonthFilterChip(
            chipKey: 'month-filter-chip-choose',
            label: isSelectedChosen
                ? AppLocalization.monthYear(context, selected)
                : 'common.choose_month'.tr(),
            selected: isSelectedChosen,
            onTap: () async {
              final pickedMonth = await showMonthYearPickerDialog(
                context,
                initialMonth: selected,
              );

              if (pickedMonth != null) {
                onMonthChanged(pickedMonth);
              }
            },
          ),
        ],
      ),
    );
  }

  static DateTime _normalize(DateTime value) {
    return DateTime(value.year, value.month);
  }

  static DateTime _nowMonth() {
    final now = DateTime.now();

    return DateTime(now.year, now.month);
  }
}

class _MonthFilterChip extends StatelessWidget {
  final String chipKey;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MonthFilterChip({
    required this.chipKey,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey(chipKey),
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: CustomText(
          title: label,
          fontSize: 12.sp,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontColor: selected ? AppColors.white : AppColors.gray,
        ),
      ),
    );
  }
}
