import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDepartmentProvider =
StateProvider.autoDispose<String?>((ref) => null);