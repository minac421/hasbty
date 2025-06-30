import 'dart:math';
import 'package:flutter/material.dart';

class SmartDataGenerator {
  final Random _random = Random();
  
  // قائمة أسماء المستخدمين العربية
  static const List<String> _arabicNames = [
    'أحمد محمد',
    'فاطمة علي',
    'محمود عبدالله',
    'عائشة حسن',
    'يوسف إبراهيم',
    'خديجة أحمد',
    'علي محمود',
    'نور الدين',
    'سارة عمر',
    'حسام الدين'
  ];
  
  // أسماء الأعمال الصغيرة
  static const List<String> _businessNames = [
    'متجر الإلكترونيات المتطور',
    'صيدلية الشفاء',
    'سوبر ماركت الأسرة',
    'مطعم الذوق الأصيل',
    'ورشة النجار الماهر',
    'مكتبة المعرفة',
    'محل الذهب والمجوهرات',
    'معرض السيارات الحديث',
    'مخبز الحي',
    'محل الملابس العصرية'
  ];
  
  // فئات المصروفات مع أيقوناتها
  static const List<Map<String, dynamic>> _expenseCategories = [
    {
      'name': 'طعام ومشروبات',
      'icon': Icons.restaurant,
      'color': Color(0xFFf8961e),
      'minAmount': 50,
      'maxAmount': 500,
    },
    {
      'name': 'مواصلات',
      'icon': Icons.directions_car,
      'color': Color(0xFFe63946),
      'minAmount': 20,
      'maxAmount': 200,
    },
    {
      'name': 'تسوق',
      'icon': Icons.shopping_cart,
      'color': Color(0xFF0087B8),
      'minAmount': 100,
      'maxAmount': 1000,
    },
    {
      'name': 'ترفيه',
      'icon': Icons.movie,
      'color': Color(0xFF6f42c1),
      'minAmount': 100,
      'maxAmount': 600,
    },
    {
      'name': 'صحة',
      'icon': Icons.local_hospital,
      'color': Color(0xFF28a745),
      'minAmount': 50,
      'maxAmount': 800,
    },
    {
      'name': 'فواتير',
      'icon': Icons.receipt,
      'color': Color(0xFF6c757d),
      'minAmount': 200,
      'maxAmount': 1500,
    },
    {
      'name': 'هدايا',
      'icon': Icons.card_giftcard,
      'color': Color(0xFFfd7e14),
      'minAmount': 100,
      'maxAmount': 800,
    }
  ];
  
  // فئات منتجات الأعمال الصغيرة
  static const List<Map<String, dynamic>> _businessProducts = [
    {
      'name': 'هاتف ذكي',
      'category': 'إلكترونيات',
      'minPrice': 2000,
      'maxPrice': 15000,
    },
    {
      'name': 'لابتوب',
      'category': 'إلكترونيات',
      'minPrice': 8000,
      'maxPrice': 25000,
    },
    {
      'name': 'دواء',
      'category': 'صيدلية',
      'minPrice': 15,
      'maxPrice': 200,
    },
    {
      'name': 'مواد غذائية',
      'category': 'سوبرماركت',
      'minPrice': 5,
      'maxPrice': 500,
    },
    {
      'name': 'وجبة',
      'category': 'مطعم',
      'minPrice': 25,
      'maxPrice': 150,
    },
    {
      'name': 'خدمة نجارة',
      'category': 'ورشة',
      'minPrice': 100,
      'maxPrice': 1000,
    },
    {
      'name': 'كتاب',
      'category': 'مكتبة',
      'minPrice': 20,
      'maxPrice': 200,
    },
    {
      'name': 'مجوهرات',
      'category': 'ذهب',
      'minPrice': 500,
      'maxPrice': 10000,
    }
  ];
  
  // أسماء العملاء
  static const List<String> _customerNames = [
    'أحمد السيد',
    'فاطمة محمد',
    'محمود علي',
    'عائشة حسن',
    'يوسف أحمد',
    'خديجة عبدالله',
    'علي إبراهيم',
    'نور محمود',
    'سارة يوسف',
    'حسام الدين',
    'مريم أحمد',
    'عبدالله محمد',
    'زينب علي',
    'حسن عبدالرحمن',
    'ليلى إبراهيم'
  ];

