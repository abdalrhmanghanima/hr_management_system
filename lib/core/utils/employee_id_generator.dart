import 'package:uuid/uuid.dart';

class EmployeeIdGenerator {
  const EmployeeIdGenerator._();

  static String generate() {
    return const Uuid().v4();
  }
}
