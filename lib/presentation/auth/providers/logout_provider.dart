import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/presentation/auth/providers/logout_notifier.dart';

final logoutProvider = AsyncNotifierProvider<LogoutNotifier, void>(
  LogoutNotifier.new,
);
