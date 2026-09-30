class GroupModule {
  final String key;
  final String label;
  final bool supportsScope;

  const GroupModule({
    required this.key,
    required this.label,
    this.supportsScope = false,
  });
}

class GroupModules {
  const GroupModules._();

  static const GroupModule employees = GroupModule(
    key: 'employees',
    label: 'Employees',
  );

  static const GroupModule attendance = GroupModule(
    key: 'attendance',
    label: 'Attendance',
    supportsScope: true,
  );

  static const GroupModule payroll = GroupModule(
    key: 'payroll',
    label: 'Payroll',
    supportsScope: true,
  );

  static const GroupModule departments = GroupModule(
    key: 'departments',
    label: 'Departments',
  );

  static const GroupModule officialHolidays = GroupModule(
    key: 'officialHolidays',
    label: 'Official Holidays',
  );

  static const GroupModule groups = GroupModule(
    key: 'groups',
    label: 'Groups & Permissions',
  );

  static const GroupModule applicationUsers = GroupModule(
    key: 'applicationUsers',
    label: 'Application Users',
  );

  static const GroupModule profile = GroupModule(key: 'profile', label: 'Profile');

  static const List<GroupModule> all = [
    employees,
    attendance,
    payroll,
    departments,
    officialHolidays,
    groups,
    applicationUsers,
    profile,
  ];

  static List<GroupModule> get withScope =>
      all.where((module) => module.supportsScope).toList();

  static GroupModule? byKey(String key) {
    for (final module in all) {
      if (module.key == key) return module;
    }
    return null;
  }
}
