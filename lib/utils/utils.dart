// String formatToIndianUnits(double value) {
//   if (value >= 10000000) {
//     // 1 Crore = 1 Cr = 10,000,000
//     double croreValue = value / 10000000;
//     return "₹${croreValue.toStringAsFixed(croreValue < 10 ? 2 : 1)} Cr";
//   } else if (value >= 100000) {
//     // 1 Lakh = 1 L = 100,000
//     double lakhValue = value / 100000;
//     return "₹${lakhValue.toStringAsFixed(lakhValue < 10 ? 2 : 1)} L";
//   } else if (value >= 1000) {
//     // Thousand
//     double thousandValue = value / 1000;
//     return "₹${thousandValue.toStringAsFixed(thousandValue < 10 ? 2 : 1)} K";
//   } else {
//     // Below thousand
//     return value.toStringAsFixed(2);
//   }
// }

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
