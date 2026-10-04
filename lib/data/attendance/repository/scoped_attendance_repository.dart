import 'package:flutter/foundation.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance/repository/attendance_repository.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_exception.dart';
import 'package:hr_management_system/domain/authorization/service/module_access.dart';

class ScopedAttendanceRepository implements AttendanceRepository {
  final AttendanceRepository repository;
  final ModuleAccess access;

  ScopedAttendanceRepository({
    required this.repository,
    required this.access,
  });

  @override
  Future<List<AttendanceEntity>> getAttendances() async {
    final scope = access.scope;

    // TODO(hr-session-diagnostics): temporary debug logging.
    debugPrint(
      '[ATTENDANCE-RELOGIN] scopedRepo.isDenied=${scope.isDenied} '
      'isOwn=${scope.isOwn} employeeId=${scope.employeeId ?? '<null>'} '
      'canAdd=${access.canAdd}',
    );

    if (scope.isDenied) {
      // TODO(hr-session-diagnostics): temporary debug logging.
      debugPrint('[hr-session] attendance.scope denied -> 0 docs (no firestore query)');
      debugPrint('[ATTENDANCE-RELOGIN] DENIED -> returns [] WITHOUT firestore query');

      return const [];
    }

    final records = await (scope.isOwn
        ? repository.getAttendancesByEmployeeId(scope.employeeId!)
        : repository.getAttendances());

    // TODO(hr-session-diagnostics): temporary debug logging.
    debugPrint('[hr-session] attendance.scope own=${scope.isOwn} firestore docs=${records.length}');
    debugPrint(
      '[ATTENDANCE-RELOGIN] scopedRepo returned ${records.length} records '
      'firstId=${records.isEmpty ? '<none>' : records.first.id}',
    );

    return records;
  }

  @override
  Future<List<AttendanceEntity>> getAttendancesByEmployeeId(
    String employeeId,
  ) async {
    final scope = access.scope;

    if (!scope.allows(employeeId)) return const [];

    return repository.getAttendancesByEmployeeId(employeeId);
  }

  @override
  Future<AttendanceEntity?> getAttendanceByEmployeeAndDate(
    String employeeId,
    DateTime date,
  ) async {
    final scope = access.scope;

    if (!scope.allows(employeeId)) return null;

    return repository.getAttendanceByEmployeeAndDate(employeeId, date);
  }

  @override
  Future<void> addAttendance(AttendanceEntity attendance) async {
    _requireWrite(access.canAdd, 'add attendance records');

    if (!access.scope.allows(attendance.employeeId)) {
      throw const AuthorizationException(
        'You can only add attendance records for yourself.',
      );
    }

    await repository.addAttendance(attendance);
  }

  @override
  Future<void> updateAttendance(AttendanceEntity attendance) async {
    _requireWrite(access.canEdit, 'edit attendance records');

    if (!access.scope.allows(attendance.employeeId)) {
      throw const AuthorizationException(
        'You can only edit attendance records for yourself.',
      );
    }

    await repository.updateAttendance(attendance);
  }

  @override
  Future<void> deleteAttendance(String id) async {
    _requireWrite(access.canDelete, 'delete attendance records');

    if (access.scope.isOwn) {
      throw const AuthorizationException(
        'Attendance records cannot be deleted with own scope access.',
      );
    }

    await repository.deleteAttendance(id);
  }

  void _requireWrite(bool granted, String action) {
    if (granted) return;

    throw AuthorizationException('You are not allowed to $action.');
  }
}
