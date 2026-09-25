import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hr_management_system/data/department/data_source/department_remote_data_source.dart';
import 'package:hr_management_system/data/department/model/department_model.dart';

class DepartmentRemoteDataSourceImpl
    implements DepartmentRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  DepartmentRemoteDataSourceImpl(
      this.auth,
      this.firestore,
      );

  @override
  Future<List<DepartmentModel>> getDepartments() async {
    final snapshot = await firestore.collection('departments').get();

    return snapshot.docs
        .map((document) => DepartmentModel.fromFirestore(document))
        .toList();
  }

  @override
  Future<DepartmentModel> getDepartmentById(String id) async {
    final document =
    await firestore.collection('departments').doc(id).get();

    if (!document.exists) {
      throw Exception('Department not found');
    }

    return DepartmentModel.fromFirestore(document);
  }

  @override
  Future<void> addDepartment(DepartmentModel department) async {
    final document =
    firestore.collection('departments').doc(department.id);

    await document.set(department.toFirestore());
  }

  @override
  Future<void> updateDepartment(DepartmentModel department) async {
    final document =
    firestore.collection('departments').doc(department.id);

    await document.update(department.toFirestore());
  }

  @override
  Future<void> deleteDepartment(String id) async {
    final document =
    firestore.collection('departments').doc(id);

    await document.delete();
  }
}