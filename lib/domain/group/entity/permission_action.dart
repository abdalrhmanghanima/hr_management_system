enum PermissionAction {
  view(label: 'View', key: 'view'),
  add(label: 'Add', key: 'add'),
  edit(label: 'Edit', key: 'edit'),
  delete(label: 'Delete', key: 'delete');

  final String label;
  final String key;

  const PermissionAction({required this.label, required this.key});
}
