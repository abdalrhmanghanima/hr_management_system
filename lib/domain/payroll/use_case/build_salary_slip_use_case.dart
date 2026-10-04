import 'package:hr_management_system/domain/payroll/entity/payroll_calculation_entity.dart';
import 'package:hr_management_system/domain/payroll/entity/salary_slip_entity.dart';

class BuildSalarySlipUseCase {
  const BuildSalarySlipUseCase();

  SalarySlipEntity call({
    required PayrollCalculationEntity payroll,
    required String departmentName,
  }) {
    return SalarySlipEntity(
      employeeId: payroll.employeeId,
      employeeName: payroll.employeeName,
      departmentName: departmentName,
      year: payroll.year,
      month: payroll.month,
      reference: referenceOf(
        employeeId: payroll.employeeId,
        year: payroll.year,
        month: payroll.month,
      ),
      basicSalary: payroll.basicSalary,
      overtimeHours: payroll.overtimeHours,
      overtimeAmount: payroll.overtimeAmount,
      deductionHours: payroll.deductionHours,
      totalDeductions: payroll.totalDeductions,
      presentDays: payroll.presentDays,
      absentDays: payroll.absentDays,
      workingDays: payroll.workingDays,
      netSalary: payroll.netSalary,
    );
  }

  String referenceOf({
    required String employeeId,
    required int year,
    required int month,
  }) {
    final compactId = employeeId.replaceAll('-', '').toUpperCase();
    final shortId = compactId.length > 8
        ? compactId.substring(0, 8)
        : compactId;
    final monthToken = month.toString().padLeft(2, '0');

    return 'PAY-$shortId-$year$monthToken';
  }
}
