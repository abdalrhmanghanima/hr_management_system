class PayrollFormat {
  const PayrollFormat._();

  static String amount(double value) {
    final rounded = value.round();
    final digits = rounded.abs().toString();
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(digits[index]);
    }

    return rounded < 0 ? '-$buffer' : buffer.toString();
  }

  static String signed(double value) {
    final rounded = value.round();
    final negative = rounded < 0 || (rounded == 0 && value.isNegative);
    final body = amount(rounded.abs().toDouble());

    return negative ? '-$body' : '+$body';
  }

  static String hours(double value) {
    final rounded = value.roundToDouble();

    return rounded == value ? rounded.toStringAsFixed(0) : '$value';
  }
}
