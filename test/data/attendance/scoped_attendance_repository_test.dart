import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/data/attendance/repository/scoped_attendance_repository.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance/repository/attendance_repository.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_exception.dart';
import 'package:hr_management_system/domain/authorization/service/employee_scope.dart';
import 'package:hr_management_system/domain/authorization/service/module_access.dart';

class _FakeAttendanceRepository implements AttendanceRepository {
  final List<AttendanceEntity> attendances;

  _FakeAttendanceRepository([List<AttendanceEntity>? attendances])
    : attendances = [...?attendances];

  int getAllCallCount = 0;
  int getByEmployeeCallCount = 0;
  int addCallCount = 0;
  int updateCallCount = 0;
  int deleteCallCount = 0;

  @override
  Future<List<AttendanceEntity>> getAttendances() async {
    getAllCallCount++;

    return List.of(attendances);
  }

  @override
  Future<List<AttendanceEntity>> getAttendancesByEmployeeId(
    String employeeId,
  ) async {
    getByEmployeeCallCount++;

    return attendances
        .where((attendance) => attendance.employeeId == employeeId)
        .toList();
  }

  @override
  Future<AttendanceEntity?> getAttendanceByEmployeeAndDate(
    String employeeId,
    DateTime date,
  ) async {
    for (final attendance in attendances) {
      final isSameDay =
          attendance.attendanceDate.year == date.year &&
          attendance.attendanceDate.month == date.month &&
          attendance.attendanceDate.day == date.day;

      if (attendance.employeeId == employeeId && isSameDay) {
        return attendance;
      }
    }

    return null;
  }

  @override
  Future<void> addAttendance(AttendanceEntity attendance) async {
    addCallCount++;
    attendances.add(attendance);
  }

  @override
  Future<void> updateAttendance(AttendanceEntity attendance) async {
    updateCallCount++;

    final index = attendances.indexWhere((item) => item.id == attendance.id);

    if (index != -1) attendances[index] = attendance;
  }

  @override
  Future<void> deleteAttendance(String id) async {
    deleteCallCount++;
    attendances.removeWhere((attendance) => attendance.id == id);
  }
}

AttendanceEntity _attendance(String id, String employeeId) {
  return AttendanceEntity(
    id: id,
    employeeId: employeeId,
    attendanceDate: DateTime(2026, 1, 1),
    status: AttendanceEntity.presentStatus,
  );
}

