import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../providers/products_provider.dart';
import '../providers/customers_provider.dart';
import '../providers/sales_provider.dart';
import '../providers/user_provider.dart';
import '../services/feature_manager_service.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  List<SaleItem> _cartItems = [];
  Customer? _selectedCustomer;
  String _paymentMethod = 'نقدي';
  double _discountAmount = 0.0;
  double _taxRate = 0.14;
  String _searchQuery = '';
  bool _isProcessing = false;
  bool _isCartVisible = false; // للموبايل - للتبديل بين المنتجات والعربة

  final List<String> _paymentMethods = ['نقدي', 'بطاقة', 'آجل', 'تحويل بنكي'];
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get _taxAmount => (_subtotal - _discountAmount) * _taxRate;
  double get _total => _subtotal - _discountAmount + _taxAmount;
  int get _totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  void _addToCart(Product product) {
    final existingIndex = _cartItems.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex >= 0) {
      if (_cartItems[existingIndex].quantity < product.currentStock) {
      setState(() {
          _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
            quantity: _cartItems[existingIndex].quantity + 1,
            totalPrice: _cartItems[existingIndex].unitPrice * (_cartItems[existingIndex].quantity + 1),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الكمية المطلوبة غير متوفرة في المخزون')),
        );
      }
    } else {
      setState(() {
        _cartItems.add(SaleItem(
          saleId: '',
          productId: product.id!,
          productName: product.name,
          quantity: 1,
          unitPrice: product.sellingPrice,
          totalPrice: product.sellingPrice,
          purchasePrice: product.purchasePrice,
        ));
      });
      
      // في الموبايل، اعرض العربة تلقائياً بعد إضافة منتج
      if (ResponsiveHelper.isMobile(context)) {
        setState(() => _isCartVisible = true);
      }
    }
    
    // إشعار بصري للإضافة
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
        content: Text('تم إضافة ${product.name} للعربة'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppTheme.successColor,
          ),
        );
      }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _updateCartItemQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(index);
      return;
    }
    
    final products = ref.read(productsProvider);
    final product = products.firstWhere((p) => p.id == _cartItems[index].productId);
    
    if (newQuantity > product.currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الكمية المطلوبة غير متوفرة في المخزون')),
      );
      return;
    }
    
    setState(() {
      _cartItems[index] = _cartItems[index].copyWith(
        quantity: newQuantity,
        totalPrice: _cartItems[index].unitPrice * newQuantity,
      );
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _selectedCustomer = null;
      _discountAmount = 0.0;
      _discountController.clear();
      _notesController.clear();
    });
  }

  Future<void> _processSale() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('العربة فارغة')),
      );
      return;
    }

    // التحقق من حدود المبيعات الشهرية
    final userPlan = ref.read(userPlanProvider);
    final sales = ref.read(salesProvider);
    final featureManager = ref.read(featureManagerProvider);
    
    // حساب عدد المبيعات في الشهر الحالي
    final now = DateTime.now();
    final currentMonthSales = sales.where((sale) {
      return sale.saleDate.year == now.year && sale.saleDate.month == now.month;
    }).length;
    
    // التحقق من الحدود
    final canProceed = FeatureManagerService.limitGate(
      context,
      userPlan,
      'sales_this_month',
      currentMonthSales,
    );
    
    if (!canProceed) return;

    setState(() => _isProcessing = true);

    try {
      final sale = Sale(
        userId: 'dummy-user',
        customerId: _selectedCustomer?.id,
        customerName: _selectedCustomer?.name ?? 'عميل نقدي',
        totalAmount: _subtotal,
        discountAmount: _discountAmount,
        taxAmount: _taxAmount,
        finalAmount: _total,
        paymentMethod: _paymentMethod,
        status: 'مكتملة',
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        saleDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: _cartItems,
      );

      ref.read(salesProvider.notifier).addSale(sale);

      // تحديث مخزون المنتجات
      for (final item in _cartItems) {
        final products = ref.read(productsProvider);
        final product = products.firstWhere((p) => p.id == item.productId);
        final updatedProduct = product.copyWith(
          currentStock: product.currentStock - item.quantity,
          updatedAt: DateTime.now(),
        );
        ref.read(productsProvider.notifier).updateProduct(updatedProduct);
      }

      _clearCart();
      setState(() => _isCartVisible = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنجاز البيع بنجاح! 🎉'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في معالجة البيع: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final customers = ref.watch(customersProvider);
    final availableProducts = products.where((p) => p.currentStock > 0).toList();
    final filteredProducts = availableProducts.where((p) =>
      _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            AppTheme.iconContainer(
              icon: Icons.point_of_sale_rounded,
                color: Colors.white,
                size: 24,
              containerSize: 40,
            ),
            const SizedBox(width: 12),
            const Text('نقطة البيع'),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // زر العربة للموبايل
          if (ResponsiveHelper.isMobile(context))
          IconButton(
            icon: Stack(
              children: [
                  Icon(
                    _isCartVisible ? Icons.storefront : Icons.shopping_cart_rounded,
                    color: _isCartVisible ? AppTheme.accentColor : Colors.white,
                  ),
                if (_cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _totalItems.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
              onPressed: () => setState(() => _isCartVisible = !_isCartVisible),
              tooltip: _isCartVisible ? 'عرض المنتجات' : 'عرض العربة',
          ),
        ],
      ),
      body: ResponsiveHelper.responsiveBuilder(
        context: context,
        mobile: _buildMobileLayout(filteredProducts, customers),
        tablet: _buildTabletLayout(filteredProducts, customers),
        desktop: _buildDesktopLayout(filteredProducts, customers),
      ),
      // شريط سفلي للموبايل يعرض ملخص سريع
      bottomNavigationBar: ResponsiveHelper.isMobile(context) && _cartItems.isNotEmpty
          ? Container(
              padding: ResponsiveHelper.getScreenPadding(context),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
              child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        Text(
                          '${_totalItems} عنصر',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${_total.toStringAsFixed(0)} جنيه',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : () {
                      if (_isCartVisible) {
                        _processSale();
                      } else {
                        setState(() => _isCartVisible = true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(_isCartVisible ? 'إتمام البيع' : 'عرض العربة'),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  // تخطيط الموبايل
  Widget _buildMobileLayout(List<Product> filteredProducts, List<Customer> customers) {
    return _isCartVisible 
        ? _buildCartView(customers, isMobile: true)
        : _buildProductsView(filteredProducts, isMobile: true);
  }

  // تخطيط التابلت
  Widget _buildTabletLayout(List<Product> filteredProducts, List<Customer> customers) {
    return Row(
              children: [
                Expanded(
          flex: 3,
          child: _buildProductsView(filteredProducts),
        ),
                      Container(
          width: 350,
          child: _buildCartView(customers),
        ),
      ],
    );
  }

  // تخطيط الديسكتوب
  Widget _buildDesktopLayout(List<Product> filteredProducts, List<Customer> customers) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildProductsView(filteredProducts),
        ),
        Container(
          width: 400,
          child: _buildCartView(customers),
        ),
      ],
    );
  }

  Widget _buildProductsView(List<Product> filteredProducts, {bool isMobile = false}) {
    final crossAxisCount = ResponsiveHelper.getGridColumns(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 3,
    );

    return Container(
      color: Colors.white,
                          child: Column(
                            children: [
                              // شريط البحث
          Container(
            padding: ResponsiveHelper.getScreenPadding(context),
            child: TextField(
                                decoration: InputDecoration(
                hintText: 'البحث في المنتجات...',
                                  prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() => _searchQuery = ''),
                                        )
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                          ),
                          onChanged: (value) => setState(() => _searchQuery = value),
                              ),
          ),
          
          // إحصائيات سريعة للموبايل
          if (isMobile) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                                children: [
                  Expanded(
                    child: _buildQuickStat(
                      'المنتجات المتاحة',
                      filteredProducts.length.toString(),
                      Icons.inventory_rounded,
                      AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                    child: _buildQuickStat(
                      'في العربة',
                      _totalItems.toString(),
                      Icons.shopping_cart_rounded,
                      AppTheme.successColor,
                    ),
                  ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // بطاقة المبيعات المتبقية هذا الشهر
                  _buildMonthlyLimitCard(),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            // للتابلت والديسكتوب - عرض البطاقة في مكان آخر
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildMonthlyLimitCard(),
            ),
          ],
          
          // قائمة المنتجات
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('لا توجد منتجات متاحة للبيع', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: ResponsiveHelper.getScreenPadding(context),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: ResponsiveHelper.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
                      mainAxisSpacing: ResponsiveHelper.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
                    ),
                    itemCount: filteredProducts.length,
                                        itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                              ),
                            ],
                        ),
                      ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _addToCart(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
                                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.inventory_2_rounded, color: AppTheme.primaryColor, size: 32),
              ),
              const SizedBox(height: 12),
                                      Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                                      Text(
                    '${product.sellingPrice.toStringAsFixed(2)} جنيه',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'متوفر: ${product.currentStock}',
                    style: TextStyle(
                      fontSize: 12,
                      color: product.currentStock <= product.minimumStock
                          ? AppTheme.warningColor
                          : AppTheme.successColor,
                    ),
                  ),
                ],
                      ),
                    ],
                    ),
                  ),
                ),
    );
  }
                
  Widget _buildCartView(List<Customer> customers, {bool isMobile = false}) {
    return Container(
                    decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(-2, 0),
                      ),
                    ],
                    ),
                    child: Column(
                      children: [
          // رأس العربة
                        Container(
                          padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.05),
                              AppTheme.primaryColor.withOpacity(0.02),
                            ],
                          ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                        ),
                          child: Column(
                            children: [
                            // اختيار العميل
                DropdownButtonFormField<Customer>(
                                value: _selectedCustomer,
                                decoration: InputDecoration(
                                  labelText: 'العميل',
                                  prefixIcon: Icon(Icons.person_rounded, color: AppTheme.primaryColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                items: [
                    const DropdownMenuItem<Customer>(value: null, child: Text('عميل نقدي')),
                    ...customers.map((customer) => DropdownMenuItem<Customer>(
                                      value: customer,
                                      child: Text(customer.name),
                    )),
                                ],
                                onChanged: (customer) => setState(() => _selectedCustomer = customer),
                            ),
                            const SizedBox(height: 12),
                            
                            // طريقة الدفع
                DropdownButtonFormField<String>(
                                value: _paymentMethod,
                                decoration: InputDecoration(
                                  labelText: 'طريقة الدفع',
                                  prefixIcon: Icon(Icons.payment_rounded, color: AppTheme.primaryColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _paymentMethods.map((method) => DropdownMenuItem(
                                    value: method,
                    child: Text(method),
                  )).toList(),
                                onChanged: (value) => setState(() => _paymentMethod = value!),
                              ),
                            ],
                          ),
                        ),
                        
          // عناصر العربة
                              Expanded(
                                child: _cartItems.isEmpty
                ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('العربة فارغة', style: TextStyle(color: Colors.grey)),
                                  ],
                                        ),
                                      )
                                    : ListView.builder(
                    padding: const EdgeInsets.all(16),
                                        itemCount: _cartItems.length,
                                        itemBuilder: (context, index) {
                                          final item = _cartItems[index];
                                          return _buildCartItem(item, index);
                                        },
                          ),
                        ),
                        
                        // ملخص الفاتورة
                        if (_cartItems.isNotEmpty)
                        Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: Column(
                            children: [
                              // حقل الخصم
                  TextField(
                                      controller: _discountController,
                                  decoration: InputDecoration(
                      labelText: 'الخصم (جنيه)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          _discountAmount = double.tryParse(value) ?? 0.0;
                                        });
                                      },
                                    ),
                  const SizedBox(height: 16),
                              
                              // ملخص المبالغ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                      const Text('المجموع الفرعي:'),
                      Text('${_subtotal.toStringAsFixed(2)} جنيه'),
                    ],
                  ),
                  if (_discountAmount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                        const Text('الخصم:', style: TextStyle(color: AppTheme.errorColor)),
                        Text('- ${_discountAmount.toStringAsFixed(2)} جنيه', 
                             style: const TextStyle(color: AppTheme.errorColor)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الضريبة (${(_taxRate * 100).toInt()}%):'),
                      Text('${_taxAmount.toStringAsFixed(2)} جنيه'),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                      const Text('الإجمالي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '${_total.toStringAsFixed(2)} جنيه',
                          style: const TextStyle(
                          fontSize: 18,
                            fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                ),
              ),
                  ],
                ),
                  const SizedBox(height: 16),
                  
                  // أزرار العمليات
                Row(
                  children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearCart,
                          child: const Text('مسح الكل'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _processSale,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('إتمام البيع'),
                        ),
                      ),
                    ],
                  ),
                ],
                    ),
                  ),
              ],
      ),
    );
  }

  Widget _buildCartItem(SaleItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
        color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
              children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.unitPrice.toStringAsFixed(2)} جنيه × ${item.quantity}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
                ),
            Text(
                      '${item.totalPrice.toStringAsFixed(2)} جنيه',
            style: const TextStyle(
                        fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          IconButton(
            onPressed: () => _removeFromCart(index),
            icon: const Icon(Icons.delete_rounded, color: AppTheme.errorColor),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyLimitCard() {
    final userPlan = ref.watch(userPlanProvider);
    final sales = ref.watch(salesProvider);
    final featureManager = ref.read(featureManagerProvider);
    
    // حساب عدد المبيعات في الشهر الحالي
    final now = DateTime.now();
    final currentMonthSales = sales.where((sale) {
      return sale.saleDate.year == now.year && sale.saleDate.month == now.month;
    }).length;
    
    final remaining = FeatureManagerService.getRemainingCount('sales_this_month', userPlan, currentMonthSales);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: remaining > 10 
              ? [AppTheme.primaryColor.withOpacity(0.8), AppTheme.accentColor.withOpacity(0.8)]
              : remaining > 0
                  ? [AppTheme.warningColor.withOpacity(0.8), Colors.orange.withOpacity(0.8)]
                  : [AppTheme.errorColor.withOpacity(0.8), Colors.red.shade700.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: remaining > 0 ? AppTheme.primaryColor.withOpacity(0.2) : AppTheme.errorColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المبيعات هذا الشهر',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  remaining > 1000 ? 'لا محدود' : '$currentMonthSales من ${currentMonthSales + remaining}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (remaining <= 1000) ...[
                  const SizedBox(height: 4),
                  Text(
                    'متبقي: ${remaining} مبيعة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (remaining <= 5 && remaining > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'قريب من الحد',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }
}