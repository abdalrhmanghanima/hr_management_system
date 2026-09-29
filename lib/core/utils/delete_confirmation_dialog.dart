import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onDelete;
  final bool isLoading;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onDelete,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: AppColors.red,
                size: 28.w,
              ),
            ),
            SizedBox(height: 16.h),
            CustomText(
              title: title,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              fontColor: AppColors.primary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            CustomText(
              title: message,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              fontColor: const Color(0xFF64748B),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    title: 'Cancel',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    bg: const Color(0xFFF1F5F9),
                    fontColor: const Color(0xFF334155),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    title: 'Delete',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    bg: AppColors.red,
                    isLoading: isLoading,
                    onTap: onDelete,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}