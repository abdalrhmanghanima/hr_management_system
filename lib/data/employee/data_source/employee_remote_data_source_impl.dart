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
  Future<EmployeeModel?> getEmployeeByNationalId(
    String nationalId, {
    String? excludingId,
  }) async {
    final target = nationalId.trim();

    for (final employee in await getEmployees()) {
      if (excludingId != null && employee.id == excludingId) {
        continue;
      }

      if (employee.nationalId.trim() == target) {
        return employee;
      }
    }

    return null;
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

  @override
  Future<void> linkEmployeeAccount(String id, String authUid) async {
    final document = firestore.collection('employees').doc(id);
    await document.update({
      'hasAccount': true,
      'authUid': authUid,
    });
  }
}
