import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';

class EmployeeModel extends EmployeeEntity {
  const EmployeeModel({
    required super.id,
    required super.fullName,
    required super.address,
    required super.phoneNumber,
    required super.birthDate,
    required super.nationalId,
    required super.nationality,
    required super.gender,
    required super.departmentId,
    required super.contractDate,
    required super.salary,
  });

  factory EmployeeModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;

    return EmployeeModel(
      id: doc.id,
      fullName: data['fullName'] as String? ?? '',
      address: data['address'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      nationalId: data['nationalId'] as String? ?? '',
      nationality: data['nationality'] as String? ?? '',
      gender: data['gender'] as String? ?? '',
      departmentId: data['departmentId'] as String? ?? '',
      contractDate: (data['contractDate'] as Timestamp).toDate(),
      salary: (data['salary'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'address': address,
      'phoneNumber': phoneNumber,
      'birthDate': Timestamp.fromDate(birthDate),
      'nationalId': nationalId,
      'nationality': nationality,
      'gender': gender,
      'departmentId': departmentId,
      'contractDate': Timestamp.fromDate(contractDate),
      'salary': salary,
    };
  }
  factory EmployeeModel.fromEntity(EmployeeEntity employee) {
    return EmployeeModel(
      id: employee.id,
      fullName: employee.fullName,
      address: employee.address,
      phoneNumber: employee.phoneNumber,
      birthDate: employee.birthDate,
      nationalId: employee.nationalId,
      nationality: employee.nationality,
      gender: employee.gender,
      departmentId: employee.departmentId,
      contractDate: employee.contractDate,
      salary: employee.salary,
    );
  }
}