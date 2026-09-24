import 'package:flutter/material.dart';

class DatePickerHelper {
  static Future<String?> pickFormattedDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1950),
      lastDate: lastDate ?? DateTime.now(),
    );

    if (date == null) return null;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}