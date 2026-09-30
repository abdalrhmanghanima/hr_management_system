import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/data/application_user/model/application_user_model.dart';

void main() {
  group('application user document parsing', () {
    test('reads a complete document', () {
      final model = ApplicationUserModel.fromMap('uid-1', {
        'employeeId': 'EMP999',
        'email': 'pioneershr@gmail.com',
        'groupId': 'management',
        'isActive': true,
      });

      expect(model.id, 'uid-1');
      expect(model.employeeId, 'EMP999');
      expect(model.email, 'pioneershr@gmail.com');
      expect(model.groupId, 'management');
      expect(model.isActive, isTrue);
    });

    test('an absent group is read as no group', () {
      final model = ApplicationUserModel.fromMap('uid-1', {
        'employeeId': 'EMP-1',
        'email': 'a@b.com',
        'isActive': true,
      });

      expect(model.groupId, isNull);
    });

    test('an unexpected field type does not break the whole list', () {
      final model = ApplicationUserModel.fromMap('uid-1', {
        'employeeId': 42,
        'email': ['not', 'a', 'string'],
        'groupId': 7,
        'isActive': 'false',
      });

      expect(model.employeeId, '');
      expect(model.email, '');
      expect(model.groupId, isNull);
      expect(model.isActive, isFalse);
    });

    test('a missing isActive flag keeps the account active', () {
      final model = ApplicationUserModel.fromMap('uid-1', {
        'employeeId': 'EMP-1',
        'email': 'a@b.com',
      });

      expect(model.isActive, isTrue);
    });

    test('a legacy document written without the new fields still parses', () {
      final model = ApplicationUserModel.fromMap('uid-1', {});

      expect(model.id, 'uid-1');
      expect(model.employeeId, '');
      expect(model.email, '');
      expect(model.isActive, isTrue);
    });
  });
}
