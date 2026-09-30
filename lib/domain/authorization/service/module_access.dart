import 'package:hr_management_system/domain/authorization/service/employee_scope.dart';

class ModuleAccess {
  final EmployeeScope scope;
  final bool canAdd;
  final bool canEdit;
  final bool canDelete;

  const ModuleAccess({
    required this.scope,
    this.canAdd = false,
    this.canEdit = false,
    this.canDelete = false,
  });

  const ModuleAccess.denied() : this(scope: const EmployeeScope.denied());

  bool get isDenied => scope.isDenied;
}
