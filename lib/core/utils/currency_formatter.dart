import 'package:intl/intl.dart';

/// Formats [amount] using the given ISO 4217 [currencyCode] (e.g. 'GBP', 'USD', 'EUR').
String formatCurrency(double amount, String currencyCode) {
  return NumberFormat.simpleCurrency(name: currencyCode).format(amount);
}
