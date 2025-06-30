import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryMovement {
  final String id;
  final String productId;
  final String productName;
  final String type; // 'in' للإدخال، 'out' للإخراج، 'adjustment' للتعديل
  final int quantity;
  final double unitPrice;
  final double totalValue;
  final String reason; // سبب الحركة
  final String? reference; // مرجع العملية (رقم فاتورة، رقم مرتجع، إلخ)
  final DateTime date;
  final String userId;

  InventoryMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.totalValue,
    required this.reason,
    this.reference,
    required this.date,
    required this.userId,
  });

  InventoryMovement copyWith({
    String? id,
    String? productId,
    String? productName,
    String? type,
    int? quantity,
    double? unitPrice,
    double? totalValue,
    String? reason,
    String? reference,
    DateTime? date,
    String? userId,
  }) {
    return InventoryMovement(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalValue: totalValue ?? this.totalValue,
      reason: reason ?? this.reason,
      reference: reference ?? this.reference,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }
}

class InventoryNotifier extends StateNotifier<List<InventoryMovement>> {
  InventoryNotifier() : super(_generateDummyMovements());
  
  static List<InventoryMovement> _generateDummyMovements() {
    return [
      // مشتريات - إدخال مخزون
      InventoryMovement(
        id: '1',
        productId: '1',
        productName: 'بيبسي',
        type: 'in',
        quantity: 24,
        unitPrice: 50.0,
        totalValue: 1200.0,
        reason: 'شراء من مورد',
        reference: 'PUR-001',
        date: DateTime.now().subtract(const Duration(days: 5)),
        userId: 'dummy-user',
      ),
      InventoryMovement(
        id: '2',
        productId: '2',
        productName: 'شيبسي',
        type: 'in',
        quantity: 20,
        unitPrice: 65.0,
        totalValue: 1300.0,
        reason: 'شراء من مورد',
        reference: 'PUR-001',
        date: DateTime.now().subtract(const Duration(days: 5)),
        userId: 'dummy-user',
      ),
      
      // مبيعات - إخراج مخزون
      InventoryMovement(
        id: '3',
        productId: '1',
        productName: 'بيبسي',
        type: 'out',
        quantity: 12,
        unitPrice: 60.0,
        totalValue: 720.0,
        reason: 'بيع للعميل',
        reference: 'SALE-001',
        date: DateTime.now().subtract(const Duration(days: 4)),
        userId: 'dummy-user',
      ),
      InventoryMovement(
        id: '4',
        productId: '3',
        productName: 'لبن',
        type: 'out',
        quantity: 15,
        unitPrice: 30.0,
        totalValue: 450.0,
        reason: 'بيع للعميل',
        reference: 'SALE-002',
        date: DateTime.now().subtract(const Duration(days: 3)),
        userId: 'dummy-user',
      ),
      
      // مزيد من المشتريات
      InventoryMovement(
        id: '5',
        productId: '3',
        productName: 'لبن',
        type: 'in',
        quantity: 30,
        unitPrice: 25.0,
        totalValue: 750.0,
        reason: 'شراء من مورد',
        reference: 'PUR-002',
        date: DateTime.now().subtract(const Duration(days: 3)),
        userId: 'dummy-user',
      ),
      InventoryMovement(
        id: '6',
        productId: '4',
        productName: 'خبز',
        type: 'in',
        quantity: 100,
        unitPrice: 3.0,
        totalValue: 300.0,
        reason: 'شراء من مورد',
        reference: 'PUR-003',
        date: DateTime.now().subtract(const Duration(days: 2)),
        userId: 'dummy-user',
      ),
      
      // تعديل جرد
      InventoryMovement(
        id: '7',
        productId: '2',
        productName: 'شيبسي',
        type: 'adjustment',
        quantity: -2,
        unitPrice: 65.0,
        totalValue: -130.0,
        reason: 'تلف منتج',
        reference: 'ADJ-001',
        date: DateTime.now().subtract(const Duration(days: 2)),
        userId: 'dummy-user',
      ),
      
      // مبيعات حديثة
      InventoryMovement(
        id: '8',
        productId: '4',
        productName: 'خبز',
        type: 'out',
        quantity: 50,
        unitPrice: 4.0,
        totalValue: 200.0,
        reason: 'بيع للعميل',
        reference: 'SALE-003',
        date: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'dummy-user',
      ),
      InventoryMovement(
        id: '9',
        productId: '5',
        productName: 'زيت',
        type: 'in',
        quantity: 20,
        unitPrice: 85.0,
        totalValue: 1700.0,
        reason: 'شراء من مورد',
        reference: 'PUR-004',
        date: DateTime.now().subtract(const Duration(days: 7)),
        userId: 'dummy-user',
      ),
      InventoryMovement(
        id: '10',
        productId: '5',
        productName: 'زيت',
        type: 'out',
        quantity: 8,
        unitPrice: 110.0,
        totalValue: 880.0,
        reason: 'بيع للعميل',
        reference: 'SALE-004',
        date: DateTime.now().subtract(const Duration(hours: 12)),
        userId: 'dummy-user',
      ),
      
      // تعديل جرد إيجابي
      InventoryMovement(
        id: '11',
        productId: '1',
        productName: 'بيبسي',
        type: 'adjustment',
        quantity: 5,
        unitPrice: 50.0,
        totalValue: 250.0,
        reason: 'تصحيح جرد',
        reference: 'ADJ-002',
        date: DateTime.now().subtract(const Duration(hours: 6)),
        userId: 'dummy-user',
      ),
      
      // مرتجعات
      InventoryMovement(
        id: '12',
        productId: '3',
        productName: 'لبن',
        type: 'in',
        quantity: 3,
        unitPrice: 25.0,
        totalValue: 75.0,
        reason: 'مرتجع من عميل',
        reference: 'RET-001',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        userId: 'dummy-user',
      ),
    ];
  }
  
