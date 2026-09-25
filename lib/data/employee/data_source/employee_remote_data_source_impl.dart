import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_management_system/data/employee/data_source/employee_remote_data_source.dart';
import 'package:hr_management_system/data/employee/model/employee_model.dart';

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final FirebaseFirestore firestore;
  EmployeeRemoteDataSourceImpl(this.firestore);
  @override
  Future<List<EmployeeModel>> getEmployees() async {
    final snapshot = await firestore.collection('employees').get();
    return snapshot.docs
        .map((document) => EmployeeModel.fromFirestore(document))
        .toList();
  }

  @override
  Future<EmployeeModel> getEmployeeById(String id) async {
    final document = await firestore.collection('employees').doc(id).get();
    if (!document.exists) {
      throw Exception('Employee not found');
    }
    return EmployeeModel.fromFirestore(document);
  }

  @override
  Future<void> addEmployee(EmployeeModel employee) async {
    final document = firestore.collection('employees').doc(employee.id);
    await document.set(employee.toFirestore());
  }

  @override
  Future<void> updateEmployee(EmployeeModel employee) async {
    final document = firestore.collection('employees').doc(employee.id);
    await document.update(employee.toFirestore());
  }

  @override
  Future<void> deleteEmployee(String id) async {
    final document = firestore.collection('employees').doc(id);
    await document.delete();
  }
}
