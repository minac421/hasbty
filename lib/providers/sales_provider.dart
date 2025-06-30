import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sale.dart';

class SalesNotifier extends StateNotifier<List<Sale>> {
  SalesNotifier() : super(_generateDummySales());
  
  static List<Sale> _generateDummySales() {
    return [
      Sale(
        id: '1',
        userId: 'dummy-user',
        customerName: 'أحمد محمد سالم',
        customerId: '1',
        totalAmount: 45.0,
        discountAmount: 0.0,
        taxAmount: 6.3,
        finalAmount: 51.3,
        paymentMethod: 'نقدي',
        status: 'مكتملة',
        saleDate: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Sale(
        id: '2',
        userId: 'dummy-user',
        customerName: 'فاطمة علي أحمد',
        customerId: '2',
        totalAmount: 120.0,
        discountAmount: 10.0,
        taxAmount: 15.4,
        finalAmount: 125.4,
        paymentMethod: 'بطاقة',
        status: 'مكتملة',
        saleDate: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Sale(
        id: '3',
        userId: 'dummy-user',
        customerName: 'محمود حسن عبدالله',
        customerId: '3',
        totalAmount: 75.0,
        discountAmount: 5.0,
        taxAmount: 9.8,
        finalAmount: 79.8,
        paymentMethod: 'نقدي',
        status: 'مكتملة',
        saleDate: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Sale(
        id: '4',
        userId: 'dummy-user',
        customerName: 'نورا إبراهيم',
        customerId: '4',
        totalAmount: 89.5,
        discountAmount: 0.0,
        taxAmount: 12.5,
        finalAmount: 102.0,
        paymentMethod: 'تحويل بنكي',
        status: 'مكتملة',
        saleDate: DateTime.now().subtract(const Duration(hours: 5)),
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Sale(
        id: '5',
        userId: 'dummy-user',
        customerName: 'خالد أحمد',
        totalAmount: 156.0,
        discountAmount: 15.0,
        taxAmount: 19.7,
        finalAmount: 160.7,
        paymentMethod: 'آجل',
        status: 'معلقة',
        saleDate: DateTime.now().subtract(const Duration(hours: 8)),
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }
  
  void addSale(Sale sale) {
    state = [sale.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'dummy-user',
      saleDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ), ...state];
  }
  
  void updateSale(Sale sale) {
    state = state.map((s) => 
      s.id == sale.id ? sale.copyWith(updatedAt: DateTime.now()) : s
    ).toList();
  }
  
  void deleteSale(String id) {
    state = state.where((s) => s.id != id).toList();
  }
  
  double getTotalRevenue() {
    return state.fold(0.0, (sum, sale) => sum + sale.finalAmount);
  }
  
  double getTodayRevenue() {
    final today = DateTime.now();
    return state.where((sale) => 
      sale.saleDate.year == today.year &&
      sale.saleDate.month == today.month &&
      sale.saleDate.day == today.day
    ).fold(0.0, (sum, sale) => sum + sale.finalAmount);
  }
  
  int getTodaySalesCount() {
    final today = DateTime.now();
    return state.where((sale) => 
      sale.saleDate.year == today.year &&
      sale.saleDate.month == today.month &&
      sale.saleDate.day == today.day
    ).length;
  }
  
  double getWeeklyRevenue() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return state.where((sale) => sale.saleDate.isAfter(weekAgo))
        .fold(0.0, (sum, sale) => sum + sale.finalAmount);
  }
  
  double getMonthlyRevenue() {
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    return state.where((sale) => sale.saleDate.isAfter(monthAgo))
        .fold(0.0, (sum, sale) => sum + sale.finalAmount);
  }
  
  List<Sale> getPendingSales() {
    return state.where((sale) => sale.status == 'معلقة').toList();
  }
  
  List<Sale> getCompletedSales() {
    return state.where((sale) => sale.status == 'مكتملة').toList();
  }
  
  Map<String, double> getSalesByPaymentMethod() {
    final result = <String, double>{};
    for (final sale in state) {
      result[sale.paymentMethod] = (result[sale.paymentMethod] ?? 0) + sale.finalAmount;
    }
    return result;
  }
  
  List<Sale> searchSales(String query) {
    if (query.isEmpty) return state;
    return state.where((s) => 
      s.customerName.toLowerCase().contains(query.toLowerCase()) ||
      (s.id?.contains(query) ?? false) ||
      s.paymentMethod.toLowerCase().contains(query.toLowerCase()) ||
      (s.customerId?.contains(query) ?? false)
    ).toList();
  }
}

final salesProvider = StateNotifierProvider<SalesNotifier, List<Sale>>((ref) {
  return SalesNotifier();
});

// Provider للحصول على إحصائيات المبيعات
final salesStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final sales = ref.watch(salesProvider);
  final salesNotifier = ref.read(salesProvider.notifier);
  
  return {
    'totalRevenue': salesNotifier.getTotalRevenue(),
    'todayRevenue': salesNotifier.getTodayRevenue(),
    'todaySalesCount': salesNotifier.getTodaySalesCount(),
    'weeklyRevenue': salesNotifier.getWeeklyRevenue(),
    'monthlyRevenue': salesNotifier.getMonthlyRevenue(),
    'pendingSales': salesNotifier.getPendingSales().length,
    'completedSales': salesNotifier.getCompletedSales().length,
    'totalSales': sales.length,
  };
}); 