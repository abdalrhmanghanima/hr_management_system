import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';

class EmployeeScope {
  final String? _employeeId;
  final bool _denied;

  const EmployeeScope._(this._employeeId, this._denied);

  const EmployeeScope.unrestricted() : this._(null, false);

  const EmployeeScope.own(String employeeId) : this._(employeeId, false);

  const EmployeeScope.denied() : this._(null, true);

  bool get isDenied => _denied;

  bool get isOwn => !_denied && _employeeId != null;

  bool get isUnrestricted => !_denied && _employeeId == null;

  String? get employeeId => _employeeId;

  bool allows(String? candidate) {
    if (_denied) return false;
    if (_employeeId == null) return true;
    return candidate == _employeeId;
  }

  List<EmployeeEntity> applyToEmployees(List<EmployeeEntity> employees) {
    if (isUnrestricted) return employees;
    return employees.where((employee) => allows(employee.id)).toList();
  }

  List<AttendanceEntity> applyToAttendances(List<AttendanceEntity> attendances) {
    if (isUnrestricted) return attendances;
    return attendances.where((attendance) => allows(attendance.employeeId)).toList();
  }
}
