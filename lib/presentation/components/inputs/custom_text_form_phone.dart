import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/dimens/dimens.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_theme/text_styles.dart';

class CustomTextFormFieldPhone extends StatelessWidget {
  final String? hint;
  final TextEditingController controller;
  final Widget? prefix;
  final Widget? suffix;
  final bool readOnly;
  final Color? bgColor;
  final double? borderRadius;
  final ValueChanged<String>? onChange;

  const CustomTextFormFieldPhone({super.key,required this.controller,this.hint,this.prefix,this.suffix ,this.readOnly = false,this.bgColor, this.onChange, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: Dimens.padding_16h),
      height: 56.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bgColor??AppColors.inputBg,borderRadius: BorderRadius.circular(borderRadius??16.r)),
      child: TextFormField(
        readOnly:readOnly ,
        controller: controller,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: AppColors.primary,
        style: AppTextStyles().normalText().textColorNormal(AppColors.black),
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
