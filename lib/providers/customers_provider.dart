import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer.dart';

class CustomersNotifier extends StateNotifier<List<Customer>> {
  CustomersNotifier() : super(_generateDummyCustomers());
  
  static List<Customer> _generateDummyCustomers() {
    return [
      Customer(
        id: '1',
        userId: 'dummy-user',
        name: 'أحمد محمد سالم',
        phone: '01012345678',
        email: 'ahmed.salem@gmail.com',
        address: 'شارع الثورة، المنصورة، الدقهلية',
        balance: -250.0, // مديون بـ 250 جنيه
        creditLimit: 1000.0,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Customer(
        id: '2',
        userId: 'dummy-user',
        name: 'فاطمة علي أحمد',
        phone: '01198765432',
        email: 'fatma.ali@yahoo.com',
        address: 'شارع الجمهورية، طنطا، الغربية',
        balance: 150.0, // عندها رصيد 150 جنيه
        creditLimit: 500.0,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Customer(
        id: '3',
        userId: 'dummy-user',
        name: 'محمود حسن عبدالله',
        phone: '01087654321',
        email: 'mahmoud.hassan@hotmail.com',
        address: 'شارع الحرية، دمياط الجديدة، دمياط',
        balance: -100.0, // مديون بـ 100 جنيه
        creditLimit: 2000.0,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Customer(
        id: '4',
        userId: 'dummy-user',
        name: 'نورا إبراهيم محمد',
        phone: '01156789123',
        email: 'nora.ibrahim@gmail.com',
        address: 'شارع البحر، رأس البر، دمياط',
        balance: 0.0, // مالهاش عليها
        creditLimit: 800.0,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Customer(
        id: '5',
        userId: 'dummy-user',
        name: 'خالد أحمد سالم',
        phone: '01223456789',
        email: 'khaled.ahmed@outlook.com',
        address: 'شارع النيل، المنيا الجديدة، المنيا',
        balance: -500.0, // مديون بـ 500 جنيه
        creditLimit: 1500.0,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Customer(
        id: '6',
        userId: 'dummy-user',
        name: 'سارة محمد عبدالعزيز',
        phone: '01134567890',
        address: 'شارع الكورنيش، الأقصر، الأقصر',
        balance: 75.0, // عندها رصيد 75 جنيه
        creditLimit: 300.0,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Customer(
        id: '7',
        userId: 'dummy-user',
        name: 'عمر حسام الدين',
        phone: '01045678901',
        email: 'omar.hosam@gmail.com',
        address: 'شارع الهرم، الجيزة، الجيزة',
        balance: -300.0, // مديون بـ 300 جنيه
        creditLimit: 1200.0,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Customer(
        id: '8',
        userId: 'dummy-user',
        name: 'ريم أحمد فاروق',
        phone: '01567890123',
        email: 'reem.farouk@yahoo.com',
        address: 'شارع الخليفة، حلوان، القاهرة',
        balance: 200.0, // عندها رصيد 200 جنيه
        creditLimit: 600.0,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }
  
  void addCustomer(Customer customer) {
    state = [...state, customer.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'dummy-user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )];
  }
  
  void updateCustomer(Customer customer) {
    state = state.map((c) => 
      c.id == customer.id ? customer.copyWith(updatedAt: DateTime.now()) : c
    ).toList();
  }
  
  void deleteCustomer(String id) {
    state = state.where((c) => c.id != id).toList();
  }
  
  void updateBalance(String customerId, double newBalance) {
    state = state.map((c) => 
      c.id == customerId ? c.copyWith(
        balance: newBalance,
        updatedAt: DateTime.now(),
      ) : c
    ).toList();
  }
  
  List<Customer> getDebtorCustomers() {
    return state.where((c) => c.balance < 0).toList();
  }
  
  List<Customer> getCreditCustomers() {
    return state.where((c) => c.balance > 0).toList();
  }
  
  List<Customer> searchCustomers(String query) {
    if (query.isEmpty) return state;
    return state.where((c) => 
      c.name.toLowerCase().contains(query.toLowerCase()) ||
      (c.phone?.contains(query) ?? false) ||
      (c.email?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }
  
  double getTotalDebt() {
    return state.where((c) => c.balance < 0)
        .fold(0.0, (sum, customer) => sum + customer.balance.abs());
  }
  
  double getTotalCredit() {
    return state.where((c) => c.balance > 0)
        .fold(0.0, (sum, customer) => sum + customer.balance);
  }
  
  Customer? getCustomerById(String id) {
    try {
      return state.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}

final customersProvider = StateNotifierProvider<CustomersNotifier, List<Customer>>((ref) {
  return CustomersNotifier();
});

// Provider للحصول على إحصائيات العملاء
final customersStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final customers = ref.watch(customersProvider);
  final customersNotifier = ref.read(customersProvider.notifier);
  
  final debtorCustomers = customersNotifier.getDebtorCustomers();
  final creditCustomers = customersNotifier.getCreditCustomers();
  final totalDebt = customersNotifier.getTotalDebt();
  final totalCredit = customersNotifier.getTotalCredit();
  
  return {
    'totalCustomers': customers.length,
    'debtorCustomers': debtorCustomers.length,
    'creditCustomers': creditCustomers.length,
    'totalDebt': totalDebt,
    'totalCredit': totalCredit,
    'netBalance': totalCredit - totalDebt,
  };
}); 