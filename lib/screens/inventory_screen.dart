import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../providers/products_provider.dart';
import '../providers/inventory_provider.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with TickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedFilter = 'الكل';
  late TabController _tabController;

  final List<String> _filters = [
    'الكل',
    'مخزون منخفض',
    'منتهي الصلاحية',
    'ينتهي قريباً',
    'غير متوفر'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    return products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (product.barcode?.contains(_searchQuery) ?? false);

      switch (_selectedFilter) {
        case 'مخزون منخفض':
          return matchesSearch && product.isLowStock;
        case 'منتهي الصلاحية':
          return matchesSearch && product.isExpired;
        case 'ينتهي قريباً':
          return matchesSearch && product.isExpiringSoon;
        case 'غير متوفر':
          return matchesSearch && product.currentStock == 0;
        default:
          return matchesSearch;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.inventory_2_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            const Text('إدارة المخزون'),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'نظرة عامة', icon: Icon(Icons.dashboard_rounded)),
            Tab(text: 'قائمة المنتجات', icon: Icon(Icons.list_rounded)),
            Tab(text: 'حركة المخزون', icon: Icon(Icons.history_rounded)),
        ],
        ),
      ),
      body: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildProductsListTab(),
          _buildInventoryMovementsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    final products = ref.watch(productsProvider);
    final productsStats = ref.watch(productsStatsProvider);
    final inventoryStats = ref.watch(inventoryStatsProvider);
    
    final totalProducts = productsStats['totalProducts'] ?? 0;
    final lowStockProducts = productsStats['lowStockCount'] ?? 0;
    final totalInventoryValue = productsStats['totalInventoryValue'] ?? 0.0;
    final totalMovements = inventoryStats['totalMovements'] ?? 0;
    
    final expiredProducts = products.where((p) => p.isExpired).length;
    final expiringSoonProducts = products.where((p) => p.isExpiringSoon).length;
    final outOfStockProducts = products.where((p) => p.currentStock == 0).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.dashboard_rounded, color: AppTheme.primaryColor, size: 32),
              const SizedBox(width: 12),
          const Text(
            'ملخص المخزون',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
            ],
          ),
          const SizedBox(height: 20),

          // بطاقات الإحصائيات الأساسية
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildStatCard(
                'إجمالي المنتجات',
                totalProducts.toString(),
                Icons.inventory_2_rounded,
                AppTheme.primaryColor,
              ),
              _buildStatCard(
                'قيمة المخزون',
                '${totalInventoryValue.toStringAsFixed(0)} جنيه',
                Icons.account_balance_wallet_rounded,
                AppTheme.successColor,
              ),
              _buildStatCard(
                'مخزون منخفض',
                lowStockProducts.toString(),
                Icons.warning_rounded,
                AppTheme.warningColor,
              ),
              _buildStatCard(
                'حركات اليوم',
                totalMovements.toString(),
                Icons.swap_horiz_rounded,
                AppTheme.accentColor,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // إحصائيات حركة المخزون
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics_rounded, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      'إحصائيات الحركة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStatCard(
                        'إدخال',
                        '${inventoryStats['totalInMovements'] ?? 0}',
                        AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMiniStatCard(
                        'إخراج',
                        '${inventoryStats['totalOutMovements'] ?? 0}',
                        AppTheme.errorColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMiniStatCard(
                        'تعديلات',
                        '${inventoryStats['totalAdjustments'] ?? 0}',
                        AppTheme.warningColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // تنبيهات
          if (expiredProducts > 0 ||
              expiringSoonProducts > 0 ||
              lowStockProducts > 0) ...[
            Row(
              children: [
                Icon(Icons.notification_important_rounded, color: AppTheme.errorColor),
                const SizedBox(width: 8),
            const Text(
              'تنبيهات مهمة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (expiredProducts > 0)
              _buildAlertCard(
                'منتجات منتهية الصلاحية',
                '$expiredProducts منتج',
                Icons.dangerous_rounded,
                AppTheme.errorColor,
                () => setState(() {
                  _selectedFilter = 'منتهي الصلاحية';
                  _tabController.animateTo(1);
                }),
              ),
            if (expiringSoonProducts > 0)
              _buildAlertCard(
                'منتجات تنتهي قريباً',
                '$expiringSoonProducts منتج',
                Icons.schedule_rounded,
                AppTheme.warningColor,
                () => setState(() {
                  _selectedFilter = 'ينتهي قريباً';
                  _tabController.animateTo(1);
                }),
              ),
            if (lowStockProducts > 0)
              _buildAlertCard(
                'مخزون منخفض',
                '$lowStockProducts منتج',
                Icons.warning_rounded,
                AppTheme.warningColor,
                () => setState(() {
                  _selectedFilter = 'مخزون منخفض';
                  _tabController.animateTo(1);
                }),
              ),
          ],

          const SizedBox(height: 24),

          // أعلى المنتجات قيمة
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: AppTheme.successColor),
              const SizedBox(width: 8),
          const Text(
            'أعلى المنتجات قيمة في المخزون',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...(() {
            var sortedProducts = products
                .where((p) => p.currentStock > 0)
                .toList()
                  ..sort((a, b) => b.totalStockValue.compareTo(a.totalStockValue));
            
            if (sortedProducts.length > 5) {
              sortedProducts = sortedProducts.sublist(0, 5);
            }
            
            return sortedProducts.map<Widget>((product) => Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.inventory_2_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('${product.currentStock} ${product.unit}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                      '${product.totalStockValue.toStringAsFixed(0)} جنيه',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
                          ),
                        ),
                        Text(
                          '${product.sellingPrice.toStringAsFixed(0)} ج/وحدة',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList();
          })(),
        ],
      ),
    );
  }

  Widget _buildProductsListTab() {
    final products = ref.watch(productsProvider);
    final filteredProducts = _getFilteredProducts(products);

    return Column(
      children: [
        // شريط البحث والفلترة
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'البحث بالاسم أو الباركود...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.filter_list_rounded, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  const Text('الفلتر: ', style: TextStyle(fontWeight: FontWeight.w600)),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFilter,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _filters.map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(filter),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedFilter = value!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // قائمة المنتجات
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty 
                            ? Icons.search_off_rounded
                            : Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty 
                            ? 'لا توجد نتائج للبحث'
                            : 'لا توجد منتجات',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return _buildProductListTile(product);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInventoryMovementsTab() {
    final movements = ref.watch(inventoryProvider);
    final inventoryNotifier = ref.read(inventoryProvider.notifier);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addInventoryMovement,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('إضافة حركة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _exportInventoryReport,
                  icon: const Icon(Icons.file_download_rounded),
                  label: const Text('تصدير تقرير'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: movements.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد حركات مخزون',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: movements.length,
            itemBuilder: (context, index) {
                    final movement = movements[movements.length - 1 - index]; // عرض الأحدث أولاً
                    return _buildMovementTile(movement);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
              fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          const SizedBox(height: 4),
            Text(
              title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
    );
  }

  Widget _buildMiniStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
        onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductListTile(Product product) {
    Color? statusColor;
    String? statusText;

    if (product.isExpired) {
      statusColor = AppTheme.errorColor;
      statusText = 'منتهي الصلاحية';
    } else if (product.isExpiringSoon) {
      statusColor = AppTheme.warningColor;
      statusText = 'ينتهي قريباً';
    } else if (product.currentStock == 0) {
      statusColor = AppTheme.errorColor;
      statusText = 'غير متوفر';
    } else if (product.isLowStock) {
      statusColor = AppTheme.warningColor;
      statusText = 'مخزون منخفض';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
            if (statusText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor!.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _adjustStock(product),
                  icon: Icon(Icons.edit_rounded, color: AppTheme.primaryColor),
                  tooltip: 'تعديل المخزون',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'المخزون',
                    '${product.currentStock} ${product.unit}',
                    Icons.inventory_rounded,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'القيمة',
                    '${product.totalStockValue.toStringAsFixed(0)} جنيه',
                    Icons.account_balance_wallet_rounded,
                  ),
                ),
              ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMovementTile(InventoryMovement movement) {
    Color typeColor;
    IconData typeIcon;
    String typeText;

    switch (movement.type) {
      case 'in':
        typeColor = AppTheme.successColor;
        typeIcon = Icons.add_circle_rounded;
        typeText = 'إدخال';
        break;
      case 'out':
        typeColor = AppTheme.errorColor;
        typeIcon = Icons.remove_circle_rounded;
        typeText = 'إخراج';
        break;
      case 'adjustment':
        typeColor = AppTheme.warningColor;
        typeIcon = Icons.edit_rounded;
        typeText = 'تعديل';
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.help_rounded;
        typeText = 'غير محدد';
    }

    final timeAgo = _getTimeAgo(movement.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(typeIcon, color: typeColor, size: 20),
        ),
        title: Text(
          movement.productName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(movement.reason),
            Text(
              timeAgo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${movement.quantity > 0 ? '+' : ''}${movement.quantity}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: typeColor,
                fontSize: 16,
              ),
            ),
            Text(
              typeText,
              style: TextStyle(
                fontSize: 12,
                color: typeColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  void _adjustStock(Product product) {
    final controller = TextEditingController(text: product.currentStock.toString());
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل مخزون ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'المخزون الجديد',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب التعديل',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(controller.text) ?? product.currentStock;
              final reason = reasonController.text.isNotEmpty 
                  ? reasonController.text 
                  : 'تعديل مخزون';
              
              _updateProductStock(product, newStock, reason);
                Navigator.of(context).pop();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _updateProductStock(Product product, int newStock, String reason) {
    final difference = newStock - product.currentStock;
    
    // تحديث المنتج
    final updatedProduct = product.copyWith(currentStock: newStock);
    ref.read(productsProvider.notifier).updateProduct(updatedProduct);
    
    // إضافة حركة مخزون
    if (difference != 0) {
      final movement = InventoryMovement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: product.id!,
        productName: product.name,
        type: 'adjustment',
        quantity: difference,
        unitPrice: product.purchasePrice,
        totalValue: difference * product.purchasePrice,
        reason: reason,
        reference: 'ADJ-${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        userId: 'dummy-user',
      );
      
      ref.read(inventoryProvider.notifier).addMovement(movement);
    }
    
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث المخزون بنجاح')),
        );
      }

  void _addInventoryMovement() {
    // يمكن إضافة dialog لإضافة حركة مخزون جديدة
        ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة هذه الميزة قريباً')),
        );
  }

  void _exportInventoryReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة تصدير التقارير قريباً')),
    );
  }
}
