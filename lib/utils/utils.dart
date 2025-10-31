String formatToIndianUnits(double value) {
  final sign = value < 0 ? "-" : "";
  value = value.abs();

  String formatNumber(double num) {
    // Keep up to 2 decimals, but remove trailing zeros
    return num.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  if (value >= 10000000) {
    // Crores
    return "₹$sign${formatNumber(value / 10000000)} Cr";
  } else if (value >= 100000) {
    // Lakhs
    return "₹$sign${formatNumber(value / 100000)} L";
  } else if (value >= 1000) {
    // Thousands
    return "₹$sign${formatNumber(value / 1000)} K";
  } else {
    // Below 1000
    return "₹$sign${formatNumber(value)}";
  }
}
