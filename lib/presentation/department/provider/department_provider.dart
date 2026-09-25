import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/department/data_source/department_remote_data_source.dart';
import 'package:hr_management_system/data/department/data_source/department_remote_data_source_impl.dart';
import 'package:hr_management_system/data/department/repository/department_repository_impl.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/domain/department/repository/department_repository.dart';
import 'package:hr_management_system/domain/department/use_case/add_department.dart';
import 'package:hr_management_system/domain/department/use_case/delete_department.dart';
import 'package:hr_management_system/domain/department/use_case/get_department_by_id.dart';
import 'package:hr_management_system/domain/department/use_case/get_departments.dart';
import 'package:hr_management_system/domain/department/use_case/update_department.dart';
import 'package:hr_management_system/presentation/department/provider/department_notifier.dart';

final departmentProvider =
AsyncNotifierProvider<DepartmentNotifier, List<DepartmentEntity>>(
  DepartmentNotifier.new,
);

final departmentRemoteDataSourceProvider =
Provider<DepartmentRemoteDataSource>((ref) {
  return DepartmentRemoteDataSourceImpl(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
});

final departmentRepositoryProvider =
Provider<DepartmentRepository>((ref) {
  return DepartmentRepositoryImpl(
    ref.read(departmentRemoteDataSourceProvider),
  );
});

final getDepartmentsUseCaseProvider =
Provider<GetDepartments>((ref) {
  return GetDepartments(
    ref.read(departmentRepositoryProvider),
  );
});

final getDepartmentByIdUseCaseProvider =
Provider<GetDepartmentById>((ref) {
  return GetDepartmentById(
    ref.read(departmentRepositoryProvider),
  );
});

final addDepartmentUseCaseProvider =
Provider<AddDepartment>((ref) {
  return AddDepartment(
    ref.read(departmentRepositoryProvider),
  );
});

final updateDepartmentUseCaseProvider =
Provider<UpdateDepartment>((ref) {
  return UpdateDepartment(
    ref.read(departmentRepositoryProvider),
  );
});

final deleteDepartmentUseCaseProvider =
Provider<DeleteDepartment>((ref) {
  return DeleteDepartment(
    ref.read(departmentRepositoryProvider),
  );
});