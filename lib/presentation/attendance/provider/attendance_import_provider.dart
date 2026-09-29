import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/attendance_import/repository/attendance_import_repository_impl.dart';
import 'package:hr_management_system/domain/attendance_import/repository/attendance_import_repository.dart';
import 'package:hr_management_system/domain/attendance_import/use_case/import_attendance_use_case.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_import_notifier.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';

final attendanceImportRepositoryProvider = Provider<AttendanceImportRepository>(
  (ref) {
    return AttendanceImportRepositoryImpl();
  },
);

final importAttendanceUseCaseProvider = Provider<ImportAttendanceUseCase>((
  ref,
) {
  return ImportAttendanceUseCase(
    attendanceRepository: ref.read(attendanceRepositoryProvider),
    employeeRepository: ref.read(employeeRepositoryProvider),
    departmentRepository: ref.read(departmentRepositoryProvider),
    importRepository: ref.read(attendanceImportRepositoryProvider),
  );
});

final attendanceImportProvider =
    NotifierProvider<AttendanceImportNotifier, AttendanceImportState>(
      AttendanceImportNotifier.new,
    );