  // أسماء الشركات المتقدمة
  static const List<String> _enterpriseNames = [
    'شركة الرياض التجارية',
    'مجموعة القاهرة للاستثمار',
    'شركة الخليج للتجارة',
    'مؤسسة النور التجارية',
    'مجموعة الأمل للاستثمار',
    'شركة الوطن للتجارة الإلكترونية',
    'مجموعة الفجر التجارية',
    'شركة التقدم للاستثمار',
    'مؤسسة البناء التجارية',
    'مجموعة النجاح للأعمال'
  ];

  // فروع الشركات
  static const List<String> _branchNames = [
    'فرع وسط البلد',
    'فرع المعادي',
    'فرع مدينة نصر',
    'فرع الزمالك',
    'فرع الإسكندرية',
    'فرع طنطا',
    'فرع المنصورة',
    'فرع أسوان',
    'فرع شرم الشيخ',
    'فرع الغردقة',
    'فرع أسيوط',
    'فرع سوهاج'
  ];

  // منتجات الشركات المتقدمة
  static const List<Map<String, dynamic>> _enterpriseProducts = [
    {
      'name': 'نظام إدارة المؤسسات',
      'category': 'برمجيات',
      'minPrice': 50000,
      'maxPrice': 200000,
    },
    {
      'name': 'حلول الذكاء الاصطناعي',
      'category': 'تقنية',
      'minPrice': 100000,
      'maxPrice': 500000,
    },
    {
      'name': 'خدمات الاستشارات',
      'category': 'خدمات',
      'minPrice': 25000,
      'maxPrice': 150000,
    },
    {
      'name': 'تطوير التطبيقات',
      'category': 'برمجيات',
      'minPrice': 75000,
      'maxPrice': 300000,
    },
    {
      'name': 'حلول الأمان السيبراني',
      'category': 'أمان',
      'minPrice': 80000,
      'maxPrice': 400000,
    },
    {
      'name': 'تحليل البيانات الضخمة',
      'category': 'تحليل',
      'minPrice': 60000,
      'maxPrice': 250000,
    },
    {
      'name': 'التجارة الإلكترونية',
      'category': 'منصات',
      'minPrice': 40000,
      'maxPrice': 180000,
    },
    {
      'name': 'إنترنت الأشياء',
      'category': 'تقنية',
      'minPrice': 90000,
      'maxPrice': 350000,
    }
  ];

  // عملاء الشركات (شركات أخرى)
  static const List<String> _enterpriseCustomers = [
    'بنك مصر',
    'شركة المصرية للاتصالات',
    'البنك الأهلي المصري',
    'مجموعة طلعت مصطفى',
    'شركة العز للحديد والصلب',
    'مجموعة النساجون الشرقيون',
    'شركة جهينة للصناعات الغذائية',
    'مجموعة أوراسكوم',
    'البنك التجاري الدولي',
    'شركة رايو للاستثمار',
    'مجموعة المنصور',
    'شركة كلوباتيرا للسياحة',
    'مجموعة إعمار مصر',
    'شركة الإسكندرية للغزل',
    'مجموعة السويدي للكابلات'
  ];
  
  String _currentUserName = '';
  String _currentBusinessName = '';
  String _currentEnterpriseName = '';
  List<Map<String, dynamic>> _monthlyTransactions = [];
  List<Map<String, dynamic>> _businessSales = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _customers = [];
  
  // بيانات الشركات المتقدمة
  List<Map<String, dynamic>> _enterpriseSalesData = [];
  List<Map<String, dynamic>> _enterpriseProductsData = [];
  List<Map<String, dynamic>> _enterpriseCustomersData = [];
  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _employees = [];
  
  SmartDataGenerator() {
    _generateUserData();
    _generateBusinessData();
    _generateEnterpriseData();
  }
  
  void _generateUserData() {
    _currentUserName = _arabicNames[_random.nextInt(_arabicNames.length)];
    _generateMonthlyTransactions();
  }
  
  void _generateBusinessData() {
    _currentBusinessName = _businessNames[_random.nextInt(_businessNames.length)];
    _generateBusinessSales();
    _generateProducts();
    _generateCustomers();
  }

  void _generateEnterpriseData() {
    _currentEnterpriseName = _enterpriseNames[_random.nextInt(_enterpriseNames.length)];
    _generateEnterpriseSales();
    _generateEnterpriseProducts();
    _generateEnterpriseCustomers();
    _generateBranches();
    _generateEmployees();
  }
  
