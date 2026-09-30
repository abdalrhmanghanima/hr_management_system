import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_management_system/data/application_user/data_source/application_user_remote_data_source.dart';
import 'package:hr_management_system/data/application_user/model/application_user_model.dart';

class ApplicationUserRemoteDataSourceImpl
    implements ApplicationUserRemoteDataSource {
  static const String usersCollectionName = 'users';

  final FirebaseFirestore firestore;

  ApplicationUserRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<ApplicationUserModel>> getApplicationUsers() async {
    final snapshot = await firestore
        .collection(usersCollectionName)
        .get();

    return snapshot.docs
        .map(
          (document) => ApplicationUserModel.fromMap(
            document.id,
            document.data(),
          ),
        )
        .toList();
  }

  @override
  Future<ApplicationUserModel?> getApplicationUserByUid(String uid) async {
    if (uid.isEmpty) {
      return null;
    }

    final document = await firestore.collection(usersCollectionName).doc(uid).get();

    if (!document.exists) {
      return null;
    }

    return ApplicationUserModel.fromMap(document.id, document.data() ?? {});
  }

  @override
  Future<void> updateApplicationUser(
    ApplicationUserModel applicationUser,
  ) async {
    await firestore
        .collection(usersCollectionName)
        .doc(applicationUser.id)
        .set(
          {
            'employeeId': applicationUser.employeeId,
            'email': applicationUser.email,
            'isActive': applicationUser.isActive,
            'groupId': applicationUser.groupId ?? FieldValue.delete(),
          },
          SetOptions(merge: true),
        );
  }
}
