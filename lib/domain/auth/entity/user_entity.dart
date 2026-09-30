class UserEntity {
  final String uid;
  final String email;
  final String? employeeId;
  final String? groupId;
  final bool isActive;

  const UserEntity({
    required this.uid,
    required this.email,
    this.employeeId,
    this.groupId,
    this.isActive = true,
  });
}
