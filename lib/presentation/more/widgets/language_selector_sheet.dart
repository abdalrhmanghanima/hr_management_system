import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';
import 'package:hr_management_system/core/responsive/responsive_widgets.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class LanguageOption {
  final Locale locale;
  final String label;

  const LanguageOption(this.locale, this.label);
}

class LanguageSelectorSheet extends StatelessWidget {
  final Locale currentLocale;

  const LanguageSelectorSheet({super.key, required this.currentLocale});

  static List<LanguageOption> get options => [
    LanguageOption(AppLocalization.en, 'language.english'),
    LanguageOption(AppLocalization.ar, 'language.arabic'),
  ];

  static Future<void> show(BuildContext context) async {
    final selected = await showModalBottomSheet<Locale>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) {
        return ResponsiveSheetContent(
          child: LanguageSelectorSheet(currentLocale: context.locale),
        );
      },
    );

    if (selected == null || !context.mounted) {
      return;
    }

    await context.setLocale(selected);
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
              title: context.tr('language.title'),
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.black,
            ),
            SizedBox(height: 5.h),
            CustomText(
              title: context.tr('language.subtitle'),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              fontColor: AppColors.gray,
            ),
            SizedBox(height: 14.h),
            ...options.map((option) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _LanguageTile(
                  option: option,
                  isSelected:
                      option.locale.languageCode == currentLocale.languageCode,
                  onTap: () {
                    Navigator.pop(context, option.locale);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final LanguageOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFD9E1EC),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomText(
                title: context.tr(option.label),
                fontSize: 16.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontColor: isSelected ? AppColors.primary : AppColors.black,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 22.w),
          ],
        ),
      ),
    );
  }
}
