class AttendanceCalculationEntity {
  final double actualWorkedHours;
  final double overtimeHours;
  final double deductionHours;
  final double hourlyRate;
  final double overtimeAmount;
  final double deductionAmount;

  const AttendanceCalculationEntity({
    required this.actualWorkedHours,
    required this.overtimeHours,
    required this.deductionHours,
    required this.hourlyRate,
    required this.overtimeAmount,
    required this.deductionAmount,
  });

  factory AttendanceCalculationEntity.empty() {
    return const AttendanceCalculationEntity(
      actualWorkedHours: 0,
      overtimeHours: 0,
      deductionHours: 0,
      hourlyRate: 0,
      overtimeAmount: 0,
      deductionAmount: 0,
    );
  }
}
