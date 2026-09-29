class GeneralSettingsEntity {
  final double multiplier;
  final double workingHoursPerDay;
  final List<String> weekendDays;

  const GeneralSettingsEntity({
    required this.multiplier,
    required this.workingHoursPerDay,
    required this.weekendDays,
  });

  factory GeneralSettingsEntity.defaults() {
    return const GeneralSettingsEntity(
      multiplier: 2,
      workingHoursPerDay: 8,
      weekendDays: ['Friday', 'Saturday'],
    );
  }
}
