# 🚀 خطوات البداية الفورية - Frontend أولاً

## اليوم الأول: تجهيز State Management

### الخطوة 1: إضافة Riverpod
```bash
flutter pub add flutter_riverpod
```

### الخطوة 2: تحديث main.dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // إزالة Supabase مؤقتاً
  // await Supabase.initialize(...);
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const ProviderScope(child: MyApp()));
}
```

### الخطوة 3: إنشاء Products Provider
```dart
// إنشاء lib/providers/products_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier() : super(_dummyProducts);
  
  // بيانات تجريبية للتطوير
  static final List<Product> _dummyProducts = [
    Product(
      id: '1',
      userId: 'dummy-user',
      name: 'بيبسي كولا',
      description: 'مشروب غازي 330 مل',
      barcode: '123456789',
      purchasePrice: 8.0,
      sellingPrice: 12.0,
      unit: 'قطعة',
      currentStock: 150,
      minimumStock: 20,
      category: 'مشروبات',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '2', 
      userId: 'dummy-user',
      name: 'شيبسي',
      description: 'بطاطس مقلية 50 جم',
      purchasePrice: 4.0,
      sellingPrice: 7.0,
      unit: 'قطعة',
      currentStock: 80,
      minimumStock: 15,
      category: 'أطعمة',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '3',
      userId: 'dummy-user', 
      name: 'لبن جهينة',
      description: 'لبن كامل الدسم 1 لتر',
      purchasePrice: 20.0,
      sellingPrice: 25.0,
      unit: 'قطعة',
      currentStock: 60,
      minimumStock: 10,
      category: 'ألبان',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '4',
      userId: 'dummy-user',
      name: 'خبز أبيض',
      description: 'رغيف خبز أبيض طازج',
      purchasePrice: 1.0,
      sellingPrice: 1.5,
      unit: 'رغيف',
      currentStock: 200,
      minimumStock: 50,
      category: 'مخبوزات',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '5',
      userId: 'dummy-user',
      name: 'زيت عافية',
      description: 'زيت طبخ 1 لتر',
      purchasePrice: 35.0,
      sellingPrice: 45.0,
      unit: 'زجاجة',
      currentStock: 25,
      minimumStock: 5,
      category: 'زيوت',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
  
  void addProduct(Product product) {
    state = [...state, product.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'dummy-user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )];
  }
  
  void updateProduct(Product product) {
    state = state.map((p) => 
      p.id == product.id ? product.copyWith(updatedAt: DateTime.now()) : p
    ).toList();
  }
  
  void deleteProduct(String id) {
    state = state.where((p) => p.id != id).toList();
  }
  
  void updateStock(String productId, int newStock) {
    state = state.map((p) => 
      p.id == productId ? p.copyWith(
        currentStock: newStock,
        updatedAt: DateTime.now(),
      ) : p
    ).toList();
  }
  
  List<Product> getLowStockProducts() {
    return state.where((p) => p.currentStock <= p.minimumStock).toList();
  }
  
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return state;
    return state.where((p) => 
      p.name.toLowerCase().contains(query.toLowerCase()) ||
      p.description.toLowerCase().contains(query.toLowerCase()) ||
      p.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>((ref) {
  return ProductsNotifier();
});
```

### الخطوة 4: إنشاء Sales Provider
```dart
// إنشاء lib/providers/sales_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sale.dart';

class SalesNotifier extends StateNotifier<List<Sale>> {
  SalesNotifier() : super(_dummySales);
  
  static final List<Sale> _dummySales = [
    Sale(
      id: '1',
      userId: 'dummy-user',
      customerName: 'أحمد محمد',
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
      customerName: 'فاطمة علي',
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
      customerName: 'محمود حسن',
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
  ];
  
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
}

final salesProvider = StateNotifierProvider<SalesNotifier, List<Sale>>((ref) {
  return SalesNotifier();
});
```

### الخطوة 5: إنشاء Customers Provider
```dart
// إنشاء lib/providers/customers_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer.dart';

class CustomersNotifier extends StateNotifier<List<Customer>> {
  CustomersNotifier() : super(_dummyCustomers);
  
  static final List<Customer> _dummyCustomers = [
    Customer(
      id: '1',
      userId: 'dummy-user',
      name: 'أحمد محمد سالم',
      email: 'ahmed@example.com',
      phone: '01012345678',
      address: '123 شارع النيل، القاهرة',
      notes: 'عميل VIP - خصم 5%',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Customer(
      id: '2',
      userId: 'dummy-user',
      name: 'فاطمة علي أحمد',
      email: 'fatma@example.com', 
      phone: '01198765432',
      address: '456 شارع الجامعة، الجيزة',
      notes: 'تشتري بكميات كبيرة',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Customer(
      id: '3',
      userId: 'dummy-user',
      name: 'محمود حسن عبدالله',
      phone: '01065432198',
      address: 'حي المعادي، القاهرة',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Customer(
      id: '4',
      userId: 'dummy-user',
      name: 'نورا إبراهيم',
      email: 'nora@example.com',
      phone: '01154321876',
      address: 'شبرا الخيمة، القليوبية',
      notes: 'دفع نقدي فقط',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];
  
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
  
  List<Customer> searchCustomers(String query) {
    if (query.isEmpty) return state;
    return state.where((c) => 
      c.name.toLowerCase().contains(query.toLowerCase()) ||
      (c.phone?.contains(query) ?? false) ||
      (c.email?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }
}

final customersProvider = StateNotifierProvider<CustomersNotifier, List<Customer>>((ref) {
  return CustomersNotifier();
});
```

### الخطوة 6: إنشاء Dashboard Provider
```dart
// إنشاء lib/providers/dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'products_provider.dart';
import 'sales_provider.dart';
import 'customers_provider.dart';

class DashboardData {
  final double totalRevenue;
  final double todayRevenue;
  final int todaySalesCount;
  final int customersCount;
  final int productsCount;
  final int lowStockCount;
  final double profit;
  
  DashboardData({
    required this.totalRevenue,
    required this.todayRevenue,
    required this.todaySalesCount,
    required this.customersCount,
    required this.productsCount,
    required this.lowStockCount,
    required this.profit,
  });
}

final dashboardProvider = Provider<DashboardData>((ref) {
  final products = ref.watch(productsProvider);
  final sales = ref.watch(salesProvider);
  final customers = ref.watch(customersProvider);
  
  final salesNotifier = ref.read(salesProvider.notifier);
  final productsNotifier = ref.read(productsProvider.notifier);
  
  final totalRevenue = salesNotifier.getTotalRevenue();
  final todayRevenue = salesNotifier.getTodayRevenue();
  final todaySalesCount = salesNotifier.getTodaySalesCount();
  final lowStockProducts = productsNotifier.getLowStockProducts();
  
  // حساب الربح التقريبي (إجمالي المبيعات - تكلفة البضاعة)
  final totalCost = products.fold(0.0, (sum, product) => 
    sum + (product.purchasePrice * (100 - product.currentStock))
  );
  final profit = totalRevenue - totalCost;
  
  return DashboardData(
    totalRevenue: totalRevenue,
    todayRevenue: todayRevenue,
    todaySalesCount: todaySalesCount,
    customersCount: customers.length,
    productsCount: products.length,
    lowStockCount: lowStockProducts.length,
    profit: profit,
  );
});
```

### الخطوة 7: تحديث Dashboard Screen
```dart
// تحديث lib/screens/dashboard_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardProvider);
    
    return Scaffold(
      // باقي الكود مع استخدام dashboardData بدلاً من الأرقام الثابتة
      // مثال:
      // Text('${dashboardData.totalRevenue} ج.م')
      // Text('${dashboardData.todaySalesCount} مبيعة')
    );
  }
}
```

---

## اليوم الثاني: ربط Products Screen

### تحديث Products Screen
```dart
// تحديث lib/screens/products_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final productsNotifier = ref.read(productsProvider.notifier);
    
    final filteredProducts = _searchQuery.isEmpty 
      ? products 
      : productsNotifier.searchProducts(_searchQuery);
    
    return Scaffold(
      // باقي الكود مع استخدام filteredProducts
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _showAddProductDialog(BuildContext context) {
    // عرض dialog لإضافة منتج جديد
    // عند الضغط على Save، استخدم:
    // ref.read(productsProvider.notifier).addProduct(newProduct);
  }
}
```

---

## اليوم الثالث: ربط POS Screen

### تحديث POS Screen لحفظ المبيعات
```dart
// تحديث lib/screens/pos_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';
import '../providers/sales_provider.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  final List<CartItem> _cartItems = [];
  
  void _completeSale() {
    if (_cartItems.isEmpty) return;
    
    final sale = Sale(
      id: '',
      userId: 'dummy-user',
      customerName: _selectedCustomer?.name ?? 'عميل نقدي',
      customerId: _selectedCustomer?.id,
      totalAmount: _calculateTotal(),
      discountAmount: _discountAmount,
      taxAmount: _calculateTax(),
      finalAmount: _calculateFinalAmount(),
      paymentMethod: _paymentMethod,
      status: 'مكتملة',
      saleDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // إضافة البيع
    ref.read(salesProvider.notifier).addSale(sale);
    
    // تحديث المخزون
    for (final item in _cartItems) {
      ref.read(productsProvider.notifier).updateStock(
        item.productId,
        item.currentStock - item.quantity,
      );
    }
    
    // مسح العربة
    setState(() {
      _cartItems.clear();
    });
    
    // رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إتمام البيع بنجاح')),
    );
  }
}
```

---

## التجربة الآن:

```bash
# تشغيل التطبيق
flutter run

# الآن التطبيق هيعمل مع بيانات تجريبية:
# - Dashboard يعرض عدد المنتجات الحقيقي
# - Products يعرض المنتجات ويمكن إضافة/تعديل/حذف
# - POS يشتغل مع المنتجات الموجودة
# - كل شيء functional بدون database
```

**هل تبدأ بتطبيق الخطوات دي؟** 🚀 