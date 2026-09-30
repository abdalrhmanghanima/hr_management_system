import 'package:hr_management_system/domain/authorization/entity/authorization_entity.dart';
import 'package:hr_management_system/domain/authorization/service/employee_scope.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/permission_scope.dart';

class PermissionChecker {
  const PermissionChecker(this.authorization);

  final AuthorizationEntity authorization;

  bool get isResolved => authorization.isResolved;

  String? get employeeId => authorization.employeeId;

  String? get groupId => authorization.groupId;

  bool canView(GroupModule module) => authorization.canView(module);

  bool canAdd(GroupModule module) => authorization.canAdd(module);

  bool canEdit(GroupModule module) => authorization.canEdit(module);

  bool canDelete(GroupModule module) => authorization.canDelete(module);

  PermissionScope scope(GroupModule module) => authorization.scopeOf(module);

  bool isOwnScope(GroupModule module) => authorization.isOwnScope(module);

  bool isAllScope(GroupModule module) => authorization.isAllScope(module);

  EmployeeScope employeeScopeFor(GroupModule module) {
    if (!canView(module)) return const EmployeeScope.denied();

    if (!module.supportsScope) return const EmployeeScope.unrestricted();

    if (isAllScope(module)) return const EmployeeScope.unrestricted();

    final employeeId = authorization.employeeId;
    if (employeeId == null || employeeId.isEmpty) {
      return const EmployeeScope.denied();
    }

    return EmployeeScope.own(employeeId);
  }
}
