import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_management_system/data/attendance/data_source/attendance_remote_data_source.dart';
import 'package:hr_management_system/data/attendance/model/attendance_model.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  static const String collectionName = 'attendance';

  final FirebaseFirestore firestore;
  AttendanceRemoteDataSourceImpl(this.firestore);
  @override
  Future<List<AttendanceModel>> getAttendances() async {
    final snapshot = await firestore.collection(collectionName).get();
    return snapshot.docs
        .map((document) => AttendanceModel.fromFirestore(document))
        .toList();
  }

  @override
  Future<void> addAttendance(AttendanceModel attendance) async {
    final document = firestore.collection(collectionName).doc(attendance.id);
    await document.set(attendance.toFirestore());
  }

  @override
  Future<void> updateAttendance(AttendanceModel attendance) async {
    final document = firestore.collection(collectionName).doc(attendance.id);
    await document.update(attendance.toFirestore());
  }

  @override
  Future<void> deleteAttendance(String id) async {
    final document = firestore.collection(collectionName).doc(id);
    await document.delete();
  }

  @override
  Future<List<AttendanceModel>> getAttendancesByEmployeeId(
    String employeeId,
  ) async {
    final snapshot = await firestore
        .collection(collectionName)
        .where('employeeId', isEqualTo: employeeId)
        .get();
    return snapshot.docs
        .map((document) => AttendanceModel.fromFirestore(document))
        .toList();
  }

  @override
  Future<AttendanceModel?> getAttendanceByEmployeeAndDate(
    String employeeId,
    DateTime date,
  ) async {
    final deterministicDocument = await firestore
        .collection(collectionName)
        .doc(AttendanceEntity.documentIdFor(employeeId, date))
        .get();

    if (deterministicDocument.exists) {
      return AttendanceModel.fromFirestore(deterministicDocument);
    }

    final legacySnapshot = await firestore
        .collection(collectionName)
        .where('employeeId', isEqualTo: employeeId)
        .get();

    for (final document in legacySnapshot.docs) {
      final attendance = AttendanceModel.fromFirestore(document);

      if (isSameDay(attendance.attendanceDate, date)) {
        return attendance;
      }
    }

    return null;
  }

  bool isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
