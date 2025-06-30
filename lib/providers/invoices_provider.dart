import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/invoice.dart';

class InvoicesNotifier extends StateNotifier<List<Invoice>> {
  InvoicesNotifier() : super(_generateDummyInvoices());
  
  static List<Invoice> _generateDummyInvoices() {
    return [
      // فواتير البيع
      Invoice(
        id: '1',
        userId: 'dummy-user',
        type: 'sale',
        customerId: '1',
        customerName: 'أحمد محمد سالم',
        invoiceNumber: 'SALE-001',
        invoiceDate: DateTime.now().subtract(const Duration(days: 2)),
        subtotal: 850.0,
        discount: 50.0,
        tax: 112.0, // 14% ضريبة
        totalAmount: 912.0,
        status: 'paid',
        paymentMethod: 'نقدي',
        notes: 'فاتورة بيع نقدية',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        items: [
          InvoiceItem(
            id: '1',
            invoiceId: '1',
            productId: '1',
            itemName: 'بيبسي',
            quantity: 12,
            unitPrice: 60.0,
            totalPrice: 720.0,
          ),
          InvoiceItem(
            id: '2',
            invoiceId: '1',
            productId: '2',
            itemName: 'شيبسي',
            quantity: 2,
            unitPrice: 65.0,
            totalPrice: 130.0,
          ),
        ],
      ),
      
      Invoice(
        id: '2',
        userId: 'dummy-user',
        type: 'sale',
        customerId: '3',
        customerName: 'محمود حسن عبدالله',
        invoiceNumber: 'SALE-002',
        invoiceDate: DateTime.now().subtract(const Duration(days: 1)),
        subtotal: 450.0,
        tax: 63.0,
        totalAmount: 513.0,
        status: 'pending',
        paymentMethod: 'آجل',
        notes: 'فاتورة آجلة - استحقاق خلال 30 يوم',
        dueDate: DateTime.now().add(const Duration(days: 29)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        items: [
          InvoiceItem(
            id: '3',
            invoiceId: '2',
            productId: '3',
            itemName: 'لبن',
            quantity: 15,
            unitPrice: 30.0,
            totalPrice: 450.0,
          ),
        ],
      ),
      
      Invoice(
        id: '3',
        userId: 'dummy-user',
        type: 'sale',
        customerId: '5',
        customerName: 'خالد أحمد سالم',
        invoiceNumber: 'SALE-003',
        invoiceDate: DateTime.now().subtract(const Duration(hours: 6)),
        subtotal: 320.0,
        discount: 20.0,
        tax: 42.0,
        totalAmount: 342.0,
        status: 'paid',
        paymentMethod: 'بطاقة',
        notes: 'دفع بالبطاقة الائتمانية',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        items: [
          InvoiceItem(
            id: '4',
            invoiceId: '3',
            productId: '4',
            itemName: 'خبز',
            quantity: 80,
            unitPrice: 4.0,
            totalPrice: 320.0,
          ),
        ],
      ),
      
      // فواتير الشراء
      Invoice(
        id: '4',
        userId: 'dummy-user',
        type: 'purchase',
        supplierId: '1',
        supplierName: 'شركة النور للمواد الغذائية',
        invoiceNumber: 'PUR-001',
        invoiceDate: DateTime.now().subtract(const Duration(days: 5)),
        subtotal: 2500.0,
        totalAmount: 2500.0,
        status: 'paid',
        paymentMethod: 'تحويل بنكي',
        notes: 'فاتورة شراء من المورد الرئيسي',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        items: [
          InvoiceItem(
            id: '5',
            invoiceId: '4',
            productId: '1',
            itemName: 'بيبسي - كرتونة',
            quantity: 24,
            unitPrice: 50.0,
            totalPrice: 1200.0,
          ),
          InvoiceItem(
            id: '6',
            invoiceId: '4',
            productId: '2',
            itemName: 'شيبسي - كرتونة',
            quantity: 20,
            unitPrice: 65.0,
            totalPrice: 1300.0,
          ),
        ],
      ),
      
      Invoice(
        id: '5',
        userId: 'dummy-user',
        type: 'purchase',
        supplierId: '3',
        supplierName: 'شركة الأهرام للألبان',
        invoiceNumber: 'PUR-002',
        invoiceDate: DateTime.now().subtract(const Duration(days: 3)),
        subtotal: 1800.0,
        totalAmount: 1800.0,
        status: 'pending',
        paymentMethod: 'آجل',
        notes: 'فاتورة شراء آجلة - استحقاق خلال 45 يوم',
        dueDate: DateTime.now().add(const Duration(days: 42)),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        items: [
          InvoiceItem(
            id: '7',
            invoiceId: '5',
            productId: '3',
            itemName: 'لبن - كرتونة',
            quantity: 30,
            unitPrice: 25.0,
            totalPrice: 750.0,
          ),
          InvoiceItem(
            id: '8',
            invoiceId: '5',
            productId: '8',
            itemName: 'جبن أبيض',
            quantity: 15,
            unitPrice: 70.0,
            totalPrice: 1050.0,
          ),
        ],
      ),
      
      Invoice(
        id: '6',
        userId: 'dummy-user',
        type: 'purchase',
        supplierId: '5',
        supplierName: 'شركة النيل للزيوت',
        invoiceNumber: 'PUR-003',
        invoiceDate: DateTime.now().subtract(const Duration(days: 7)),
        subtotal: 3200.0,
        totalAmount: 3200.0,
        status: 'paid',
        paymentMethod: 'نقدي',
        notes: 'زيوت ومواد غذائية أساسية',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        items: [
          InvoiceItem(
            id: '9',
            invoiceId: '6',
            productId: '5',
            itemName: 'زيت عباد الشمس',
            quantity: 20,
            unitPrice: 85.0,
            totalPrice: 1700.0,
          ),
          InvoiceItem(
            id: '10',
            invoiceId: '6',
            productId: '6',
            itemName: 'أرز مصري',
            quantity: 30,
            unitPrice: 50.0,
            totalPrice: 1500.0,
          ),
        ],
      ),
      
      // فاتورة متأخرة
      Invoice(
        id: '7',
        userId: 'dummy-user',
        type: 'sale',
        customerId: '2',
        customerName: 'فاطمة علي أحمد',
        invoiceNumber: 'SALE-004',
        invoiceDate: DateTime.now().subtract(const Duration(days: 40)),
        subtotal: 275.0,
        tax: 38.5,
        totalAmount: 313.5,
        status: 'overdue',
        paymentMethod: 'آجل',
        notes: 'فاتورة متأخرة - يجب المتابعة',
        dueDate: DateTime.now().subtract(const Duration(days: 10)),
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
        items: [
          InvoiceItem(
            id: '11',
            invoiceId: '7',
            productId: '7',
            itemName: 'شاي',
            quantity: 10,
            unitPrice: 18.0,
            totalPrice: 180.0,
          ),
          InvoiceItem(
            id: '12',
            invoiceId: '7',
            productId: '8',
            itemName: 'سكر',
            quantity: 2,
            unitPrice: 47.5,
            totalPrice: 95.0,
          ),
        ],
      ),
    ];
  }
  
  void addInvoice(Invoice invoice) {
    state = [...state, invoice.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'dummy-user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )];
  }
  
  void updateInvoice(Invoice invoice) {
    state = state.map((i) => 
      i.id == invoice.id ? invoice.copyWith(updatedAt: DateTime.now()) : i
    ).toList();
  }
  
  void deleteInvoice(String id) {
    state = state.where((i) => i.id != id).toList();
  }

  void updateInvoiceStatus(String invoiceId, String newStatus) {
    state = state.map((i) {
      if (i.id == invoiceId) {
        return i.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }
      return i;
    }).toList();
  }
  
  List<Invoice> getSaleInvoices() {
    return state.where((i) => i.type == 'sale').toList();
  }
  
  List<Invoice> getPurchaseInvoices() {
    return state.where((i) => i.type == 'purchase').toList();
  }
  
  List<Invoice> getInvoicesByStatus(String status) {
    return state.where((i) => i.status == status).toList();
  }
  
  List<Invoice> getOverdueInvoices() {
    return state.where((i) => i.isOverdue).toList();
  }
  
  List<Invoice> getPendingInvoices() {
    return state.where((i) => i.isPending).toList();
  }
  
  List<Invoice> searchInvoices(String query) {
    if (query.isEmpty) return state;
    return state.where((i) => 
      i.invoiceNumber.toLowerCase().contains(query.toLowerCase()) ||
      i.clientName.toLowerCase().contains(query.toLowerCase()) ||
      (i.notes?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }
  
  double getTotalSalesAmount() {
    return getSaleInvoices().fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }
  
  double getTotalPurchasesAmount() {
    return getPurchaseInvoices().fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }
  
  double getTotalOutstandingAmount() {
    return getPendingInvoices().fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }
  
  double getTotalOverdueAmount() {
    return getOverdueInvoices().fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }
  
  // إحصائيات شهرية
  double getMonthlySalesAmount() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return getSaleInvoices()
        .where((i) => i.invoiceDate.isAfter(startOfMonth.subtract(const Duration(days: 1))))
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }
  
  double getMonthlyPurchasesAmount() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return getPurchaseInvoices()
        .where((i) => i.invoiceDate.isAfter(startOfMonth.subtract(const Duration(days: 1))))
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }
  
  // الفواتير الأخيرة
  List<Invoice> getRecentInvoices({int limit = 10}) {
    final sortedInvoices = [...state]..sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
    return sortedInvoices.take(limit).toList();
  }
  
  Invoice? getInvoiceById(String id) {
    try {
      return state.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }
}

final invoicesProvider = StateNotifierProvider<InvoicesNotifier, List<Invoice>>((ref) {
  return InvoicesNotifier();
});

// Provider للحصول على إحصائيات الفواتير
final invoicesStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final invoices = ref.watch(invoicesProvider);
  final invoicesNotifier = ref.read(invoicesProvider.notifier);
  
  final saleInvoices = invoicesNotifier.getSaleInvoices();
  final purchaseInvoices = invoicesNotifier.getPurchaseInvoices();
  final pendingInvoices = invoicesNotifier.getPendingInvoices();
  final overdueInvoices = invoicesNotifier.getOverdueInvoices();
  
  return {
    'totalInvoices': invoices.length,
    'saleInvoicesCount': saleInvoices.length,
    'purchaseInvoicesCount': purchaseInvoices.length,
    'pendingInvoicesCount': pendingInvoices.length,
    'overdueInvoicesCount': overdueInvoices.length,
    'totalSalesAmount': invoicesNotifier.getTotalSalesAmount(),
    'totalPurchasesAmount': invoicesNotifier.getTotalPurchasesAmount(),
    'totalOutstandingAmount': invoicesNotifier.getTotalOutstandingAmount(),
    'totalOverdueAmount': invoicesNotifier.getTotalOverdueAmount(),
    'monthlySalesAmount': invoicesNotifier.getMonthlySalesAmount(),
    'monthlyPurchasesAmount': invoicesNotifier.getMonthlyPurchasesAmount(),
    'recentInvoices': invoicesNotifier.getRecentInvoices(limit: 5),
  };
}); 