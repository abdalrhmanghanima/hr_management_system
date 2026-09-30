import 'package:hr_management_system/domain/authorization/service/module_access.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';

final moduleAccessProvider = Provider.family<ModuleAccess, GroupModule>((
  ref,
  module,
) {
  final checker = ref.watch(permissionCheckerProvider);

  return ModuleAccess(
    scope: checker.employeeScopeFor(module),
    canAdd: checker.canAdd(module),
    canEdit: checker.canEdit(module),
    canDelete: checker.canDelete(module),
  );
});
