import 'dart:typed_data';

import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_file.dart';
import 'package:hr_management_system/domain/attendance_import/entity/attendance_import_sheet.dart';

abstract class AttendanceImportRepository {
  Future<AttendanceImportFile?> pickXlsxFile();

  AttendanceImportSheet parseWorkbook(Uint8List bytes);
}
