enum AttendanceImportRowStatus { imported, updated, skipped, failed }

class AttendanceImportRowIssue {
  final int rowNumber;
  final String reason;

  const AttendanceImportRowIssue({
    required this.rowNumber,
    required this.reason,
  });
}

class AttendanceImportSummary {
  final int totalRows;
  final int added;
  final int updated;
  final int skipped;
  final int failed;
  final int employeesCreated;
  final int existingEmployeesUsed;
  final List<AttendanceImportRowIssue> issues;

  const AttendanceImportSummary({
    required this.totalRows,
    required this.added,
    required this.updated,
    required this.skipped,
    required this.failed,
    required this.employeesCreated,
    required this.existingEmployeesUsed,
    required this.issues,
  });

  int get attendanceAdded {
    return added;
  }

  int get attendanceUpdated {
    return updated;
  }

  bool get hasFailures {
    return failed > 0;
  }
}
