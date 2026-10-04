import 'package:hr_management_system/domain/payroll/entity/salary_slip_texts.dart';

class SalarySlipLine {
  final String label;
  final String value;

  const SalarySlipLine({required this.label, required this.value});
}

class SalarySlipEntity {
  final String employeeId;
  final String employeeName;
  final String departmentName;
  final int year;
  final int month;
  final String reference;
  final double basicSalary;
  final double overtimeHours;
  final double overtimeAmount;
  final double deductionHours;
  final double totalDeductions;
  final int presentDays;
  final int absentDays;
  final int workingDays;
  final double netSalary;

  const SalarySlipEntity({
    required this.employeeId,
    required this.employeeName,
    required this.departmentName,
    required this.year,
    required this.month,
    required this.reference,
    required this.basicSalary,
    required this.overtimeHours,
    required this.overtimeAmount,
    required this.deductionHours,
    required this.totalDeductions,
    required this.presentDays,
    required this.absentDays,
    required this.workingDays,
    required this.netSalary,
  });
}

class SalarySlipDocument {
  final SalarySlipEntity slip;
  final SalarySlipTexts texts;
  final List<SalarySlipLine> lines;
  final SalarySlipLine netLine;
  final String periodValue;
  final bool rtl;

  const SalarySlipDocument({
    required this.slip,
    required this.texts,
    required this.lines,
    required this.netLine,
    required this.periodValue,
    required this.rtl,
  });
}
