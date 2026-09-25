import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';

class DepartmentModel extends DepartmentEntity {
  const DepartmentModel({
    required super.id,
    required super.name,
  });

  factory DepartmentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data()!;

    return DepartmentModel(
      id: document.id,
      name: data['name'] as String? ?? '',
    );
  }

  factory DepartmentModel.fromEntity(DepartmentEntity department) {
    return DepartmentModel(
      id: department.id,
      name: department.name,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}