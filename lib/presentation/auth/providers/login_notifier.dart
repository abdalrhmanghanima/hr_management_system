import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/auth/data_source/auth_remote_data_source.dart';
import 'package:hr_management_system/data/auth/data_source/auth_remote_data_source_impl.dart';
import 'package:hr_management_system/data/auth/repository/auth_repo_impl.dart';
import 'package:hr_management_system/domain/auth/entity/user_entity.dart';
import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';
import 'package:hr_management_system/domain/auth/use_case/login_use_case.dart';
import 'package:hr_management_system/domain/auth/use_case/update_user_group.dart';
import 'package:hr_management_system/presentation/application_user/provider/application_user_provider.dart';

class LoginNotifier extends AsyncNotifier<UserEntity?>{
  @override
  Future<UserEntity?> build() async{
    return null;
  }
  Future<void> login({required String email, required String password})async{
   state = const AsyncLoading();
   state = await AsyncValue.guard(() async {
     final user = await ref
         .read(loginUseCaseProvider)
         .call(email: email, password: password);

     await ref
         .read(validateApplicationUserUseCaseProvider)
         .call(user.uid);

     return user;
   });
  }
}
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});
final authRemoteDataProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    ref.read(firebaseAuthProvider),
    ref.read(firestoreProvider),
  );
});
final authRepoProvider = Provider<AuthRepo>((ref) {
  return AuthRepoImpl(ref.read(authRemoteDataProvider));
});
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepoProvider));
});
final updateUserGroupProvider = Provider<UpdateUserGroup>((ref) {
  return UpdateUserGroup(ref.read(authRepoProvider));
});