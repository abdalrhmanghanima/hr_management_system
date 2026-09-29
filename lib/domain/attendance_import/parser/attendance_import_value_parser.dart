import 'package:hr_management_system/core/utils/date_parser.dart';

class AttendanceImportValueParser {
  static final DateTime _excelEpoch = DateTime(1899, 12, 30);

  static final RegExp _separatorDate = RegExp(
    r'^(\d{1,4})[-/](\d{1,2})[-/](\d{1,4})$',
  );

  static final RegExp _timePattern = RegExp(
    r'^(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?\s*([a-zA-Z]{2})?$',
  );

  static bool isBlank(Object? value) {
    if (value == null) {
      return true;
    }

    if (value is String) {
      return value.trim().isEmpty;
    }

    return false;
  }

  static DateTime? parseDate(Object? value) {
    if (isBlank(value)) {
      return null;
    }

    if (value is DateTime) {
      return DateTime(value.year, value.month, value.day);
    }

    if (value is num) {
      return _dateFromSerial(value.toDouble());
    }

    return _dateFromText(value.toString());
  }

  static DateTime? parseTime(Object? value, {DateTime? date}) {
    if (isBlank(value)) {
      return null;
    }

    final baseDate = date ?? DateTime.now();

    if (value is DateTime) {
      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        value.hour,
        value.minute,
        value.second,
      );
    }

    if (value is num) {
      return _timeFromSerial(value.toDouble(), baseDate);
    }

    return _timeFromText(value.toString(), baseDate);
  }

  static String asText(Object? value) {
    if (value == null) {
      return '';
    }

    if (value is double && value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString().trim();
  }

  static String? readText(Object? value) {
    final text = asText(value);

    return text.isEmpty ? null : text;
  }

  static DateTime? _dateFromSerial(double serial) {
    if (serial < 1) {
      return null;
    }

    final date = _excelEpoch.add(
      Duration(milliseconds: (serial * Duration.millisecondsPerDay).round()),
    );

    return DateTime(date.year, date.month, date.day);
  }

  static DateTime? _timeFromSerial(double serial, DateTime baseDate) {
    var fraction = serial % 1;

    if (fraction < 0) {
      fraction += 1;
    }

    final totalSeconds = (fraction * Duration.secondsPerDay).round();

    if (totalSeconds >= Duration.secondsPerDay) {
      return null;
    }

    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      totalSeconds ~/ Duration.secondsPerHour,
      (totalSeconds % Duration.secondsPerHour) ~/ Duration.secondsPerMinute,
      totalSeconds % Duration.secondsPerMinute,
    );
  }

  static DateTime? _dateFromText(String raw) {
    final text = raw.trim();

    if (text.isEmpty) {
      return null;
    }

    final match = _separatorDate.firstMatch(text);

    if (match == null) {
      final parsed = DateTime.tryParse(text);

      if (parsed == null) {
        return null;
      }

      return DateTime(parsed.year, parsed.month, parsed.day);
    }

    final first = int.parse(match.group(1)!);
    final second = int.parse(match.group(2)!);
    final third = int.parse(match.group(3)!);

    int year;
    int month;
    int day;

    if (match.group(1)!.length == 4) {
      year = first;
      month = second;
      day = third;
    } else {
      year = third;

      if (first > 12) {
        day = first;
        month = second;
      } else if (second > 12) {
        day = second;
        month = first;
      } else {
        day = first;
        month = second;
      }
    }

    return _safeDate(year, month, day);
  }

  static DateTime? _timeFromText(String raw, DateTime baseDate) {
    final text = raw.trim();

    if (text.isEmpty) {
      return null;
    }

    final display = DateParser.fromDisplayTime(text, date: baseDate);

    if (display != null) {
      return display;
    }

    final match = _timePattern.firstMatch(text);

    if (match != null) {
      var hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final second = int.tryParse(match.group(3) ?? '0') ?? 0;
      final period = match.group(4)?.toUpperCase();

      if (minute > 59 || second > 59) {
        return null;
      }

      if (period != null) {
        if (hour < 1 || hour > 12) {
          return null;
        }

        if (period == 'AM' && hour == 12) {
          hour = 0;
        } else if (period == 'PM' && hour != 12) {
          hour += 12;
        }
      } else if (hour > 23) {
        return null;
      }

      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hour,
        minute,
        second,
      );
    }

    final parsed = DateTime.tryParse(text);

    if (parsed == null) {
      return null;
    }

    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
    );
  }

  static DateTime? _safeDate(int year, int month, int day) {
    if (year < 1900 || year > 2200 || month < 1 || month > 12) {
      return null;
    }

    if (day < 1 || day > 31) {
      return null;
    }

    final date = DateTime(year, month, day);

    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }

    return date;
  }
}
