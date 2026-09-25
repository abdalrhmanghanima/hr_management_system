class EmployeeEntity {
  final String id;
  final String fullName;
  final String address;
  final String phoneNumber;
  final DateTime birthDate;
  final String nationalId;
  final String nationality;
  final String gender;
  final String departmentId;
  final DateTime contractDate;
  final double salary;

  const EmployeeEntity({
    required this.id,
    required this.fullName,
    required this.address,
    required this.phoneNumber,
    required this.birthDate,
    required this.nationalId,
    required this.nationality,
    required this.gender,
    required this.departmentId,
    required this.contractDate,
    required this.salary,
  });
}