void main() {
  late _FakeAttendanceRepository inner;

  setUp(() {
    inner = _FakeAttendanceRepository([
      _attendance('a-1', 'employee-1'),
      _attendance('a-2', 'employee-2'),
    ]);
  });

  ScopedAttendanceRepository scoped(ModuleAccess access) {
    return ScopedAttendanceRepository(repository: inner, access: access);
  }

  group('ScopedAttendanceRepository reads', () {
    test('all scope reads every attendance', () async {
      final result = await scoped(
        const ModuleAccess(scope: EmployeeScope.unrestricted()),
      ).getAttendances();

      expect(result, hasLength(2));
      expect(inner.getAllCallCount, 1);
      expect(inner.getByEmployeeCallCount, 0);
    });

    test('own scope reads only the current employee', () async {
      final result = await scoped(
        const ModuleAccess(scope: EmployeeScope.own('employee-1')),
      ).getAttendances();

      expect(result, hasLength(1));
      expect(result.single.employeeId, 'employee-1');
      expect(inner.getAllCallCount, 0);
      expect(inner.getByEmployeeCallCount, 1);
    });

    test('denied scope returns no data without querying', () async {
      final result = await scoped(const ModuleAccess.denied()).getAttendances();

      expect(result, isEmpty);
      expect(inner.getAllCallCount, 0);
      expect(inner.getByEmployeeCallCount, 0);
    });

    test('own scope rejects reading another employee', () async {
      final result = await scoped(
        const ModuleAccess(scope: EmployeeScope.own('employee-1')),
      ).getAttendancesByEmployeeId('employee-2');

      expect(result, isEmpty);
      expect(inner.getByEmployeeCallCount, 0);
    });

    test('all scope allows reading any employee', () async {
      final result = await scoped(
        const ModuleAccess(scope: EmployeeScope.unrestricted()),
      ).getAttendancesByEmployeeId('employee-2');

      expect(result, hasLength(1));
    });

    test('own scope returns null for another employee date lookup', () async {
      final result = await scoped(
        const ModuleAccess(scope: EmployeeScope.own('employee-1')),
      ).getAttendanceByEmployeeAndDate('employee-2', DateTime(2026, 1, 1));

      expect(result, isNull);
    });

    test('own scope returns the record for the current employee', () async {
      final result = await scoped(
        const ModuleAccess(scope: EmployeeScope.own('employee-1')),
      ).getAttendanceByEmployeeAndDate('employee-1', DateTime(2026, 1, 1));

      expect(result?.id, 'a-1');
    });
  });

  group('ScopedAttendanceRepository writes', () {
    test('add requires the add permission', () async {
      await expectLater(
        scoped(
          const ModuleAccess(
            scope: EmployeeScope.unrestricted(),
            canAdd: false,
          ),
        ).addAttendance(_attendance('a-3', 'employee-1')),
        throwsA(isA<AuthorizationException>()),
      );

      expect(inner.addCallCount, 0);
    });

    test('own scope cannot add records for another employee', () async {
      await expectLater(
        scoped(
          const ModuleAccess(
            scope: EmployeeScope.own('employee-1'),
            canAdd: true,
          ),
        ).addAttendance(_attendance('a-3', 'employee-2')),
        throwsA(isA<AuthorizationException>()),
      );

      expect(inner.addCallCount, 0);
    });

    test('own scope can add records for itself', () async {
      await scoped(
        const ModuleAccess(
          scope: EmployeeScope.own('employee-1'),
          canAdd: true,
        ),
      ).addAttendance(_attendance('a-3', 'employee-1'));

      expect(inner.addCallCount, 1);
    });

    test('update requires the edit permission', () async {
      await expectLater(
        scoped(
          const ModuleAccess(
            scope: EmployeeScope.unrestricted(),
            canEdit: false,
          ),
        ).updateAttendance(_attendance('a-1', 'employee-1')),
        throwsA(isA<AuthorizationException>()),
      );

      expect(inner.updateCallCount, 0);
    });

    test('own scope cannot update another employee record', () async {
      await expectLater(
        scoped(
          const ModuleAccess(
            scope: EmployeeScope.own('employee-1'),
            canEdit: true,
          ),
        ).updateAttendance(_attendance('a-2', 'employee-2')),
        throwsA(isA<AuthorizationException>()),
      );

      expect(inner.updateCallCount, 0);
    });

    test('delete is denied with own scope even when permitted', () async {
      await expectLater(
        scoped(
          const ModuleAccess(
            scope: EmployeeScope.own('employee-1'),
            canDelete: true,
          ),
        ).deleteAttendance('a-1'),
        throwsA(isA<AuthorizationException>()),
      );

      expect(inner.deleteCallCount, 0);
    });

    test('delete requires the delete permission', () async {
      await expectLater(
        scoped(
          const ModuleAccess(
            scope: EmployeeScope.unrestricted(),
            canDelete: false,
          ),
        ).deleteAttendance('a-1'),
        throwsA(isA<AuthorizationException>()),
      );

      expect(inner.deleteCallCount, 0);
    });

    test('all scope with delete permission removes the record', () async {
      await scoped(
        const ModuleAccess(
          scope: EmployeeScope.unrestricted(),
          canDelete: true,
        ),
      ).deleteAttendance('a-1');

      expect(inner.deleteCallCount, 1);
      expect(inner.attendances, hasLength(1));
    });
  });
}
