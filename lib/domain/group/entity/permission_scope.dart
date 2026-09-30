enum PermissionScope {
  own(label: 'Own', key: 'own'),
  all(label: 'All', key: 'all');

  final String label;
  final String key;

  const PermissionScope({required this.label, required this.key});

  static PermissionScope? fromKey(String? key) {
    for (final scope in PermissionScope.values) {
      if (scope.key == key) return scope;
    }
    return null;
  }
}
