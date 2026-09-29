class AttendanceImportColumns {
  static const String employeeId = 'employeeId';

  static const String nationalId = 'nationalId';

  static const String employeeName = 'employeeName';

  static const String address = 'address';

  static const String phoneNumber = 'phoneNumber';

  static const String birthDate = 'birthDate';

  static const String gender = 'gender';

  static const String nationality = 'nationality';

  static const String departmentId = 'departmentId';

  static const String departmentName = 'departmentName';

  static const String contractDate = 'contractDate';

  static const String salary = 'salary';

  static const String attendanceDate = 'attendanceDate';

  static const String checkIn = 'checkIn';

  static const String checkOut = 'checkOut';
}

class AttendanceImportSheet {
  final Map<String, int> columnIndexes;
  final List<AttendanceImportSheetRow> rows;

  const AttendanceImportSheet({
    required this.columnIndexes,
    required this.rows,
  });

  int? indexOf(String column) {
    return columnIndexes[column];
  }

  bool has(String column) {
    return columnIndexes.containsKey(column);
  }
}

class AttendanceImportSheetRow {
  final int rowNumber;
  final List<Object?> values;

  const AttendanceImportSheetRow({
    required this.rowNumber,
    required this.values,
  });

  Object? valueAt(int? index) {
    if (index == null || index < 0 || index >= values.length) {
      return null;
    }

    return values[index];
  }
}
