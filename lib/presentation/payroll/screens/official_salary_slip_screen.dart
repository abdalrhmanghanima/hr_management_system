import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/domain/payroll/entity/salary_slip_entity.dart';
import 'package:hr_management_system/presentation/authorization/widgets/permission_guard.dart';
import 'package:hr_management_system/presentation/components/custom_app_bar/custom_app_bar.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/components/custom_snack_bar/custom_snack_bar.dart';
import 'package:hr_management_system/presentation/components/custom_text/custom_text.dart';
import 'package:hr_management_system/presentation/payroll/provider/salary_slip_provider.dart';

class OfficialSalarySlipScreen extends ConsumerWidget {
  final String employeeId;

  const OfficialSalarySlipScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slipState = ref.watch(salarySlipEntityProvider(employeeId));
    final busy = ref.watch(salarySlipActionInProgressProvider);
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return PermissionGuard(
      module: GroupModules.payroll,
      action: PermissionAction.view,
      popOnDenied: true,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(
          title: 'payroll.official_salary_slip'.tr(),
          fontSize: 18.sp,
        ),
        body: slipState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: CustomText(
              title: 'payroll.load_failed'.tr(),
              fontColor: AppColors.red,
            ),
          ),
          data: (slip) {
            if (slip == null) {
              return Center(
                child: CustomText(
                  title: 'payroll.not_found'.tr(),
                  fontColor: AppColors.gray,
                ),
              );
            }

            final document = buildSalarySlipDocument(slip, rtl: rtl);

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SlipCard(document: document),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          title: 'payroll.print_salary_slip'.tr(),
                          iconPath: AppIcons.print,
                          bg: AppColors.primary,
                          fontColor: AppColors.white,
                          fontWeight: FontWeight.w700,
                          isLoading: busy,
                          onTap: busy
                              ? null
                              : () => _print(context, ref, document),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: CustomButton(
                          title: 'payroll.share_slip'.tr(),
                          bg: const Color(0xFFEAF3FF),
                          fontColor: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          isLoading: busy,
                          onTap: busy
                              ? null
                              : () => _share(context, ref, document),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _print(
    BuildContext context,
    WidgetRef ref,
    SalarySlipDocument document,
  ) async {
    final repository = ref.read(salarySlipPdfRepositoryProvider);
    final busyNotifier = ref.read(salarySlipActionInProgressProvider.notifier);

    busyNotifier.state = true;

    try {
      final pdf = await repository.generatePdf(document);

      try {
        await repository.printPdf(pdf, name: document.slip.reference);
      } catch (_) {
        if (context.mounted) {
          CustomSnackBar.show(context, message: 'payroll.print_failed'.tr());
        }
      }
    } catch (_) {
      if (context.mounted) {
        CustomSnackBar.show(context, message: 'payroll.pdf_failed'.tr());
      }
    } finally {
      busyNotifier.state = false;
    }
  }

  Future<void> _share(
    BuildContext context,
    WidgetRef ref,
    SalarySlipDocument document,
  ) async {
    final repository = ref.read(salarySlipPdfRepositoryProvider);
    final busyNotifier = ref.read(salarySlipActionInProgressProvider.notifier);

    busyNotifier.state = true;

    try {
      final pdf = await repository.generatePdf(document);

      try {
        await repository.sharePdf(pdf, fileName: document.slip.reference);
      } catch (_) {
        if (context.mounted) {
          CustomSnackBar.show(context, message: 'payroll.share_failed'.tr());
        }
      }
    } catch (_) {
      if (context.mounted) {
        CustomSnackBar.show(context, message: 'payroll.pdf_failed'.tr());
      }
    } finally {
      busyNotifier.state = false;
    }
  }
}

class _SlipCard extends StatelessWidget {
  final SalarySlipDocument document;

  const _SlipCard({required this.document});

  static const Color _ink = Color(0xFF111827);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _soft = Color(0xFFF8FAFC);
  static const Color _darkBlue = Color(0xFF0F172A);
  static const Color _netRow = Color(0xFFEAF3FF);

  @override
  Widget build(BuildContext context) {
    final texts = document.texts;
    final pageLabel = texts.pageLabel
        .replaceAll('{current}', '1')
        .replaceAll('{total}', '1');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText(
            title: texts.confidentialTitle,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            fontColor: _muted,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          CustomText(
            title: texts.appName,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            fontColor: _ink,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),
          const Divider(height: 1, color: _border),
          SizedBox(height: 14.h),

          Row(
            children: [
              _metaCell(texts.employeeNameLabel, document.slip.employeeName),
              SizedBox(width: 8.w),
              _metaCell(texts.departmentLabel, document.slip.departmentName),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _metaCell(texts.monthLabel, document.periodValue),
              SizedBox(width: 8.w),
              _metaCell(texts.referenceLabel, document.slip.reference),
            ],
          ),

          SizedBox(height: 16.h),

          _table(),

          SizedBox(height: 16.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _badge(texts.stampLabel)),
              Flexible(child: _badge(texts.approvedLabel)),
            ],
          ),

          SizedBox(height: 12.h),

          CustomText(
            title: pageLabel,
            fontSize: 11.sp,
            fontColor: _muted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _metaCell(String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: _soft,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(title: label, fontSize: 11.sp, fontColor: _muted),
            SizedBox(height: 3.h),
            CustomText(
              title: value,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              fontColor: _ink,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _table() {
    final texts = document.texts;
    final rowPadding = EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h);

    Widget row(String label, String value) {
      return Padding(
        padding: rowPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: CustomText(
                title: label,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                fontColor: _ink,
              ),
            ),
            Flexible(
              child: CustomText(
                title: value,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                fontColor: _ink,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: _darkBlue,
            padding: rowPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: CustomText(
                    title: texts.descriptionLabel,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    fontColor: AppColors.white,
                  ),
                ),
                Flexible(
                  child: CustomText(
                    title: texts.amountLabel,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    fontColor: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          for (final line in document.lines)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _border)),
              ),
              child: row(line.label, line.value),
            ),
          Container(
            width: double.infinity,
            color: _netRow,
            padding: rowPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: CustomText(
                    title: document.netLine.label,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    fontColor: _ink,
                  ),
                ),
                Flexible(
                  child: CustomText(
                    title: document.netLine.value,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    fontColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: CustomText(
        title: label,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        fontColor: _muted,
        textAlign: TextAlign.center,
      ),
    );
  }
}
