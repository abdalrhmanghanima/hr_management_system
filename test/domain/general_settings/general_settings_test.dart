import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/data/general_settings/data_source/general_settings_remote_data_source.dart';
import 'package:hr_management_system/data/general_settings/model/general_settings_model.dart';
import 'package:hr_management_system/data/general_settings/repository/general_settings_repository_impl.dart';
import 'package:hr_management_system/domain/general_settings/entity/general_settings_entity.dart';
import 'package:hr_management_system/domain/general_settings/use_case/get_general_settings_use_case.dart';
import 'package:hr_management_system/domain/general_settings/use_case/update_general_settings_use_case.dart';
import 'package:hr_management_system/domain/general_settings/validation/general_settings_validator.dart';

class _FakeGeneralSettingsRemoteDataSource
    implements GeneralSettingsRemoteDataSource {
  GeneralSettingsModel? stored;

  int updateCount = 0;

  @override
  Future<GeneralSettingsModel> getGeneralSettings() async {
    return stored ?? GeneralSettingsModel.defaults();
  }

  @override
  Future<void> updateGeneralSettings(GeneralSettingsModel settings) async {
    stored = settings;
    updateCount++;
  }
}

void main() {
  late _FakeGeneralSettingsRemoteDataSource dataSource;
  late GeneralSettingsRepositoryImpl repository;
  late GetGeneralSettingsUseCase getSettings;
  late UpdateGeneralSettingsUseCase updateSettings;

  setUp(() {
    dataSource = _FakeGeneralSettingsRemoteDataSource();
    repository = GeneralSettingsRepositoryImpl(dataSource);
    getSettings = GetGeneralSettingsUseCase(repository);
    updateSettings = UpdateGeneralSettingsUseCase(repository);
  });

  group('defaults', () {
    test('the default settings use a multiplier of 2 and an 8 hour day', () {
      final defaults = GeneralSettingsEntity.defaults();

      expect(defaults.multiplier, 2);
      expect(defaults.workingHoursPerDay, 8);
      expect(defaults.weekendDays, ['Friday', 'Saturday']);
    });

    test('loading without a stored document returns the defaults', () async {
      final settings = await getSettings();

      expect(settings.multiplier, 2);
      expect(settings.workingHoursPerDay, 8);
      expect(settings.weekendDays, ['Friday', 'Saturday']);
    });
  });

  group('load and save', () {
    test('a saved value is returned on the next load', () async {
      await updateSettings(
        GeneralSettingsEntity(
          multiplier: 1.5,
          workingHoursPerDay: 7.5,
          weekendDays: ['Sunday'],
        ),
      );

      final loaded = await getSettings();

      expect(loaded.multiplier, 1.5);
      expect(loaded.workingHoursPerDay, 7.5);
      expect(loaded.weekendDays, ['Sunday']);
      expect(dataSource.updateCount, 1);
    });

    test('a weekend selection of several days is preserved', () async {
      await updateSettings(
        GeneralSettingsEntity(
          multiplier: 2,
          workingHoursPerDay: 8,
          weekendDays: ['Friday', 'Saturday', 'Sunday'],
        ),
      );

      final loaded = await getSettings();

      expect(loaded.weekendDays, ['Friday', 'Saturday', 'Sunday']);
    });

    test('the model round trip keeps every field', () {
      final model = GeneralSettingsModel(
        multiplier: 2.5,
        workingHoursPerDay: 6,
        weekendDays: ['Tuesday'],
      );

      final entity = model.toEntity();

      expect(model.toFirestore()['multiplier'], 2.5);
      expect(model.toFirestore()['workingHoursPerDay'], 6);
      expect(model.toFirestore()['weekendDays'], ['Tuesday']);
      expect(entity.multiplier, 2.5);
      expect(entity.workingHoursPerDay, 6);
      expect(entity.weekendDays, ['Tuesday']);
    });
  });

  group('validation', () {
    test('an empty multiplier is rejected', () {
      expect(GeneralSettingsValidator.multiplier(''), isNotNull);
    });

    test('a non numeric multiplier is rejected', () {
      expect(GeneralSettingsValidator.multiplier('abc'), isNotNull);
    });

    test('a multiplier of zero is rejected', () {
      expect(
        GeneralSettingsValidator.multiplier('0'),
        'Multiplier must be greater than 0',
      );
    });

    test('a negative multiplier is rejected', () {
      expect(
        GeneralSettingsValidator.multiplier('-1'),
        'Multiplier must be greater than 0',
      );
    });

    test('a positive multiplier is accepted', () {
      expect(GeneralSettingsValidator.multiplier('2.5'), isNull);
    });

    test('zero working hours are rejected', () {
      expect(
        GeneralSettingsValidator.workingHoursPerDay('0'),
        'Working Hours Per Day must be greater than 0',
      );
    });

    test('negative working hours are rejected', () {
      expect(GeneralSettingsValidator.workingHoursPerDay('-8'), isNotNull);
    });

    test('an empty working hours value is rejected', () {
      expect(GeneralSettingsValidator.workingHoursPerDay('  '), isNotNull);
    });

    test('no weekend day is rejected', () {
      expect(
        GeneralSettingsValidator.weekendDays([]),
        'Select at least one weekend day',
      );
    });

    test('one weekend day is enough', () {
      expect(GeneralSettingsValidator.weekendDays(['Sunday']), isNull);
    });

    test('the default settings are valid', () {
      expect(
        GeneralSettingsValidator.isValid(GeneralSettingsEntity.defaults()),
        isTrue,
      );
    });

    test('settings without a weekend day are not valid', () {
      final settings = GeneralSettingsEntity(
        multiplier: 2,
        workingHoursPerDay: 8,
        weekendDays: [],
      );

      expect(GeneralSettingsValidator.isValid(settings), isFalse);
      expect(GeneralSettingsValidator.validate(settings), isNotNull);
    });
  });
}
