import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_management_system/data/group/data_source/group_remote_data_source.dart';
import 'package:hr_management_system/data/group/model/group_model.dart';

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  static const String collectionName = 'groups';

  final FirebaseFirestore firestore;

  GroupRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<GroupModel>> getGroups() async {
    final snapshot = await firestore.collection(collectionName).get();
    return snapshot.docs.map(GroupModel.fromFirestore).toList();
  }

  @override
  Future<GroupModel?> getGroupById(String id) async {
    final document = await firestore.collection(collectionName).doc(id).get();
    if (!document.exists) return null;
    return GroupModel.fromFirestore(document);
  }

  @override
  Future<GroupModel?> getGroupByName(String name, {String? excludingId}) async {
    final groups = await getGroups();
    final target = name.trim().toLowerCase();

    for (final group in groups) {
      if (group.id == excludingId) continue;
      if (group.name.trim().toLowerCase() == target) return group;
    }
    return null;
  }

  @override
  Future<void> addGroup(GroupModel group) async {
    await firestore
        .collection(collectionName)
        .doc(group.id)
        .set(group.toFirestore());
  }

  @override
  Future<void> updateGroup(GroupModel group) async {
    await firestore
        .collection(collectionName)
        .doc(group.id)
        .set(group.toFirestore());
  }

  @override
  Future<void> deleteGroup(String id) async {
    await firestore.collection(collectionName).doc(id).delete();
  }

  @override
  Future<void> setGroupMembers(String groupId, List<String> employeeIds) async {
    await firestore
        .collection(collectionName)
        .doc(groupId)
        .update({'employeeIds': employeeIds});
  }
}
