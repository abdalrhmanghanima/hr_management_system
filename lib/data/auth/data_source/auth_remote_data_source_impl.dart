
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hr_management_system/data/auth/data_source/auth_remote_data_source.dart';
import 'package:hr_management_system/data/auth/model/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static const String usersCollectionName = 'users';

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl(this.firebaseAuth, this.firestore);
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    return UserModel.fromFirebaseUser(uid: user.uid, email: email);
  }
  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getUserByUid(String uid) async {
    final document = await firestore
        .collection(usersCollectionName)
        .doc(uid)
        .get();
    if (!document.exists) return null;
    return UserModel.fromFirestore(document);
  }

  @override
  Future<void> updateUserGroup({
    required String uid,
    required String employeeId,
    String? groupId,
  }) async {
    await firestore.collection(usersCollectionName).doc(uid).set(
      {
        'employeeId': employeeId,
        'groupId': groupId ?? FieldValue.delete(),
      },
      SetOptions(merge: true),
    );
  }
}
