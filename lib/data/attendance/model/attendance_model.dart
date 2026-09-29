import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.employeeId,
    required super.attendanceDate,
    required super.status,
    super.checkInTime,
    super.checkOutTime,
  });

  factory AttendanceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return AttendanceModel(
      id: document.id,
      employeeId: data['employeeId'] as String,
      attendanceDate: (data['attendanceDate'] as Timestamp).toDate(),
      status: data['status'] as String,
      checkInTime: (data['checkInTime'] as Timestamp?)?.toDate(),
      checkOutTime: (data['checkOutTime'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'attendanceDate': Timestamp.fromDate(attendanceDate),
      'status': status,
      if (checkInTime != null) 'checkInTime': Timestamp.fromDate(checkInTime!),
      if (checkOutTime != null)
        'checkOutTime': Timestamp.fromDate(checkOutTime!),
    };
  }

  AttendanceEntity toEntity() {
    return AttendanceEntity(
      id: id,
      employeeId: employeeId,
      attendanceDate: attendanceDate,
      status: status,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
    );
  }
}
