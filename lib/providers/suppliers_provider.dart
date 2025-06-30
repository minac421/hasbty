import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/supplier.dart';

class SuppliersNotifier extends StateNotifier<List<Supplier>> {
  SuppliersNotifier() : super(_generateDummySuppliers());
  
  static List<Supplier> _generateDummySuppliers() {
    return [
      Supplier(
        id: '1',
        userId: 'dummy-user',
        name: 'شركة النور للمواد الغذائية',
        contactPerson: 'أحمد النور',
        phone: '01012345678',
        email: 'info@alnoor-foods.com',
        address: 'شارع الثورة، المنصورة، الدقهلية',
        creditLimit: 50000.0,
        currentBalance: -15000.0, // مدين للشركة بـ 15 ألف
        paymentTerms: '30 يوم',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Supplier(
        id: '2',
        userId: 'dummy-user',
        name: 'مؤسسة الخير للتوريدات',
        contactPerson: 'فاطمة الخير',
        phone: '01198765432',
        email: 'orders@alkhayr.net',
        address: 'شارع الجمهورية، طنطا، الغربية',
        creditLimit: 30000.0,
        currentBalance: 5000.0, // دفعنا له زيادة 5 آلاف
        paymentTerms: '15 يوم',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Supplier(
        id: '3',
        userId: 'dummy-user',
        name: 'شركة الأهرام للألبان',
        contactPerson: 'محمود الأهرام',
        phone: '01087654321',
        email: 'sales@ahram-dairy.com',
        address: 'شارع الهرم، الجيزة، الجيزة',
        creditLimit: 25000.0,
        currentBalance: -8500.0, // مدين بـ 8.5 ألف
        paymentTerms: '45 يوم',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Supplier(
        id: '4',
        userId: 'dummy-user',
        name: 'مصنع الفجر للمخبوزات',
        contactPerson: 'نورا الفجر',
        phone: '01156789123',
        email: 'production@alfajr-bakery.com',
        address: 'شارع الصناعة، العاشر من رمضان، الشرقية',
        creditLimit: 20000.0,
        currentBalance: 0.0, // متساوي
        paymentTerms: '21 يوم',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Supplier(
        id: '5',
        userId: 'dummy-user',
        name: 'شركة النيل للزيوت',
        contactPerson: 'خالد النيل',
        phone: '01223456789',
        email: 'info@nile-oils.com',
        address: 'شارع الكورنيش، أسوان، أسوان',
        creditLimit: 35000.0,
        currentBalance: -12000.0, // مدين بـ 12 ألف
        paymentTerms: '60 يوم',
        createdAt: DateTime.now().subtract(const Duration(days: 75)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Supplier(
        id: '6',
        userId: 'dummy-user',
        name: 'مؤسسة الدلتا للحبوب',
        contactPerson: 'سارة الدلتا',
        phone: '01134567890',
        address: 'شارع المحطة، كفر الشيخ، كفر الشيخ',
        creditLimit: 40000.0,
        currentBalance: 2500.0, // دفعنا له زيادة 2.5 ألف
        paymentTerms: '30 يوم',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Supplier(
        id: '7',
        userId: 'dummy-user',
        name: 'شركة البحر المتوسط للتوابل',
        contactPerson: 'عمر البحر',
        phone: '01045678901',
        email: 'spices@mediterranean.com',
        address: 'شارع الميناء، الإسكندرية، الإسكندرية',
        creditLimit: 15000.0,
        currentBalance: -4500.0, // مدين بـ 4.5 ألف
        paymentTerms: '14 يوم',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Supplier(
        id: '8',
        userId: 'dummy-user',
        name: 'مصنع الصعيد للمشروبات',
        contactPerson: 'ريم الصعيد',
        phone: '01567890123',
        email: 'beverages@saaeed.com',
        address: 'شارع الصناعة، قنا، قنا',
        creditLimit: 28000.0,
        currentBalance: -7800.0, // مدين بـ 7.8 ألف
        paymentTerms: '30 يوم',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }
  
  void addSupplier(Supplier supplier) {
    state = [...state, supplier.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'dummy-user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )];
  }
  
  void updateSupplier(Supplier supplier) {
    state = state.map((s) => 
      s.id == supplier.id ? supplier.copyWith(updatedAt: DateTime.now()) : s
    ).toList();
  }
  
  void deleteSupplier(String id) {
    state = state.where((s) => s.id != id).toList();
  }
  
  void updateBalance(String supplierId, double newBalance) {
    state = state.map((s) => 
      s.id == supplierId ? s.copyWith(
        currentBalance: newBalance,
        updatedAt: DateTime.now(),
      ) : s
    ).toList();
  }
  
  List<Supplier> getDebtorSuppliers() {
    return state.where((s) => s.currentBalance < 0).toList();
  }
  
  List<Supplier> getCreditSuppliers() {
    return state.where((s) => s.currentBalance > 0).toList();
  }
  
  List<Supplier> searchSuppliers(String query) {
    if (query.isEmpty) return state;
    return state.where((s) => 
      s.name.toLowerCase().contains(query.toLowerCase()) ||
      (s.contactPerson?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
      (s.phone?.contains(query) ?? false) ||
      (s.email?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }
  
  double getTotalDebt() {
    return state.where((s) => s.currentBalance < 0)
        .fold(0.0, (sum, supplier) => sum + supplier.currentBalance.abs());
  }
  
  double getTotalCredit() {
    return state.where((s) => s.currentBalance > 0)
        .fold(0.0, (sum, supplier) => sum + supplier.currentBalance);
  }
  
  Supplier? getSupplierById(String id) {
    try {
      return state.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<String> getSupplierNames() {
    return state.map((s) => s.name).toList();
  }
}

final suppliersProvider = StateNotifierProvider<SuppliersNotifier, List<Supplier>>((ref) {
  return SuppliersNotifier();
});

// Provider للحصول على إحصائيات الموردين
final suppliersStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final suppliers = ref.watch(suppliersProvider);
  final suppliersNotifier = ref.read(suppliersProvider.notifier);
  
  final debtorSuppliers = suppliersNotifier.getDebtorSuppliers();
  final creditSuppliers = suppliersNotifier.getCreditSuppliers();
  final totalDebt = suppliersNotifier.getTotalDebt();
  final totalCredit = suppliersNotifier.getTotalCredit();
  
  return {
    'totalSuppliers': suppliers.length,
    'debtorSuppliers': debtorSuppliers.length,
    'creditSuppliers': creditSuppliers.length,
    'totalDebt': totalDebt,
    'totalCredit': totalCredit,
    'netBalance': totalCredit - totalDebt,
  };
}); 