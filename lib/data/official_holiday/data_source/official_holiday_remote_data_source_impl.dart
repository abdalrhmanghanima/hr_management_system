import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_management_system/data/official_holiday/data_source/official_holiday_remote_data_source.dart';
import 'package:hr_management_system/data/official_holiday/model/official_holiday_model.dart';

class OfficialHolidayRemoteDataSourceImpl
    implements OfficialHolidayRemoteDataSource {
  static const String collectionName = 'official_holidays';

  final FirebaseFirestore firestore;

  OfficialHolidayRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<OfficialHolidayModel>> getOfficialHolidays() async {
    final snapshot = await firestore.collection(collectionName).get();

    return snapshot.docs
        .map((document) => OfficialHolidayModel.fromFirestore(document))
        .toList();
  }

  @override
  Future<OfficialHolidayModel?> getOfficialHolidayByNameAndDate(
    String name,
    DateTime date, {
    String? excludingId,
  }) async {
    final target = name.trim().toLowerCase();

    for (final holiday in await getOfficialHolidays()) {
      if (excludingId != null && holiday.id == excludingId) {
        continue;
      }

      if (holiday.name.trim().toLowerCase() != target) {
        continue;
      }

      if (isSameDay(holiday.date, date)) {
        return holiday;
      }
    }

    return null;
  }

  bool isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  @override
  Future<void> addOfficialHoliday(OfficialHolidayModel holiday) async {
    final document = firestore.collection(collectionName).doc(holiday.id);

    await document.set(holiday.toFirestore());
  }

  @override
  Future<void> updateOfficialHoliday(OfficialHolidayModel holiday) async {
    final document = firestore.collection(collectionName).doc(holiday.id);

    await document.update(holiday.toFirestore());
  }

  @override
  Future<void> deleteOfficialHoliday(String id) async {
    final document = firestore.collection(collectionName).doc(id);

    await document.delete();
  }
}
