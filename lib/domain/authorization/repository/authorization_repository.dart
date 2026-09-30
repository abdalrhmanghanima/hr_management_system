import 'package:hr_management_system/domain/authorization/entity/authorization_entity.dart';

abstract class AuthorizationRepository {
  Future<AuthorizationEntity> load(String uid);
}
