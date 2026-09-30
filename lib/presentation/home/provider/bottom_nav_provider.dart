import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/home/tabs/home_tab_item.dart';

const List<HomeTabItem> alwaysVisibleHomeTabs = [
  HomeTabItem.home,
  HomeTabItem.more,
];

final currentHomeTabProvider = StateProvider<HomeTabItem>((ref) {
  return HomeTabItem.home;
});

final visibleHomeTabsProvider = Provider<List<HomeTabItem>>((ref) {
  final authorization = ref.watch(authorizationEntityProvider);

  if (!authorization.isResolved) {
    return alwaysVisibleHomeTabs;
  }

  final checker = ref.watch(permissionCheckerProvider);

  final tabs = HomeTabItem.values.where((tab) {
    final module = tab.module;

    if (module == null) return true;

    return checker.canView(module);
  }).toList();

  if (tabs.length < alwaysVisibleHomeTabs.length) {
    return alwaysVisibleHomeTabs;
  }

  return tabs;
});
