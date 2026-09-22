import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/domain/auth/entity/user_entity.dart';
import 'package:hr_management_system/presentation/auth/providers/login_notifier.dart';

final loginProvider =
AsyncNotifierProvider<LoginNotifier, UserEntity?>(
  LoginNotifier.new,
);