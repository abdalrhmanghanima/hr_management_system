import 'package:hr_management_system/domain/authorization/entity/authorization_entity.dart';
import 'package:hr_management_system/domain/authorization/repository/authorization_repository.dart';

class LoadAuthorization {
  const LoadAuthorization(this.repository);

  final AuthorizationRepository repository;

  Future<AuthorizationEntity> call(String uid) {
    return repository.load(uid);
  }
}
