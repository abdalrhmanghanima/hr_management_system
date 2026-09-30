class ApplicationUserEntity {
  final String id;
  final String employeeId;
  final String email;
  final String? groupId;
  final bool isActive;

  const ApplicationUserEntity({
    required this.id,
    required this.employeeId,
    this.email = '',
    this.groupId,
    this.isActive = true,
  });

  bool get hasGroup => groupId != null && groupId!.isNotEmpty;

  ApplicationUserEntity copyWith({
    String? email,
    String? groupId,
    bool clearGroup = false,
    bool? isActive,
  }) {
    return ApplicationUserEntity(
      id: id,
      employeeId: employeeId,
      email: email ?? this.email,
      groupId: clearGroup ? null : (groupId ?? this.groupId),
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ApplicationUserEntity &&
        other.id == id &&
        other.employeeId == employeeId &&
        other.email == email &&
        other.groupId == groupId &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(id, employeeId, email, groupId, isActive);
}
