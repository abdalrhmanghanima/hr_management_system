import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/presentation/components/custom_svg/custom_svg_icon.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';

class AttendanceSelectedFile extends StatelessWidget {
  final String fileName;
  final VoidCallback? onChange;
  final VoidCallback? onRemove;

  const AttendanceSelectedFile({
    super.key,
    required this.fileName,
    this.onChange,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: CustomSvgIcon(
                    assetName: AppIcons.file,
                    width: 20.w,
                    height: 20.w,
                    color: AppColors.primary,
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title: fileName,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.black,
                      maxLines: 1,
                    ),

                    SizedBox(height: 5.h),

                    _FileTypeChip(extension: _extensionOf(fileName)),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          SizedBox(height: 10.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: onChange,
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 17.w,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 5.w),
                      CustomText(
                        title: 'Change',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        fontColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 17.w,
                        color: AppColors.red,
                      ),
                      SizedBox(width: 5.w),
                      CustomText(
                        title: 'Remove',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        fontColor: AppColors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _extensionOf(String name) {
    final dotIndex = name.lastIndexOf('.');

    if (dotIndex < 0 || dotIndex == name.length - 1) {
      return 'File';
    }

    return name.substring(dotIndex + 1).toUpperCase();
  }
}

class _FileTypeChip extends StatelessWidget {
  final String extension;

  const _FileTypeChip({required this.extension});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: CustomText(
          title: extension,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          fontColor: AppColors.primary,
        ),
      ),
    );
  }
}
