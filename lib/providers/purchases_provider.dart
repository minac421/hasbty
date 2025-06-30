import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/purchase.dart';

class PurchasesNotifier extends StateNotifier<List<Purchase>> {
  PurchasesNotifier() : super(_generateDummyPurchases());
  
  static List<Purchase> _generateDummyPurchases() {
    return [
      Purchase(
        id: '1',
        userId: 'dummy-user',
        supplierId: '1', // شركة النور للمواد الغذائية
        supplierName: 'شركة النور للمواد الغذائية',
        invoiceNumber: 'PUR-001',
        totalAmount: 2500.0,
        finalAmount: 2500.0,
        status: 'مكتملة',
        paymentMethod: 'نقدي',
        notes: 'شراء بضائع أساسية للمحل',
        purchaseDate: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        items: [
          PurchaseItem(
            purchaseId: '1',
            productId: '1',
            productName: 'بيبسي',
            quantity: 24,
            unitPrice: 50.0,
            totalPrice: 1200.0,
          ),
          PurchaseItem(
            purchaseId: '1',
            productId: '2',
            productName: 'شيبسي',
            quantity: 20,
            unitPrice: 65.0,
            totalPrice: 1300.0,
          ),
        ],
      ),
      Purchase(
        id: '2',
        userId: 'dummy-user',
        supplierId: '3', // شركة الأهرام للألبان
        supplierName: 'شركة الأهرام للألبان',
        invoiceNumber: 'PUR-002',
        totalAmount: 1800.0,
        finalAmount: 1800.0,
        status: 'آجل',
        paymentMethod: 'آجل',
        notes: 'منتجات ألبان - دفع آجل',
        purchaseDate: DateTime.now().subtract(const Duration(days: 3)),
        dueDate: DateTime.now().add(const Duration(days: 27)),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        items: [
          PurchaseItem(
            purchaseId: '2',
            productId: '3',
            productName: 'لبن',
            quantity: 30,
            unitPrice: 25.0,
            totalPrice: 750.0,
          ),
          PurchaseItem(
            purchaseId: '2',
            productId: '8',
            productName: 'جبن',
            quantity: 15,
            unitPrice: 70.0,
            totalPrice: 1050.0,
          ),
        ],
      ),
      Purchase(
        id: '3',
        userId: 'dummy-user',
        supplierId: '4', // مصنع الفجر للمخبوزات
        supplierName: 'مصنع الفجر للمخبوزات',
        invoiceNumber: 'PUR-003',
        totalAmount: 1200.0,
        finalAmount: 1200.0,
        status: 'آجل',
        paymentMethod: 'آجل',
        notes: 'خبز ومخبوزات - استحقاق بعد 15 يوم',
        purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
        dueDate: DateTime.now().add(const Duration(days: 13)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        items: [
          PurchaseItem(
            purchaseId: '3',
            productId: '4',
            productName: 'خبز',
            quantity: 100,
            unitPrice: 3.0,
            totalPrice: 300.0,
          ),
          PurchaseItem(
            purchaseId: '3',
            productId: '9',
            productName: 'كعك',
            quantity: 50,
            unitPrice: 18.0,
            totalPrice: 900.0,
          ),
        ],
      ),
      Purchase(
        id: '4',
        userId: 'dummy-user',
        supplierId: '5', // شركة النيل للزيوت  
        supplierName: 'شركة النيل للزيوت',
        invoiceNumber: 'PUR-004',
        totalAmount: 3200.0,
        finalAmount: 3200.0,
        status: 'مكتملة',
        paymentMethod: 'تحويل بنكي',
        notes: 'زيوت ومواد غذائية',
        purchaseDate: DateTime.now().subtract(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        items: [
          PurchaseItem(
            purchaseId: '4',
            productId: '5',
            productName: 'زيت',
            quantity: 20,
            unitPrice: 85.0,
            totalPrice: 1700.0,
          ),
          PurchaseItem(
            purchaseId: '4',
            productId: '6',
            productName: 'أرز',
            quantity: 30,
            unitPrice: 50.0,
            totalPrice: 1500.0,
          ),
        ],
      ),
      Purchase(
        id: '5',
        userId: 'dummy-user',
        supplierId: '2', // مؤسسة الخير للتوريدات
        supplierName: 'مؤسسة الخير للتوريدات',
        invoiceNumber: 'PUR-005',
        totalAmount: 950.0,
        finalAmount: 950.0,
        status: 'مكتملة',
        paymentMethod: 'نقدي',
        notes: 'مشروبات ساخنة',
        purchaseDate: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        items: [
          PurchaseItem(
            purchaseId: '5',
            productId: '7',
            productName: 'شاي',
            quantity: 25,
            unitPrice: 18.0,
            totalPrice: 450.0,
          ),
          PurchaseItem(
            purchaseId: '5',
            productId: '8',
            productName: 'سكر',
            quantity: 10,
            unitPrice: 50.0,
            totalPrice: 500.0,
          ),
        ],
      ),
      Purchase(
        id: '6',
        userId: 'dummy-user',
        supplierId: '8', // مصنع الصعيد للمشروبات
        supplierName: 'مصنع الصعيد للمشروبات',
        invoiceNumber: 'PUR-006',
        totalAmount: 1750.0,
        finalAmount: 1750.0,
        status: 'مكتملة',
        paymentMethod: 'فيزا',
        notes: 'مشروبات باردة للصيف',
        purchaseDate: DateTime.now().subtract(const Duration(hours: 8)),
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
        items: [
          PurchaseItem(
            purchaseId: '6',
            productId: '1',
            productName: 'عصير',
            quantity: 36,
            unitPrice: 35.0,
            totalPrice: 1260.0,
          ),
          PurchaseItem(
            purchaseId: '6',
            productId: '10',
            productName: 'مياه',
            quantity: 20,
            unitPrice: 24.5,
            totalPrice: 490.0,
          ),
        ],
      ),
    ];
  }
  
  void addPurchase(Purchase purchase) {
    state = [...state, purchase.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'dummy-user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )];
  }
  
  void updatePurchase(Purchase purchase) {
    state = state.map((p) => 
      p.id == purchase.id ? purchase.copyWith(updatedAt: DateTime.now()) : p
    ).toList();
  }
  
  void deletePurchase(String id) {
    state = state.where((p) => p.id != id).toList();
  }
  
  void updatePurchaseStatus(String purchaseId, String newStatus) {
    state = state.map((p) {
      if (p.id == purchaseId) {
        return p.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
  }
  
  List<Purchase> getPurchasesBySupplier(String supplierId) {
    return state.where((p) => p.supplierId == supplierId).toList();
  }
  
  List<Purchase> getPurchasesByStatus(String status) {
    return state.where((p) => p.status == status).toList();
  }
  
  List<Purchase> getPurchasesByDateRange(DateTime startDate, DateTime endDate) {
    return state.where((p) => 
      p.purchaseDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
      p.purchaseDate.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }
  
  List<Purchase> getOverduePurchases() {
    return state.where((p) => p.isOverdue).toList();
  }
  
  List<Purchase> searchPurchases(String query) {
    if (query.isEmpty) return state;
    return state.where((p) => 
      (p.invoiceNumber?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
      p.supplierName.toLowerCase().contains(query.toLowerCase()) ||
      (p.notes?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }
  
  double getTotalPurchases() {
    return state.fold(0.0, (sum, purchase) => sum + purchase.finalAmount);
  }
  
  double getTotalPaid() {
    return state.where((p) => p.status == 'مكتملة')
        .fold(0.0, (sum, purchase) => sum + purchase.finalAmount);
  }
  
  double getTotalOutstanding() {
    return state.where((p) => p.status == 'آجل')
        .fold(0.0, (sum, purchase) => sum + purchase.finalAmount);
  }
  
  double getTodayPurchases() {
    final today = DateTime.now();
    return state.where((p) => 
      p.purchaseDate.year == today.year &&
      p.purchaseDate.month == today.month &&
      p.purchaseDate.day == today.day
    ).fold(0.0, (sum, purchase) => sum + purchase.finalAmount);
  }
  
  double getMonthlyPurchases() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return getPurchasesByDateRange(startOfMonth, now)
        .fold(0.0, (sum, purchase) => sum + purchase.finalAmount);
  }
  
  Map<String, double> getPurchasesByPaymentMethod() {
    final result = <String, double>{};
    for (final purchase in state) {
      result[purchase.paymentMethod] = (result[purchase.paymentMethod] ?? 0) + purchase.finalAmount;
    }
    return result;
  }
  
  Purchase? getPurchaseById(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

final purchasesProvider = StateNotifierProvider<PurchasesNotifier, List<Purchase>>((ref) {
  return PurchasesNotifier();
});

// Provider للحصول على إحصائيات المشتريات
final purchasesStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final purchases = ref.watch(purchasesProvider);
  final purchasesNotifier = ref.read(purchasesProvider.notifier);
  
  final totalPurchases = purchasesNotifier.getTotalPurchases();
  final totalPaid = purchasesNotifier.getTotalPaid();
  final totalOutstanding = purchasesNotifier.getTotalOutstanding();
  final todayPurchases = purchasesNotifier.getTodayPurchases();
  final monthlyPurchases = purchasesNotifier.getMonthlyPurchases();
  
  final completedPurchases = purchasesNotifier.getPurchasesByStatus('مكتملة');
  final pendingPurchases = purchasesNotifier.getPurchasesByStatus('آجل');
  final overduePurchases = purchasesNotifier.getOverduePurchases();
  
  return {
    'totalPurchases': purchases.length,
    'totalAmount': totalPurchases,
    'totalPaid': totalPaid,
    'totalOutstanding': totalOutstanding,
    'todayPurchases': todayPurchases,
    'monthlyPurchases': monthlyPurchases,
    'completedCount': completedPurchases.length,
    'pendingCount': pendingPurchases.length,
    'overdueCount': overduePurchases.length,
    'paymentMethods': purchasesNotifier.getPurchasesByPaymentMethod(),
  };
}); 