  void _generateMonthlyTransactions() {
    _monthlyTransactions.clear();
    
    // توليد 15-25 معاملة للشهر
    final transactionCount = 15 + _random.nextInt(11);
    
    for (int i = 0; i < transactionCount; i++) {
      final category = _expenseCategories[_random.nextInt(_expenseCategories.length)];
      final amount = (category['minAmount'] as int) + 
                    _random.nextInt((category['maxAmount'] as int) - (category['minAmount'] as int));
      
      // تواريخ متنوعة خلال الشهر
      final day = 1 + _random.nextInt(DateTime.now().day);
      final date = DateTime(DateTime.now().year, DateTime.now().month, day);
      
      _monthlyTransactions.add({
        'id': 'gen_${i + 1}',
        'title': category['name'],
        'details': _generateTransactionDetails(category['name']),
        'category': category['name'],
        'amount': amount.toDouble(),
        'date': date.toString().split(' ')[0],
        'icon': category['icon'],
        'color': category['color'],
        'timestamp': date.millisecondsSinceEpoch,
      });
    }
    
    // ترتيب المعاملات حسب التاريخ (الأحدث أولاً)
    _monthlyTransactions.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
  }
  
  void _generateBusinessSales() {
    _businessSales.clear();
    
    // توليد 50-150 مبيعة للشهر
    final salesCount = 50 + _random.nextInt(101);
    
    for (int i = 0; i < salesCount; i++) {
      final product = _businessProducts[_random.nextInt(_businessProducts.length)];
      final customer = _customerNames[_random.nextInt(_customerNames.length)];
      final price = (product['minPrice'] as int) + 
                   _random.nextInt((product['maxPrice'] as int) - (product['minPrice'] as int));
      final quantity = 1 + _random.nextInt(5);
      final total = price * quantity;
      
      // تواريخ متنوعة خلال الشهر
      final day = 1 + _random.nextInt(DateTime.now().day);
      final date = DateTime(DateTime.now().year, DateTime.now().month, day);
      
      _businessSales.add({
        'id': 'sale_${i + 1}',
        'customerName': customer,
        'productName': product['name'],
        'category': product['category'],
        'quantity': quantity,
        'unitPrice': price.toDouble(),
        'totalAmount': total.toDouble(),
        'date': date,
        'timestamp': date.millisecondsSinceEpoch,
      });
    }
    
    // ترتيب المبيعات حسب التاريخ (الأحدث أولاً)
    _businessSales.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
  }
  
  void _generateProducts() {
    _products.clear();
    
    // توليد 20-50 منتج
    final productCount = 20 + _random.nextInt(31);
    
    for (int i = 0; i < productCount; i++) {
      final product = _businessProducts[_random.nextInt(_businessProducts.length)];
      final price = (product['minPrice'] as int) + 
                   _random.nextInt((product['maxPrice'] as int) - (product['minPrice'] as int));
      final stock = _random.nextInt(100);
      
      _products.add({
        'id': 'prod_${i + 1}',
        'name': '${product['name']} ${i + 1}',
        'category': product['category'],
        'price': price.toDouble(),
        'stock': stock,
        'isLowStock': stock < 10,
      });
    }
  }
  
  void _generateCustomers() {
    _customers.clear();
    
    // توليد 30-80 عميل
    final customerCount = 30 + _random.nextInt(51);
    
    for (int i = 0; i < customerCount; i++) {
      final name = _customerNames[_random.nextInt(_customerNames.length)];
      final totalPurchases = 500 + _random.nextInt(5000);
      final lastPurchase = DateTime.now().subtract(Duration(days: _random.nextInt(30)));
      
      _customers.add({
        'id': 'cust_${i + 1}',
        'name': '$name ${i + 1}',
        'totalPurchases': totalPurchases.toDouble(),
        'lastPurchase': lastPurchase,
        'isVIP': totalPurchases > 2000,
      });
    }
  }

