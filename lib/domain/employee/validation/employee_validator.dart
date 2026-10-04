import 'package:hr_management_system/core/constants/constants.dart';
import 'package:hr_management_system/core/utils/date_parser.dart';

class EmployeeValidator {
  const EmployeeValidator._();

  static const List<String> genders = ['Male', 'Female'];

  static final RegExp _phonePattern = RegExp(r'^01[0125][0-9]{8}$');

  static final RegExp _nationalIdPattern = RegExp(r'^\d{14}$');

  static final RegExp _displayDatePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');

  static const String addressRequiredKey =
      'validation.employee.address_required';

  static const String departmentRequiredKey =
      'validation.employee.department_required';

  static const String nationalityRequiredKey =
      'validation.employee.nationality_required';

  static const String genderRequiredKey =
      'validation.employee.gender_required';

  static const String contractDateRequiredKey =
      'validation.employee.contract_date_required';

  static const String birthDateRequiredKey =
      'validation.employee.birth_date_required';

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.employee.full_name_required';
    }

    if (value.trim().length < 3) {
      return 'validation.employee.full_name_short';
    }

    return null;
  }

  static String? address(String? value) {
    return required(value, addressRequiredKey);
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.employee.phone_required';
    }

    if (!_phonePattern.hasMatch(value.trim())) {
      return 'validation.employee.phone_invalid';
    }

    return null;
  }

  static String? nationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.employee.national_id_required';
    }

    if (!_nationalIdPattern.hasMatch(value.trim())) {
      return 'validation.employee.national_id_invalid';
    }

    return null;
  }

  static String? nationality(String? value) {
    return required(value, nationalityRequiredKey);
  }

  static String? gender(String? value) {
    return required(value, genderRequiredKey);
  }

  static String? department(String? value) {
    return required(value, departmentRequiredKey);
  }

  static String? salaryText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.employee.salary_required';
    }

    final salary = double.tryParse(value.trim());

    if (salary == null) {
      return 'validation.employee.salary_invalid';
    }

    if (salary <= 0) {
      return 'validation.employee.salary_positive';
    }

    return null;
  }

  static String? salary(double? value) {
    if (value == null) {
      return 'validation.employee.salary_required';
    }

    if (value <= 0) {
      return 'validation.employee.salary_positive';
    }

    return null;
  }

  static String? displayDate(String? value, String requiredKey) {
    if (value == null || value.trim().isEmpty) {
      return requiredKey;
    }

    final date = value.trim();

    if (!_displayDatePattern.hasMatch(date)) {
      return 'validation.date_format';
    }

    final parts = date.split('/');

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return 'validation.date_invalid';
    }

    final parsedDate = DateTime(year, month, day);

    if (parsedDate.year != year ||
        parsedDate.month != month ||
        parsedDate.day != day) {
      return 'validation.date_invalid';
    }

    return null;
  }

  static String? contractDateText(String? value) {
    final error = displayDate(value, contractDateRequiredKey);

    if (error != null) {
      return error;
    }

    return contractDate(DateParser.fromDisplayDate(value!.trim()));
  }

  static String? contractDate(DateTime? value) {
    if (value == null) {
      return contractDateRequiredKey;
    }

    if (value.year < companyStartYear) {
      return 'validation.employee.contract_date_before_start';
    }

    return null;
  }

  static String? birthDateText(String? value) {
    final error = displayDate(value, birthDateRequiredKey);

    if (error != null) {
      return error;
    }

    return birthDate(DateParser.fromDisplayDate(value!.trim()));
  }

  static String? birthDate(DateTime? value) {
    if (value == null) {
      return birthDateRequiredKey;
    }

    final today = DateTime.now();

    final minimumBirthDate = DateTime(today.year - 20, today.month, today.day);

    if (value.isAfter(minimumBirthDate)) {
      return 'validation.employee.age_restriction';
    }

    return null;
  }

  static String? required(String? value, String requiredKey) {
    if (value == null || value.trim().isEmpty) {
      return requiredKey;
    }

    return null;
  }
}
