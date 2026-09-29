import 'dart:typed_data';

class AttendanceImportFile {
  final String name;
  final Uint8List bytes;

  const AttendanceImportFile({required this.name, required this.bytes});
}