  void _generateEnterpriseSales() {
    _enterpriseSalesData.clear();
    
    // توليد 200-500 معاملة للشهر (شركة كبيرة)
    final salesCount = 200 + _random.nextInt(301);
    
    for (int i = 0; i < salesCount; i++) {
      final product = _enterpriseProducts[_random.nextInt(_enterpriseProducts.length)];
      final customer = _enterpriseCustomers[_random.nextInt(_enterpriseCustomers.length)];
      final branch = _branchNames[_random.nextInt(_branchNames.length)];
      final price = (product['minPrice'] as int) + 
                   _random.nextInt((product['maxPrice'] as int) - (product['minPrice'] as int));
      final quantity = 1 + _random.nextInt(3); // عادة كميات أقل للمنتجات المتقدمة
      final total = price * quantity;
      
      // تواريخ متنوعة خلال الشهر
      final day = 1 + _random.nextInt(DateTime.now().day);
      final date = DateTime(DateTime.now().year, DateTime.now().month, day);
      
      _enterpriseSalesData.add({
        'id': 'ent_sale_${i + 1}',
        'customerName': customer,
        'productName': product['name'],
        'category': product['category'],
        'branchName': branch,
        'quantity': quantity,
        'unitPrice': price.toDouble(),
        'totalAmount': total.toDouble(),
        'date': date,
        'timestamp': date.millisecondsSinceEpoch,
        'salesPerson': _arabicNames[_random.nextInt(_arabicNames.length)],
      });
    }
    
    // ترتيب المبيعات حسب التاريخ (الأحدث أولاً)
    _enterpriseSalesData.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
  }

  void _generateEnterpriseProducts() {
    _enterpriseProductsData.clear();
    
    // توليد 50-100 منتج متقدم
    final productCount = 50 + _random.nextInt(51);
    
    for (int i = 0; i < productCount; i++) {
      final product = _enterpriseProducts[_random.nextInt(_enterpriseProducts.length)];
      final price = (product['minPrice'] as int) + 
                   _random.nextInt((product['maxPrice'] as int) - (product['minPrice'] as int));
      final stock = _random.nextInt(50); // مخزون أقل للمنتجات المتقدمة
      
      _enterpriseProductsData.add({
        'id': 'ent_prod_${i + 1}',
        'name': '${product['name']} ${i + 1}',
        'category': product['category'],
        'price': price.toDouble(),
        'stock': stock,
        'isLowStock': stock < 5, // حد أقل للمنتجات المتقدمة
        'isHighValue': price > 150000,
      });
    }
  }

  void _generateEnterpriseCustomers() {
    _enterpriseCustomersData.clear();
    
    // توليد 100-200 عميل شركة
    final customerCount = 100 + _random.nextInt(101);
    
    for (int i = 0; i < customerCount; i++) {
      final name = _enterpriseCustomers[_random.nextInt(_enterpriseCustomers.length)];
      final totalPurchases = 50000 + _random.nextInt(500000); // مبالغ أكبر للشركات
      final lastPurchase = DateTime.now().subtract(Duration(days: _random.nextInt(90)));
      final contractValue = totalPurchases * (1.5 + _random.nextDouble());
      
      _enterpriseCustomersData.add({
        'id': 'ent_cust_${i + 1}',
        'name': '$name ${i + 1}',
        'totalPurchases': totalPurchases.toDouble(),
        'contractValue': contractValue,
        'lastPurchase': lastPurchase,
        'isEnterpriseClient': true,
        'isPremium': totalPurchases > 200000,
        'industry': ['تقنية', 'مالية', 'صناعة', 'خدمات', 'طاقة'][_random.nextInt(5)],
      });
    }
  }

  void _generateBranches() {
    _branches.clear();
    
    // توليد 5-15 فرع
    final branchCount = 5 + _random.nextInt(11);
    
    for (int i = 0; i < branchCount; i++) {
      final branchName = _branchNames[i % _branchNames.length];
      final monthlyRevenue = 500000 + _random.nextInt(2000000);
      final employees = 5 + _random.nextInt(20);
      
      _branches.add({
        'id': 'branch_${i + 1}',
        'name': branchName,
        'monthlyRevenue': monthlyRevenue.toDouble(),
        'employeeCount': employees,
        'isMainBranch': i == 0,
        'performance': 70 + _random.nextInt(31), // 70-100%
        'manager': _arabicNames[_random.nextInt(_arabicNames.length)],
      });
    }
  }

