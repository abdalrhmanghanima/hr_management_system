import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';

class OfficialHolidayModel extends OfficialHolidayEntity {
  const OfficialHolidayModel({
    required super.id,
    required super.name,
    required super.date,
  });

  factory OfficialHolidayModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return OfficialHolidayModel(
      id: document.id,
      name: data['name'] as String,
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'date': Timestamp.fromDate(date)};
  }

  OfficialHolidayEntity toEntity() {
    return OfficialHolidayEntity(id: id, name: name, date: date);
  }
}
