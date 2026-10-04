import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> loadTranslations(String fileName) {
  final content = File('assets/languages/$fileName').readAsStringSync();

  return json.decode(content) as Map<String, dynamic>;
}

void flatten(
  Object? node,
  String prefix,
  Map<String, dynamic> result,
) {
  if (node is Map<String, dynamic>) {
    node.forEach((key, value) {
      final path = prefix.isEmpty ? key : '$prefix.$key';

      flatten(value, path, result);
    });

    return;
  }

  result[prefix] = node;
}

void main() {
  test('English and Arabic translations define the same keys', () {
    final english = <String, dynamic>{};
    final arabic = <String, dynamic>{};

    flatten(loadTranslations('en.json'), '', english);
    flatten(loadTranslations('ar.json'), '', arabic);

    expect(english.keys, isNotEmpty);
    expect(arabic.keys.toSet(), english.keys.toSet());
  });

  test('payroll salary slip keys exist in both languages', () {
    final english = <String, dynamic>{};
    final arabic = <String, dynamic>{};

    flatten(loadTranslations('en.json'), '', english);
    flatten(loadTranslations('ar.json'), '', arabic);

    const keys = [
      'home.current_month_payroll',
      'payroll.details_title',
      'payroll.attendance_statistics',
      'payroll.financial_breakdown',
      'payroll.net_monthly_salary',
      'payroll.view_print_salary_slip',
      'payroll.official_salary_slip',
      'payroll.confidential_pay_slip',
      'payroll.employee_name',
      'payroll.month_label',
      'payroll.reference_label',
      'payroll.reference',
      'payroll.description',
      'payroll.amount_header',
      'payroll.attendance_work_days',
      'payroll.deductions',
      'payroll.net_transfer_salary',
      'payroll.authorized_digital_stamp',
      'payroll.hr_approved_verified',
      'payroll.page_of',
      'payroll.share_slip',
      'payroll.print_salary_slip',
      'payroll.days_value',
      'payroll.not_found',
      'payroll.pdf_failed',
      'payroll.print_failed',
      'payroll.share_failed',
    ];

    for (final key in keys) {
      expect(english.containsKey(key), isTrue, reason: 'missing en $key');
      expect(arabic.containsKey(key), isTrue, reason: 'missing ar $key');
    }
  });
}
