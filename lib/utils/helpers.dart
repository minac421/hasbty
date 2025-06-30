
import 'package:intl/intl.dart';

class Helpers {
  // Format currency
  static String formatCurrency(double amount, {String currency = 'EGP'}) {
    final formatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
  
  static String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'EGP':
        return '£';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'SAR':
        return '﷼';
      default:
        return '£';
    }
  }
  
  // Format date
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'ar');
    return formatter.format(date);
  }
  
  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy - HH:mm', 'ar');
    return formatter.format(dateTime);
  }
  
  // Get month name in Arabic
  static String getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month - 1];
  }
  
  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  // Validate phone number
  static bool isValidPhone(String phone) {
    return RegExp(r'^01[0-2,5]{1}[0-9]{8}$').hasMatch(phone);
  }
  
  // Show success message
  static void showSuccessMessage(String message) {
    // Implementation for showing success message
  }
  
  // Show error message
  static void showErrorMessage(String message) {
    // Implementation for showing error message
  }
  
  // Calculate percentage
  static double calculatePercentage(double part, double whole) {
    if (whole == 0) return 0;
    return (part / whole) * 100;
  }
  
  // Get color for transaction type
  static int getTransactionColor(String type) {
    switch (type) {
      case 'income':
        return 0xFF10B981; // Green
      case 'expense':
        return 0xFFEF4444; // Red
      default:
        return 0xFF6B7280; // Gray
    }
  }
}
