import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier() : super(_generateDummyProducts());
  
  static List<Product> _generateDummyProducts() {
    return [
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
        barcode: '987654321',
        purchasePrice: 4.0,
        sellingPrice: 7.0,
        unit: 'قطعة',
        currentStock: 80,
        minimumStock: 15,
        category: 'وجبات خفيفة',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '3',
        userId: 'dummy-user',
        name: 'لبن جهينة',
        description: 'لبن كامل الدسم 1 لتر',
        barcode: '456789123',
        purchasePrice: 20.0,
        sellingPrice: 25.0,
        unit: 'علبة',
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
        barcode: '789123456',
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
        barcode: '321654987',
        purchasePrice: 35.0,
        sellingPrice: 45.0,
        unit: 'زجاجة',
        currentStock: 25,
        minimumStock: 5,
        category: 'زيوت',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '6',
        userId: 'dummy-user',
        name: 'أرز أبيض',
        description: 'أرز أبيض ممتاز 1 كيلو',
        barcode: '654987321',
        purchasePrice: 15.0,
        sellingPrice: 20.0,
        unit: 'كيلو',
        currentStock: 100,
        minimumStock: 20,
        category: 'حبوب',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '7',
        userId: 'dummy-user',
        name: 'شاي ليبتون',
        description: 'شاي أسود 50 كيس',
        barcode: '147258369',
        purchasePrice: 18.0,
        sellingPrice: 23.0,
        unit: 'علبة',
        currentStock: 45,
        minimumStock: 8,
        category: 'مشروبات ساخنة',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '8',
        userId: 'dummy-user',
        name: 'سكر أبيض',
        description: 'سكر أبيض 1 كيلو',
        barcode: '963852741',
        purchasePrice: 12.0,
        sellingPrice: 16.0,
        unit: 'كيلو',
        currentStock: 75,
        minimumStock: 15,
        category: 'توابل',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
  
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
      (p.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
      (p.category?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
      (p.barcode?.contains(query) ?? false)
    ).toList();
  }
  
  double getTotalInventoryValue() {
    return state.fold(0.0, (sum, product) => 
      sum + (product.purchasePrice * product.currentStock)
    );
  }
  
  List<String> getCategories() {
    return state
        .map((p) => p.category)
        .where((category) => category != null)
        .cast<String>()
        .toSet()
        .toList();
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>((ref) {
  return ProductsNotifier();
});

// Provider للحصول على إحصائيات المنتجات
final productsStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final products = ref.watch(productsProvider);
  final productsNotifier = ref.read(productsProvider.notifier);
  
  final lowStockProducts = productsNotifier.getLowStockProducts();
  final totalInventoryValue = productsNotifier.getTotalInventoryValue();
  
  return {
    'totalProducts': products.length,
    'lowStockCount': lowStockProducts.length,
    'totalInventoryValue': totalInventoryValue,
    'categories': productsNotifier.getCategories().length,
  };
}); 