  void _generateEmployees() {
    _employees.clear();
    
    // توليد 50-150 موظف
    final employeeCount = 50 + _random.nextInt(101);
    
    for (int i = 0; i < employeeCount; i++) {
      final name = _arabicNames[_random.nextInt(_arabicNames.length)];
      final departments = ['المبيعات', 'التسويق', 'التقنية', 'المالية', 'الموارد البشرية', 'العمليات'];
      final positions = ['مدير', 'نائب مدير', 'مشرف', 'موظف أول', 'موظف'];
      
      _employees.add({
        'id': 'emp_${i + 1}',
        'name': '$name ${i + 1}',
        'department': departments[_random.nextInt(departments.length)],
        'position': positions[_random.nextInt(positions.length)],
        'branch': _branches.isNotEmpty ? _branches[_random.nextInt(_branches.length)]['name'] : 'المقر الرئيسي',
        'monthlySales': 10000 + _random.nextInt(50000),
        'performance': 60 + _random.nextInt(41), // 60-100%
      });
    }
  }
  
  String _generateTransactionDetails(String category) {
    switch (category) {
      case 'طعام ومشروبات':
        final restaurants = ['مطعم البيت', 'كافيه المدينة', 'مطعم الأصالة', 'بيتزا هت', 'ماكدونالدز'];
        return restaurants[_random.nextInt(restaurants.length)];
        
      case 'مواصلات':
        final transport = ['أوبر', 'كريم', 'تاكسي', 'بنزين', 'مترو'];
        return transport[_random.nextInt(transport.length)];
        
      case 'تسوق':
        final shops = ['كارفور', 'سبينيس', 'متجر الملابس', 'صيدلية', 'متجر إلكترونيات'];
        return shops[_random.nextInt(shops.length)];
        
      case 'ترفيه':
        final entertainment = ['سينما', 'ملاهي', 'كافيه شيشة', 'نادي رياضي', 'حفلة'];
        return entertainment[_random.nextInt(entertainment.length)];
        
      case 'صحة':
        final health = ['دكتور', 'صيدلية', 'تحاليل طبية', 'علاج طبيعي', 'نظارة طبية'];
        return health[_random.nextInt(health.length)];
        
      case 'فواتير':
        final bills = ['كهرباء', 'مياه', 'غاز', 'إنترنت', 'موبايل'];
        return bills[_random.nextInt(bills.length)];
        
      case 'هدايا':
        final gifts = ['هدية عيد ميلاد', 'هدية زواج', 'هدية أطفال', 'ورود', 'شوكولاتة'];
        return gifts[_random.nextInt(gifts.length)];
        
      default:
        return 'مصروف متنوع';
    }
  }
  
  String getUserName() => _currentUserName;
  String getBusinessName() => _currentBusinessName;
  String getEnterpriseName() => _currentEnterpriseName;
  
  String getAvatarUrl(String name) {
    final encodedName = Uri.encodeComponent(name);
    return "https://ui-avatars.com/api/?name=$encodedName&background=0087B8&color=fff&size=128";
  }
  
  double getTotalExpenses(DateTime month) {
    final monthTransactions = _monthlyTransactions.where((transaction) {
      final transactionDate = DateTime.parse(transaction['date']);
      return transactionDate.year == month.year && transactionDate.month == month.month;
    });
    
    return monthTransactions.fold(0.0, (sum, transaction) => sum + transaction['amount']);
  }
  
  // ============ وظائف الأعمال الصغيرة الجديدة ============
  
  double getMonthlyRevenue(DateTime month) {
    final monthSales = _businessSales.where((sale) {
      final saleDate = sale['date'] as DateTime;
      return saleDate.year == month.year && saleDate.month == month.month;
    });
    
    return monthSales.fold(0.0, (sum, sale) => sum + sale['totalAmount']);
  }
  
  double getMonthlyExpenses(DateTime month) {
    // محاكاة مصروفات العمل (30-50% من الإيرادات)
    final revenue = getMonthlyRevenue(month);
    final expenseRatio = 0.3 + (_random.nextDouble() * 0.2); // 30-50%
    return revenue * expenseRatio;
  }
  
  int getMonthlyInvoiceCount(DateTime month) {
    final monthSales = _businessSales.where((sale) {
      final saleDate = sale['date'] as DateTime;
      return saleDate.year == month.year && saleDate.month == month.month;
    });
    
    return monthSales.length;
  }
  
  int getTotalProductCount() => _products.length;
  int getLowStockCount() => _products.where((p) => p['isLowStock']).length;
  int getTotalCustomerCount() => _customers.length;
  int getVIPCustomerCount() => _customers.where((c) => c['isVIP']).length;
  
