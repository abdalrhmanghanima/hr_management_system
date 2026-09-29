class PayrollCalculationEntity {
  final String employeeId;
  final String employeeName;
  final String departmentId;
  final double basicSalary;
  final double dailyRate;
  final double hourlyRate;
  final int workingDays;
  final int presentDays;
  final int absentDays;
  final int holidayDays;
  final double overtimeHours;
  final double overtimeAmount;
  final double deductionHours;
  final double lateEarlyDeductionAmount;
  final double absenceDeduction;
  final double totalDeductions;
  final double netSalary;
  final int year;
  final int month;

  const PayrollCalculationEntity({
    required this.employeeId,
    required this.employeeName,
    required this.departmentId,
    required this.basicSalary,
    required this.dailyRate,
    required this.hourlyRate,
    required this.workingDays,
    required this.presentDays,
    required this.absentDays,
    required this.holidayDays,
    required this.overtimeHours,
    required this.overtimeAmount,
    required this.deductionHours,
    required this.lateEarlyDeductionAmount,
    required this.absenceDeduction,
    required this.totalDeductions,
    required this.netSalary,
    required this.year,
    required this.month,
  });

  String get monthLabel {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${names[month - 1]} $year';
  }
}
