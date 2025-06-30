import 'package:flutter/material.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'الكل';
  
  final List<String> categories = ['الكل', 'إلكترونيات', 'ملابس', 'طعام', 'مواد بناء', 'أدوات'];
  
  final List<Map<String, dynamic>> products = [
    {
      'id': '001',
      'name': 'لابتوب Dell XPS',
      'category': 'إلكترونيات',
      'stock': 15,
      'price': 25000.0,
    },
    {
      'id': '002', 
      'name': 'تيشيرت قطني',
      'category': 'ملابس',
      'stock': 2,
      'price': 150.0,
    },
    {
      'id': '003',
      'name': 'رز بسمتي 5 كيلو',
      'category': 'طعام',
      'stock': 50,
      'price': 80.0,
    },
    {
      'id': '004',
      'name': 'أسمنت بورتلاند',
      'category': 'مواد بناء',
      'stock': 100,
      'price': 180.0,
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final matchesSearch = product['name'].toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory = _selectedCategory == 'الكل' || product['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'المنتجات',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddProductDialog(),
            icon: const Icon(
              Icons.add,
              color: Colors.blue,
            ),
                ),
        ],
      ),
      body: SafeArea(
        child: Column(
        children: [
            // شريط البحث والفلتر
            Padding(
              padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                  // شريط البحث
                TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                      hintText: 'ابحث عن منتج...',
                      prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // فلتر الفئات
                  SizedBox(
                    height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                          itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = category == _selectedCategory;
                        
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                            label: Text(category),
                                selected: isSelected,
                                onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                                },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.blue.withOpacity(0.2),
                            checkmarkColor: Colors.blue,
                                labelStyle: TextStyle(
                              color: isSelected ? Colors.blue : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
                            ),
                              ),
                            );
                          },
                      ),
                ),
              ],
            ),
          ),
          
            // قائمة المنتجات
          Expanded(
            child: filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductCard(product);
                        },
                      ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
          child: Row(
            children: [
          // صورة المنتج
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
              _getCategoryIcon(product['category']),
                  size: 30,
              color: _getCategoryColor(product['category']),
                ),
              ),
              const SizedBox(width: 16),
              
          // اسم المنتج
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                  'الفئة: ${product['category']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
          // الرصيد
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
                      children: [
                Text(
                  'الرصيد',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product['stock']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد منتجات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة منتجاتك الأولى',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddProductDialog(),
            icon: const Icon(Icons.add),
            label: const Text('إضافة منتج'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'اسم المنتج',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'السعر',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'الكمية',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
          ),
        ],
      ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إضافة المنتج بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'إلكترونيات':
        return Icons.computer;
      case 'ملابس':
        return Icons.checkroom;
      case 'طعام':
        return Icons.restaurant;
      case 'مواد بناء':
        return Icons.construction;
      case 'أدوات':
        return Icons.build;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'إلكترونيات':
        return Colors.blue;
      case 'ملابس':
        return Colors.purple;
      case 'طعام':
        return Colors.orange;
      case 'مواد بناء':
        return Colors.brown;
      case 'أدوات':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
} 