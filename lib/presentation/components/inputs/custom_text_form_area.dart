
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:flutter/material.dart';

import '../../../core/app_theme/text_styles.dart';

class CustomTextFormFieldArea extends StatelessWidget {
  final String? hint;
  final TextEditingController controller;
  final double? height;
  final Widget? prefix;
  final Widget? suffix;
  final bool readOnly;
  final Color? bgColor;
  final double? borderRadius;
  final ValueChanged<String>? onChange;

  const CustomTextFormFieldArea({super.key,required this.controller,this.hint,this.prefix,this.suffix,this.readOnly = false,this.bgColor, this.onChange, this.borderRadius, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: Dimens.padding_16h),
      height: 96.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bgColor??AppColors.inputBg,borderRadius: BorderRadius.circular(borderRadius??16.r)),
      child: TextFormField(
        readOnly:readOnly ,
        controller: controller,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: AppColors.primary,
        style: AppTextStyles().normalText().textColorNormal(AppColors.black),
        keyboardType:TextInputType.multiline,
        maxLines: null,
        onChanged: onChange,
        decoration: InputDecoration(

          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppTextStyles().normalText().textColorNormal(AppColors.inputHint),
          suffixIcon: suffix,
          prefixIcon: prefix,
          suffixIconConstraints:   BoxConstraints(maxHeight: 24.h,maxWidth:96.w,minWidth: 45.w,),
          prefixIconConstraints:  BoxConstraints(maxHeight: 24.h,maxWidth:96.w,minWidth: 45.w),
          counterText: '',

        ),
      ),
    );
  }
}
