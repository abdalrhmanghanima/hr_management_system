import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';

final departmentByIdProvider =
FutureProvider.family<DepartmentEntity, String>((ref, departmentId) {
  return ref
      .read(getDepartmentByIdUseCaseProvider)
      .call(departmentId);
});