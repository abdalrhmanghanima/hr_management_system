import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/attendance/data_source/attendance_remote_data_source.dart';
import 'package:hr_management_system/data/attendance/data_source/attendance_remote_data_source_impl.dart';
import 'package:hr_management_system/data/attendance/repository/attendance_repository_impl.dart';
import 'package:hr_management_system/data/attendance/repository/scoped_attendance_repository.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance/repository/attendance_repository.dart';
import 'package:hr_management_system/domain/attendance/use_case/add_attendance_use_case.dart';
import 'package:hr_management_system/domain/attendance/use_case/calculate_attendance_hours_use_case.dart';
import 'package:hr_management_system/domain/attendance/use_case/delete_attendance_use_case.dart';
import 'package:hr_management_system/domain/attendance/use_case/get_attendance_by_employee_and_date_use_case.dart';
import 'package:hr_management_system/domain/attendance/use_case/get_attendances_by_employee_id_use_case.dart';
import 'package:hr_management_system/domain/attendance/use_case/get_attendances_use_case.dart';
import 'package:hr_management_system/domain/attendance/use_case/update_attendance_use_case.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_notifier.dart';
import 'package:hr_management_system/presentation/authorization/provider/module_access_provider.dart';

final attendanceProvider =
    AsyncNotifierProvider<AttendanceNotifier, List<AttendanceEntity>>(
      AttendanceNotifier.new,
    );

final attendanceRemoteDataSourceProvider = Provider<AttendanceRemoteDataSource>(
  (ref) {
    return AttendanceRemoteDataSourceImpl(FirebaseFirestore.instance);
  },
);

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final repository = AttendanceRepositoryImpl(
    ref.read(attendanceRemoteDataSourceProvider),
  );

  return ScopedAttendanceRepository(
    repository: repository,
    access: ref.watch(moduleAccessProvider(GroupModules.attendance)),
  );
});

final getAttendancesUseCaseProvider = Provider<GetAttendancesUseCase>((ref) {
  return GetAttendancesUseCase(ref.watch(attendanceRepositoryProvider));
});

final getAttendancesByEmployeeIdUseCaseProvider =
    Provider<GetAttendancesByEmployeeIdUseCase>((ref) {
      return GetAttendancesByEmployeeIdUseCase(
        ref.watch(attendanceRepositoryProvider),
      );
    });

final getAttendanceByEmployeeAndDateUseCaseProvider =
    Provider<GetAttendanceByEmployeeAndDateUseCase>((ref) {
      return GetAttendanceByEmployeeAndDateUseCase(
        ref.watch(attendanceRepositoryProvider),
      );
    });

final addAttendanceUseCaseProvider = Provider<AddAttendanceUseCase>((ref) {
  return AddAttendanceUseCase(ref.watch(attendanceRepositoryProvider));
});

final updateAttendanceUseCaseProvider = Provider<UpdateAttendanceUseCase>((
  ref,
) {
  return UpdateAttendanceUseCase(ref.watch(attendanceRepositoryProvider));
});

final deleteAttendanceUseCaseProvider = Provider<DeleteAttendanceUseCase>((
  ref,
) {
  return DeleteAttendanceUseCase(ref.watch(attendanceRepositoryProvider));
});

final calculateAttendanceHoursUseCaseProvider =
    Provider<CalculateAttendanceHoursUseCase>((ref) {
      return CalculateAttendanceHoursUseCase();
    });
