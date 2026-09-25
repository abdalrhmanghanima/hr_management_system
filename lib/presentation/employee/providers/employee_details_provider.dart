import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';

final employeeDetailsProvider =
FutureProvider.family<EmployeeEntity, String>((ref, employeeId) {
  return ref
      .read(getEmployeeByIdUseCaseProvider)
      .call(employeeId);
});