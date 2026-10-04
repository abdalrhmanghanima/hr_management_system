import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';
import 'package:hr_management_system/domain/payroll/entity/salary_slip_entity.dart';
import 'package:hr_management_system/presentation/payroll/provider/salary_slip_provider.dart';

import '../../helpers/localization_test_helper.dart';

SalarySlipEntity buildSlipEntity({
  double basicSalary = 12500,
  double overtimeHours = 5,
  double overtimeAmount = 275,
  double deductionHours = 0,
  double totalDeductions = 0,
  int presentDays = 20,
  int absentDays = 2,
  double netSalary = 12775,
}) {
  return SalarySlipEntity(
    employeeId: 'EMP001',
    employeeName: 'Ahmed Mohamed',
    departmentName: 'Engineering',
    year: 2026,
    month: 9,
    reference: 'PAY-EMP001-202609',
    basicSalary: basicSalary,
    overtimeHours: overtimeHours,
    overtimeAmount: overtimeAmount,
    deductionHours: deductionHours,
    totalDeductions: totalDeductions,
    presentDays: presentDays,
    absentDays: absentDays,
    workingDays: 22,
    netSalary: netSalary,
  );
}

void main() {
  group('Salary slip document', () {
    testWidgets('builds localized lines for English', (tester) async {
      await pumpLocalized(tester, const SizedBox.shrink());

      final document = buildSalarySlipDocument(buildSlipEntity(), rtl: false);

      expect(document.rtl, isFalse);
      expect(document.periodValue, 'September 2026');
      expect(document.texts.appName, 'HR Management System');
      expect(document.texts.confidentialTitle, 'CONFIDENTIAL PAY SLIP');
      expect(document.texts.employeeNameLabel, 'Employee Name');
      expect(document.texts.departmentLabel, 'Department');
      expect(document.texts.monthLabel, 'Month');
      expect(document.texts.referenceLabel, 'Reference');
      expect(document.texts.descriptionLabel, 'Description');
      expect(document.texts.amountLabel, 'Amount (EGP)');
      expect(document.texts.stampLabel, 'Authorized Digital Stamp');
      expect(document.texts.approvedLabel, 'HR Approved & Verified');
      expect(document.texts.pageLabel, 'Page {current} of {total}');

      expect(document.lines, hasLength(5));

      expect(document.lines[0].label, 'Basic Salary');
      expect(document.lines[0].value, '12,500');
      expect(document.lines[1].label, 'Attendance Work Days');
      expect(document.lines[1].value, '20 Days');
      expect(document.lines[2].label, 'Absence Days');
      expect(document.lines[2].value, '2 Days');
      expect(document.lines[3].label, 'Overtime (5 hrs)');
      expect(document.lines[3].value, '+275');
      expect(document.lines[4].label, 'Deductions (0 hrs)');
      expect(document.lines[4].value, '-0');

      expect(document.netLine.label, 'Net Transfer Salary');
      expect(document.netLine.value, '12,775 EGP');
    });

    testWidgets('builds localized lines for Arabic', (tester) async {
      await pumpLocalized(
        tester,
        const SizedBox.shrink(),
        locale: AppLocalization.ar,
      );

      final document = buildSalarySlipDocument(buildSlipEntity(), rtl: true);

      expect(document.rtl, isTrue);
      expect(document.periodValue, 'سبتمبر 2026');
      expect(document.texts.descriptionLabel, 'البيان');
      expect(document.texts.amountLabel, 'المبلغ (ج.م)');
      expect(document.texts.pageLabel, 'صفحة {current} من {total}');

      expect(document.lines, hasLength(5));

      expect(document.lines[0].label, 'الراتب الأساسي');
      expect(document.lines[0].value, '12,500');
      expect(document.lines[1].value, '20 يوم');
      expect(document.lines[2].value, '2 يوم');
      expect(document.lines[3].label, 'العمل الصاجي (5 ساعة)');
      expect(document.lines[3].value, '+275');
      expect(document.lines[4].value, '-0');

      expect(document.netLine.label, 'صافي الراتب المحوّل');
      expect(document.netLine.value, '12,775 ج.م');
    });
  });
}