  List<Map<String, dynamic>> getRecentSales([int limit = 5]) {
    return _businessSales.take(limit).toList();
  }
  
  List<Map<String, dynamic>> getTopProducts([int limit = 5]) {
    // حساب المنتجات الأكثر مبيعاً
    final productSales = <String, Map<String, dynamic>>{};
    
    for (final sale in _businessSales) {
      final productName = sale['productName'] as String;
      if (productSales.containsKey(productName)) {
        productSales[productName]!['totalSales'] += sale['totalAmount'];
        productSales[productName]!['quantity'] += sale['quantity'];
      } else {
        productSales[productName] = {
          'name': productName,
          'totalSales': sale['totalAmount'],
          'quantity': sale['quantity'],
          'category': sale['category'],
        };
      }
    }
    
    final sortedProducts = productSales.values.toList()
      ..sort((a, b) => b['totalSales'].compareTo(a['totalSales']));
    
    return sortedProducts.take(limit).toList();
  }
  
  List<Map<String, dynamic>> getTopCustomers([int limit = 5]) {
    final sortedCustomers = List<Map<String, dynamic>>.from(_customers)
      ..sort((a, b) => b['totalPurchases'].compareTo(a['totalPurchases']));
    
    return sortedCustomers.take(limit).toList();
  }

  // ============ وظائف الشركات المتقدمة الجديدة ============
  
  double getEnterpriseMonthlyRevenue(DateTime month) {
    final monthSales = _enterpriseSalesData.where((sale) {
      final saleDate = sale['date'] as DateTime;
      return saleDate.year == month.year && saleDate.month == month.month;
    });
    
    return monthSales.fold(0.0, (sum, sale) => sum + sale['totalAmount']);
  }

  double getEnterpriseMonthlyExpenses(DateTime month) {
    // محاكاة مصروفات الشركة (25-40% من الإيرادات - هامش ربح أعلى)
    final revenue = getEnterpriseMonthlyRevenue(month);
    final expenseRatio = 0.25 + (_random.nextDouble() * 0.15); // 25-40%
    return revenue * expenseRatio;
  }

  double getEnterpriseInventoryValue() {
    return _enterpriseProductsData.fold(0.0, (sum, product) => 
        sum + (product['price'] * product['stock']));
  }

  int getEnterpriseTransactionCount(DateTime month) {
    final monthSales = _enterpriseSalesData.where((sale) {
      final saleDate = sale['date'] as DateTime;
      return saleDate.year == month.year && saleDate.month == month.month;
    });
    
    return monthSales.length;
  }

  int getEnterpriseProductCount() => _enterpriseProductsData.length;
  int getEnterpriseCustomerCount() => _enterpriseCustomersData.length;
  int getEnterpriseBranchCount() => _branches.length;
  int getEnterpriseEmployeeCount() => _employees.length;
  int getEnterpriseLowStockCount() => _enterpriseProductsData.where((p) => p['isLowStock']).length;
  int getEnterprisePremiumCustomerCount() => _enterpriseCustomersData.where((c) => c['isPremium']).length;
  int getEnterpriseHighValueProductCount() => _enterpriseProductsData.where((p) => p['isHighValue']).length;

  List<Map<String, dynamic>> getEnterpriseRecentSales([int limit = 10]) {
    return _enterpriseSalesData.take(limit).toList();
  }

  List<Map<String, dynamic>> getEnterpriseTopBranches([int limit = 5]) {
    final sortedBranches = List<Map<String, dynamic>>.from(_branches)
      ..sort((a, b) => b['monthlyRevenue'].compareTo(a['monthlyRevenue']));
    
    return sortedBranches.take(limit).toList();
  }

  List<Map<String, dynamic>> getEnterpriseTopProducts([int limit = 5]) {
    // حساب المنتجات الأكثر مبيعاً للشركة
    final productSales = <String, Map<String, dynamic>>{};
    
    for (final sale in _enterpriseSalesData) {
      final productName = sale['productName'] as String;
      if (productSales.containsKey(productName)) {
        productSales[productName]!['totalSales'] += sale['totalAmount'];
        productSales[productName]!['quantity'] += sale['quantity'];
      } else {
        productSales[productName] = {
          'name': productName,
          'totalSales': sale['totalAmount'],
          'quantity': sale['quantity'],
          'category': sale['category'],
        };
      }
    }
    
    final sortedProducts = productSales.values.toList()
      ..sort((a, b) => b['totalSales'].compareTo(a['totalSales']));
    
    return sortedProducts.take(limit).toList();
  }

