import 'package:hr_management_system/core/utils/app_icons.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';

enum HomeTabItem {
  home('nav.home', AppIcons.home, AppIcons.homeFilled),
  employees('nav.employees', AppIcons.employees, AppIcons.employeesFilled),
  attendance('nav.attendance', AppIcons.attendance, AppIcons.attendanceFilled),
  payroll('nav.payroll', AppIcons.payroll, AppIcons.payrollFilled),
  more('nav.more', AppIcons.more, AppIcons.moreFilled);

  const HomeTabItem(this.labelKey, this.iconPath, this.filledIconPath);

  final String labelKey;
  final String iconPath;
  final String filledIconPath;

  GroupModule? get module {
    switch (this) {
      case HomeTabItem.home:
        return null;
      case HomeTabItem.employees:
        return GroupModules.employees;
      case HomeTabItem.attendance:
        return GroupModules.attendance;
      case HomeTabItem.payroll:
        return GroupModules.payroll;
      case HomeTabItem.more:
        return null;
    }
  }
}
