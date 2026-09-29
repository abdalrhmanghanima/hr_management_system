class DateParser {
  static DateTime fromDisplayDate(String value) {
    final parts = value.split('/');

    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  static String toDisplayDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  static String toIsoDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  static DateTime? fromDisplayTime(
      String value, {
        DateTime? date,
      }) {
    if (value.trim().isEmpty) {
      return null;
    }

    final parts = value.trim().split(' ');

    if (parts.length != 2) {
      return null;
    }

    final timeParts = parts[0].split(':');

    if (timeParts.length != 2) {
      return null;
    }

    var hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    final period = parts[1].toUpperCase();

    if (hour == null || minute == null) {
      return null;
    }

    if (hour < 1 || hour > 12) {
      return null;
    }

    if (minute < 0 || minute > 59) {
      return null;
    }

    if (period != 'AM' && period != 'PM') {
      return null;
    }

    if (period == 'AM' && hour == 12) {
      hour = 0;
    } else if (period == 'PM' && hour != 12) {
      hour += 12;
    }

    final baseDate = date ?? DateTime.now();

    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hour,
      minute,
    );
  }

  static String toDisplayTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }
}