  List<Map<String, dynamic>> getEnterpriseTopCustomers([int limit = 5]) {
    final sortedCustomers = List<Map<String, dynamic>>.from(_enterpriseCustomersData)
      ..sort((a, b) => b['totalPurchases'].compareTo(a['totalPurchases']));
    
    return sortedCustomers.take(limit).toList();
  }

  List<Map<String, dynamic>> getEnterpriseTopEmployees([int limit = 10]) {
    final sortedEmployees = List<Map<String, dynamic>>.from(_employees)
      ..sort((a, b) => b['monthlySales'].compareTo(a['monthlySales']));
    
    return sortedEmployees.take(limit).toList();
  }

  // إحصائيات ذكية للشركات المتقدمة
  Map<String, dynamic> getEnterpriseInsights(DateTime month) {
    final monthSales = _enterpriseSalesData.where((sale) {
      final saleDate = sale['date'] as DateTime;
      return saleDate.year == month.year && saleDate.month == month.month;
    }).toList();
    
    if (monthSales.isEmpty) {
      return {
        'topBranch': 'لا توجد مبيعات',
        'topEmployee': 'لا يوجد',
        'averageTransactionValue': 0.0,
        'totalRevenue': 0.0,
        'profitMargin': 0.0,
        'bestPerformingCategory': 'غير محدد',
      };
    }

    // أفضل فرع
    final branchSales = <String, double>{};
    for (final sale in monthSales) {
      final branch = sale['branchName'] as String;
      branchSales[branch] = (branchSales[branch] ?? 0) + sale['totalAmount'];
    }
    final topBranch = branchSales.entries.isNotEmpty
        ? branchSales.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'غير محدد';

    // أفضل موظف مبيعات
    final employeeSales = <String, double>{};
    for (final sale in monthSales) {
      final employee = sale['salesPerson'] as String;
      employeeSales[employee] = (employeeSales[employee] ?? 0) + sale['totalAmount'];
    }
    final topEmployee = employeeSales.entries.isNotEmpty
        ? employeeSales.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'غير محدد';

    // متوسط قيمة المعاملة
    final totalRevenue = monthSales.fold(0.0, (sum, sale) => sum + sale['totalAmount']);
    final averageTransactionValue = totalRevenue / monthSales.length;

    // هامش الربح
    final expenses = getEnterpriseMonthlyExpenses(month);
    final profitMargin = expenses > 0 ? ((totalRevenue - expenses) / totalRevenue) * 100 : 0.0;

    // أفضل فئة منتجات
    final categorySales = <String, double>{};
    for (final sale in monthSales) {
      final category = sale['category'] as String;
      categorySales[category] = (categorySales[category] ?? 0) + sale['totalAmount'];
    }
    final bestCategory = categorySales.entries.isNotEmpty
        ? categorySales.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'غير محدد';

    return {
      'topBranch': topBranch,
      'topEmployee': topEmployee,
      'averageTransactionValue': averageTransactionValue,
      'totalRevenue': totalRevenue,
      'profitMargin': profitMargin,
      'bestPerformingCategory': bestCategory,
    };
  }

  // إحصائيات الأداء الشهري للسنة (للرسم البياني)
  List<double> getEnterpriseMonthlyPerformance() {
    final monthlyRevenues = <double>[];
    final currentDate = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final targetMonth = DateTime(currentDate.year, currentDate.month - i, 1);
      final monthRevenue = getEnterpriseMonthlyRevenue(targetMonth);
      
      // إضافة تباين واقعي للأشهر السابقة
      final variation = 0.7 + (_random.nextDouble() * 0.6); // 70% - 130%
      monthlyRevenues.add(monthRevenue * variation);
    }
    
