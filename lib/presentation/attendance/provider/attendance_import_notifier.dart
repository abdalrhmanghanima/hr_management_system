import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/enums/attendance_import_status.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_exception.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_file.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_stage.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_summary.dart';
import 'package:hr_management_system/domain/attendance_import/use_case/import_attendance_use_case.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_import_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/today_attendance_provider.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';

class AttendanceImportState {
  final AttendanceImportStatus status;
  final AttendanceImportFile? file;
  final AttendanceImportSummary? summary;
  final String? message;

  const AttendanceImportState({
    this.status = AttendanceImportStatus.idle,
    this.file,
    this.summary,
    this.message,
  });

  bool get isBusy {
    return status == AttendanceImportStatus.selectingFile ||
        status == AttendanceImportStatus.parsing ||
        status == AttendanceImportStatus.importing;
  }

  AttendanceImportState copyWith({
    AttendanceImportStatus? status,
    AttendanceImportFile? file,
    AttendanceImportSummary? summary,
    String? message,
  }) {
    return AttendanceImportState(
      status: status ?? this.status,
      file: file ?? this.file,
      summary: summary ?? this.summary,
      message: message ?? this.message,
    );
  }
}

class AttendanceImportNotifier extends Notifier<AttendanceImportState> {
  @override
  AttendanceImportState build() {
    return const AttendanceImportState();
  }

  Future<void> selectFile() async {
    state = state.copyWith(status: AttendanceImportStatus.selectingFile);

    try {
      final file = await ref
          .read(attendanceImportRepositoryProvider)
          .pickXlsxFile();

      if (file == null) {
        state = state.copyWith(status: AttendanceImportStatus.idle);
        return;
      }

      state = AttendanceImportState(
        status: AttendanceImportStatus.idle,
        file: file,
      );
    } catch (error) {
      state = state.copyWith(
        status: AttendanceImportStatus.error,
        message: _messageOf(error),
      );
    }
  }

  void removeFile() {
    state = const AttendanceImportState();
  }

  Future<AttendanceImportSummary?> importAttendance() async {
    final file = state.file;

    if (file == null || state.isBusy) {
      return null;
    }

    state = state.copyWith(status: AttendanceImportStatus.parsing);

    await Future<void>.delayed(Duration.zero);

    AttendanceImportSummary summary;

    try {
      final useCase = ImportAttendanceUseCase(
        attendanceRepository: ref.read(attendanceRepositoryProvider),
        employeeRepository: ref.read(employeeRepositoryProvider),
        departmentRepository: ref.read(departmentRepositoryProvider),
        importRepository: ref.read(attendanceImportRepositoryProvider),
        onStage: _handleStage,
      );

      summary = await useCase.call(file);
    } catch (error) {
      state = state.copyWith(
        status: AttendanceImportStatus.error,
        message: _messageOf(error),
      );

      return null;
    }

    await ref.read(employeeProvider.notifier).getEmployees();
    await ref.read(attendanceProvider.notifier).getAttendances();
    ref.invalidate(todayAttendanceProvider);

    state = AttendanceImportState(
      status: summary.hasFailures
          ? AttendanceImportStatus.partialSuccess
          : AttendanceImportStatus.success,
      file: file,
      summary: summary,
    );

    return summary;
  }

  void _handleStage(AttendanceImportStage stage) {
    if (stage != AttendanceImportStage.importing) {
      return;
    }

    state = state.copyWith(status: AttendanceImportStatus.importing);
  }

  void clearResult() {
    state = const AttendanceImportState();
  }

  String _messageOf(Object error) {
    if (error is AttendanceImportException) {
      return error.message;
    }

    return 'Failed to import attendance. Please try again';
  }
}
