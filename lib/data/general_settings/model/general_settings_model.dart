import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';

class GeneralSettingsModel extends GeneralSettingsEntity {
  const GeneralSettingsModel({
    required super.multiplier,
    required super.workingHoursPerDay,
    required super.weekendDays,
  });

  factory GeneralSettingsModel.defaults() {
    return const GeneralSettingsModel(
      multiplier: 2,
      workingHoursPerDay: 8,
      weekendDays: ['Friday', 'Saturday'],
    );
  }

  factory GeneralSettingsModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      return GeneralSettingsModel.defaults();
    }

    final defaults = GeneralSettingsEntity.defaults();

    return GeneralSettingsModel(
      multiplier:
          (data['multiplier'] as num?)?.toDouble() ?? defaults.multiplier,
      workingHoursPerDay:
          (data['workingHoursPerDay'] as num?)?.toDouble() ??
          defaults.workingHoursPerDay,
      weekendDays:
          (data['weekendDays'] as List<dynamic>?)
              ?.map((day) => day.toString())
              .toList() ??
          defaults.weekendDays,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'multiplier': multiplier,
      'workingHoursPerDay': workingHoursPerDay,
      'weekendDays': weekendDays,
    };
  }

  GeneralSettingsEntity toEntity() {
    return GeneralSettingsEntity(
      multiplier: multiplier,
      workingHoursPerDay: workingHoursPerDay,
      weekendDays: weekendDays,
    );
  }
}
