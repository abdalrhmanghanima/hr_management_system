import 'package:hr_management_system/core/utils/date_parser.dart';

class EmployeeValidator {
  const EmployeeValidator._();

  static const List<String> genders = ['Male', 'Female'];

  static final RegExp _phonePattern = RegExp(r'^01[0125][0-9]{8}$');

  static final RegExp _nationalIdPattern = RegExp(r'^\d{14}$');

  static final RegExp _displayDatePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full Name is required';
    }

    if (value.trim().length < 3) {
      return 'Full Name must be at least 3 characters';
    }

    return null;
  }

  static String? address(String? value) {
    return required(value, 'Address');
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone Number is required';
    }

    if (!_phonePattern.hasMatch(value.trim())) {
      return 'Enter a valid Egyptian phone number';
    }

    return null;
  }

  static String? nationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'National ID is required';
    }

    if (!_nationalIdPattern.hasMatch(value.trim())) {
      return 'National ID must be 14 digits';
    }

    return null;
  }

  static String? nationality(String? value) {
    return required(value, 'Nationality');
  }

  static String? gender(String? value) {
    return required(value, 'Gender');
  }

  static String? department(String? value) {
    return required(value, 'Department');
  }

  static String? salaryText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Salary is required';
    }

    final salary = double.tryParse(value.trim());

    if (salary == null) {
      return 'Enter a valid salary';
    }

    if (salary <= 0) {
      return 'Salary must be greater than 0';
    }

    return null;
  }

  static String? salary(double? value) {
    if (value == null) {
      return 'Salary is required';
    }

    if (value <= 0) {
      return 'Salary must be greater than 0';
    }

    return null;
  }

  static String? displayDate(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final date = value.trim();

    if (!_displayDatePattern.hasMatch(date)) {
      return 'Enter date as dd/mm/yyyy';
    }

    final parts = date.split('/');

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return 'Enter a valid date';
    }

    final parsedDate = DateTime(year, month, day);

    if (parsedDate.year != year ||
        parsedDate.month != month ||
        parsedDate.day != day) {
      return 'Enter a valid date';
    }

    return null;
  }

  static String? contractDateText(String? value) {
    return displayDate(value, 'Contract Date');
  }

  static String? contractDate(DateTime? value) {
    if (value == null) {
      return 'Contract Date is required';
    }

    return null;
  }

  static String? birthDateText(String? value) {
    final error = displayDate(value, 'Birth Date');

    if (error != null) {
      return error;
    }

    return birthDate(DateParser.fromDisplayDate(value!.trim()));
  }

  static String? birthDate(DateTime? value) {
    if (value == null) {
      return 'Birth Date is required';
    }

    final today = DateTime.now();

    final minimumBirthDate = DateTime(today.year - 20, today.month, today.day);

    if (value.isAfter(minimumBirthDate)) {
      return 'Employee must be at least 20 years old';
    }

    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }
}
