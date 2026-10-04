import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

Future<DateTime?> showMonthYearPickerDialog(
  BuildContext context, {
  required DateTime initialMonth,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (dialogContext) {
      return MonthYearPickerDialog(initialMonth: initialMonth);
    },
  );
}

class MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialMonth;

  const MonthYearPickerDialog({super.key, required this.initialMonth});

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int year;
  late int month;

  @override
  void initState() {
    super.initState();

    year = widget.initialMonth.year;
    month = widget.initialMonth.month;
  }

  void _changeYear(int delta) {
    setState(() {
      year += delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              title: 'common.choose_month'.tr(),
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              fontColor: AppColors.black,
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _YearArrow(
                  key: const ValueKey('month-picker-year-prev'),
                  assetName: AppIcons.leftArrow,
                  onTap: () => _changeYear(-1),
                ),
                SizedBox(width: 24.w),
                CustomText(
                  title: '$year',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  fontColor: AppColors.black,
                ),
                SizedBox(width: 24.w),
                _YearArrow(
                  key: const ValueKey('month-picker-year-next'),
                  assetName: AppIcons.rightArrow,
                  onTap: () => _changeYear(1),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 8.w,
              childAspectRatio: 2.4,
              children: List.generate(12, (index) {
                final monthNumber = index + 1;
                final isSelected = monthNumber == month;

                return InkWell(
                  key: ValueKey('month-picker-option-$monthNumber'),
                  onTap: () {
                    Navigator.pop(context, DateTime(year, monthNumber));
                  },
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: CustomText(
                      title: AppLocalization.month(context, monthNumber),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontColor: isSelected
                          ? AppColors.white
                          : AppColors.gray,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _YearArrow extends StatelessWidget {
  final String assetName;
  final VoidCallback onTap;

  const _YearArrow({
    super.key,
    required this.assetName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: CustomSvgIcon(
          assetName: assetName,
          width: 16.w,
          height: 16.w,
          color: AppColors.gray,
          mirrorInRtl: true,
        ),
      ),
    );
  }
}