    return monthlyRevenues;
  }
  
  int getOcrUsed() {
    // محاكاة استخدام OCR (5-40 من أصل 50)
    return 5 + _random.nextInt(36);
  }
  
  int getVoiceUsed() {
    // محاكاة استخدام Voice (2-20 من أصل 50)
    return 2 + _random.nextInt(19);
  }
  
  List<Map<String, dynamic>> getRecentTransactions(DateTime month) {
    final monthTransactions = _monthlyTransactions.where((transaction) {
      final transactionDate = DateTime.parse(transaction['date']);
      return transactionDate.year == month.year && transactionDate.month == month.month;
    }).toList();
    
    // إرجاع آخر 4 معاملات
    return monthTransactions.take(4).toList();
  }
  
  // إحصائيات ذكية للأعمال الصغيرة
  Map<String, dynamic> getBusinessInsights(DateTime month) {
    final monthSales = _businessSales.where((sale) {
      final saleDate = sale['date'] as DateTime;
      return saleDate.year == month.year && saleDate.month == month.month;
    }).toList();
    
    if (monthSales.isEmpty) {
      return {
        'topProduct': 'لا توجد مبيعات',
        'averageSaleValue': 0.0,
        'totalCustomers': 0,
        'bestDay': 'لا يوجد',
        'profitMargin': 0.0,
      };
    }
    
    // أكثر منتج مبيعاً
    final topProducts = getTopProducts(1);
    final topProduct = topProducts.isNotEmpty ? topProducts.first['name'] : 'غير محدد';
    
    // متوسط قيمة البيع
    final totalRevenue = monthSales.fold(0.0, (sum, sale) => sum + sale['totalAmount']);
    final averageSaleValue = totalRevenue / monthSales.length;
    
    // عدد العملاء الفريدين
    final uniqueCustomers = monthSales.map((s) => s['customerName']).toSet().length;
    
    // أفضل يوم مبيعات
    final bestDay = _getBestSalesDay(monthSales);
    
    // هامش الربح (محاكي)
    final expenses = getMonthlyExpenses(month);
    final profitMargin = expenses > 0 ? ((totalRevenue - expenses) / totalRevenue) * 100 : 0.0;
    
    return {
      'topProduct': topProduct,
      'averageSaleValue': averageSaleValue,
      'totalCustomers': uniqueCustomers,
      'bestDay': bestDay,
      'profitMargin': profitMargin,
    };
  }
  
  String _getBestSalesDay(List<Map<String, dynamic>> sales) {
    final dayTotals = <String, double>{};
    
    for (final sale in sales) {
      final date = (sale['date'] as DateTime).toString().split(' ')[0];
      dayTotals[date] = (dayTotals[date] ?? 0) + sale['totalAmount'];
    }
    
    if (dayTotals.isEmpty) return 'لا يوجد';
    
    final bestDay = dayTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    return bestDay.key;
  }
  
  // إحصائيات ذكية للفرد
  Map<String, dynamic> getSmartInsights(DateTime month) {
    final monthTransactions = _monthlyTransactions.where((transaction) {
      final transactionDate = DateTime.parse(transaction['date']);
      return transactionDate.year == month.year && transactionDate.month == month.month;
    }).toList();
    
    if (monthTransactions.isEmpty) {
      return {
        'topCategory': 'لا توجد مصروفات',
        'averageDailySpent': 0.0,
        'totalTransactions': 0,
        'mostExpensiveDay': 'لا يوجد',
      };
    }
    
    // أكثر فئة إنفاق
    final categoryTotals = <String, double>{};
    for (final transaction in monthTransactions) {
      final category = transaction['category'] as String;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + transaction['amount'];
    }
    
    final topCategory = categoryTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    // متوسط الإنفاق اليومي
    final totalAmount = monthTransactions.fold(0.0, (sum, t) => sum + t['amount']);
    final daysInMonth = DateTime.now().day; // الأيام المنقضية من الشهر
    final averageDailySpent = totalAmount / daysInMonth;
    
    return {
      'topCategory': topCategory,
      'averageDailySpent': averageDailySpent,
      'totalTransactions': monthTransactions.length,
      'mostExpensiveDay': _getMostExpensiveDay(monthTransactions),
    };
  }
  
  String _getMostExpensiveDay(List<Map<String, dynamic>> transactions) {
    final dayTotals = <String, double>{};
    
    for (final transaction in transactions) {
      final date = transaction['date'] as String;
      dayTotals[date] = (dayTotals[date] ?? 0) + transaction['amount'];
    }
    
    if (dayTotals.isEmpty) return 'لا يوجد';
    
    final mostExpensive = dayTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    return mostExpensive.key;
  }
  
  // تجديد البيانات
  void refreshData() {
    _generateUserData();
    _generateBusinessData();
    _generateEnterpriseData();
  }
} 