  void addMovement(InventoryMovement movement) {
    state = [...state, movement.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'dummy-user',
      date: DateTime.now(),
    )];
  }
  
  void deleteMovement(String id) {
    state = state.where((m) => m.id != id).toList();
  }
  
  List<InventoryMovement> getMovementsByProduct(String productId) {
    return state.where((m) => m.productId == productId).toList();
  }
  
  List<InventoryMovement> getMovementsByType(String type) {
    return state.where((m) => m.type == type).toList();
  }
  
  List<InventoryMovement> getMovementsByDateRange(DateTime startDate, DateTime endDate) {
    return state.where((m) => 
      m.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
      m.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }
  
  List<InventoryMovement> searchMovements(String query) {
    if (query.isEmpty) return state;
    return state.where((m) => 
      m.productName.toLowerCase().contains(query.toLowerCase()) ||
      m.reason.toLowerCase().contains(query.toLowerCase()) ||
      (m.reference?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }
  
  // حساب المخزون الحالي لمنتج معين
  int getCurrentStock(String productId) {
    final movements = getMovementsByProduct(productId);
    int stock = 0;
    
    for (final movement in movements) {
      if (movement.type == 'in' || movement.type == 'adjustment') {
        stock += movement.quantity;
      } else if (movement.type == 'out') {
        stock -= movement.quantity;
      }
    }
    
    return stock > 0 ? stock : 0;
  }
  
  // حساب قيمة المخزون لمنتج معين
  double getStockValue(String productId) {
    final movements = getMovementsByProduct(productId)
        .where((m) => m.type == 'in' || (m.type == 'adjustment' && m.quantity > 0))
        .toList();
    
    if (movements.isEmpty) return 0.0;
    
    // حساب متوسط سعر الشراء
    double totalValue = 0.0;
    int totalQuantity = 0;
    
    for (final movement in movements) {
      totalValue += movement.totalValue;
      totalQuantity += movement.quantity;
    }
    
    if (totalQuantity == 0) return 0.0;
    
    final averagePrice = totalValue / totalQuantity;
    final currentStock = getCurrentStock(productId);
    
    return currentStock * averagePrice;
  }
  
  // إحصائيات الحركة اليومية
  Map<String, int> getTodayMovements() {
    final today = DateTime.now();
    final todayMovements = state.where((m) => 
      m.date.year == today.year &&
      m.date.month == today.month &&
      m.date.day == today.day
    ).toList();
    
    return {
      'in': todayMovements.where((m) => m.type == 'in').length,
      'out': todayMovements.where((m) => m.type == 'out').length,
      'adjustment': todayMovements.where((m) => m.type == 'adjustment').length,
    };
  }
  
  // إحصائيات القيمة
  Map<String, double> getValueStats() {
    double totalIn = 0.0;
    double totalOut = 0.0;
    double totalAdjustment = 0.0;
    
    for (final movement in state) {
      switch (movement.type) {
        case 'in':
          totalIn += movement.totalValue;
          break;
        case 'out':
          totalOut += movement.totalValue;
          break;
        case 'adjustment':
          totalAdjustment += movement.totalValue;
          break;
      }
    }
    
    return {
      'totalIn': totalIn,
      'totalOut': totalOut,
      'totalAdjustment': totalAdjustment,
      'netValue': totalIn + totalAdjustment - totalOut,
    };
  }
  
  // أكثر المنتجات حركة
  List<Map<String, dynamic>> getMostActiveProducts({int limit = 5}) {
    final productMovements = <String, int>{};
    final productNames = <String, String>{};
    
    for (final movement in state) {
      productMovements[movement.productId] = 
          (productMovements[movement.productId] ?? 0) + movement.quantity.abs();
      productNames[movement.productId] = movement.productName;
    }
    
    final sortedProducts = productMovements.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedProducts.take(limit).map((entry) => {
      'productId': entry.key,
      'productName': productNames[entry.key],
      'totalMovement': entry.value,
    }).toList();
  }
}

final inventoryProvider = StateNotifierProvider<InventoryNotifier, List<InventoryMovement>>((ref) {
  return InventoryNotifier();
});

// Provider للحصول على إحصائيات المخزون
final inventoryStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final inventory = ref.watch(inventoryProvider);
  final inventoryNotifier = ref.read(inventoryProvider.notifier);
  
  final todayMovements = inventoryNotifier.getTodayMovements();
  final valueStats = inventoryNotifier.getValueStats();
  final mostActiveProducts = inventoryNotifier.getMostActiveProducts();
  
  final inMovements = inventoryNotifier.getMovementsByType('in');
  final outMovements = inventoryNotifier.getMovementsByType('out');
  final adjustmentMovements = inventoryNotifier.getMovementsByType('adjustment');
  
  return {
    'totalMovements': inventory.length,
    'todayIn': todayMovements['in'] ?? 0,
    'todayOut': todayMovements['out'] ?? 0,
    'todayAdjustments': todayMovements['adjustment'] ?? 0,
    'totalInMovements': inMovements.length,
    'totalOutMovements': outMovements.length,
    'totalAdjustments': adjustmentMovements.length,
    'totalInValue': valueStats['totalIn'] ?? 0.0,
    'totalOutValue': valueStats['totalOut'] ?? 0.0,
    'totalAdjustmentValue': valueStats['totalAdjustment'] ?? 0.0,
    'netInventoryValue': valueStats['netValue'] ?? 0.0,
    'mostActiveProducts': mostActiveProducts,
  };
}); 