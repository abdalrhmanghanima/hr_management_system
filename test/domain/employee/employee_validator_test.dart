import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/domain/employee/validation/employee_validator.dart';

void main() {
  group('EmployeeValidator contract date', () {
    test('a contract date before the company start year is rejected', () {
      expect(
        EmployeeValidator.contractDate(DateTime(2007, 12, 31)),
        'validation.employee.contract_date_before_start',
      );
    });

    test('the company start year itself is accepted', () {
      expect(EmployeeValidator.contractDate(DateTime(2008, 1, 1)), isNull);
    });

    test('a missing contract date is rejected', () {
      expect(
        EmployeeValidator.contractDate(null),
        'validation.employee.contract_date_required',
      );
    });

    test('a display contract date before 2008 is rejected', () {
      expect(
        EmployeeValidator.contractDateText('01/01/2007'),
        'validation.employee.contract_date_before_start',
      );
    });

    test('a valid display contract date is accepted', () {
      expect(EmployeeValidator.contractDateText('01/01/2020'), isNull);
    });

    test('a malformed display contract date is rejected', () {
      expect(
        EmployeeValidator.contractDateText('01/13/2020'),
        'validation.date_invalid',
      );
    });
  });
}
