import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormatter = NumberFormat.compact(
    locale: 'en_US',
  );

  static final NumberFormat _percentageFormatter = NumberFormat.decimalPercentPattern(
    locale: 'en_US',
    decimalDigits: 2,
  );

  // Format currency
  static String formatCurrency(double amount) {
    if (amount < 1) {
      return '\$${amount.toStringAsFixed(4)}';
    }
    return _currencyFormatter.format(amount);
  }

  // Format large numbers (market cap, volume)
  static String formatCompact(double amount) {
    return _compactFormatter.format(amount);
  }

  // Format percentage
  static String formatPercentage(double percentage) {
    return _percentageFormatter.format(percentage / 100);
  }

  // Format price change with color indicator
  static String formatPriceChange(double change) {
    final sign = change >= 0 ? '+' : '';
    return '$sign${formatCurrency(change)}';
  }

  // Format percentage change with color indicator
  static String formatPercentageChange(double percentage) {
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(2)}%';
  }

  // Format market cap rank
  static String formatRank(double rank) {
    return '#${rank.toInt()}';
  }

  // Format supply numbers
  static String formatSupply(double supply) {
    if (supply == 0) return 'N/A';
    return _compactFormatter.format(supply);
  }

  // Format date
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Get color for price change
  static bool isPositiveChange(double change) {
    return change >= 0;
  }

  // Format number with appropriate decimal places
  static String formatNumber(double number) {
    if (number == 0) return '0';
    if (number < 0.01) return number.toStringAsFixed(6);
    if (number < 1) return number.toStringAsFixed(4);
    if (number < 100) return number.toStringAsFixed(2);
    return number.toStringAsFixed(0);
  }
} 