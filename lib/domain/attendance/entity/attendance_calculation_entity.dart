class AttendanceCalculationEntity {
  final double actualWorkedHours;
  final double overtimeHours;
  final double deductionHours;
  final double hourlyRate;
  final double overtimeAmount;
  final double deductionAmount;
  final double lateHours;
  final double earlyCheckoutHours;
  final double dailyRate;
  final double absenceDeduction;
  final bool isWorkingDay;
  final bool isAbsent;

  const AttendanceCalculationEntity({
    required this.actualWorkedHours,
    required this.overtimeHours,
    required this.deductionHours,
    required this.hourlyRate,
    required this.overtimeAmount,
    required this.deductionAmount,
    required this.lateHours,
    required this.earlyCheckoutHours,
    required this.dailyRate,
    required this.absenceDeduction,
    required this.isWorkingDay,
    required this.isAbsent,
  });

  factory AttendanceCalculationEntity.empty({bool isWorkingDay = true}) {
    return AttendanceCalculationEntity(
      actualWorkedHours: 0,
      overtimeHours: 0,
      deductionHours: 0,
      hourlyRate: 0,
      overtimeAmount: 0,
      deductionAmount: 0,
      lateHours: 0,
      earlyCheckoutHours: 0,
      dailyRate: 0,
      absenceDeduction: 0,
      isWorkingDay: isWorkingDay,
      isAbsent: false,
    );
  }
}
