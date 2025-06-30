class AppConstants {
  // معلومات التطبيق
  static const String appName = 'جردلي';
  static const String appSubtitle = 'AI مساعد المصاريف';
  static const String appDescription = 'مساعدك الذكي لتتبع المصاريف والمحاسبة الشخصية';
  static const String appVersion = '2.1.0';
  
  // ألوان التطبيق الموحدة
  static const int primaryColorCode = 0xFF667eea; // أزرق هادئ
  static const int secondaryColorCode = 0xFF764ba2; // بنفسجي أنيق
  static const int accentColorCode = 0xFF4CAF50; // أخضر طبيعي
  static const int successColorCode = 0xFF4CAF50; // أخضر النجاح
  static const int warningColorCode = 0xFFFF9800; // برتقالي التحذير
  static const int errorColorCode = 0xFFE91E63; // وردي التحذير
  
  // أحجام التخطيط
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  
  // نصوص الواجهة الموحدة
  static const String welcomeMessage = 'مرحباً بك في جردلي';
  static const String loading = 'جاري التحميل...';
  static const String noData = 'لا توجد بيانات';
  static const String error = 'حدث خطأ';
  static const String success = 'تم بنجاح';
  static const String cancel = 'إلغاء';
  static const String save = 'حفظ';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String add = 'إضافة';
  static const String search = 'البحث...';
  static const String filter = 'تصفية';
  static const String refresh = 'تحديث';
  
  // نصوص الميزات
  static const String voiceInput = 'إدخال صوتي';
  static const String cameraInput = 'تصوير الفواتير';
  static const String manualInput = 'إدخال يدوي';
  static const String reports = 'التقارير';
  static const String settings = 'الإعدادات';
  
  // نصوص المستخدمين
  static const String individual = 'فرد';
  static const String smallBusiness = 'شركة صغيرة';
  static const String enterprise = 'شركة كبيرة';
  
  // نصوص الحالات الفارغة
  static const String noProducts = 'لا توجد منتجات';
  static const String noCustomers = 'لا يوجد عملاء';
  static const String noSuppliers = 'لا يوجد موردين';
  static const String noTransactions = 'لا توجد معاملات';
  static const String noInvoices = 'لا توجد فواتير';
  static const String emptyCart = 'العربة فارغة';
  
  // العملة الافتراضية
  static const String defaultCurrency = 'ج.م';
  static const String currencyCode = 'EGP';
  
  // إعدادات التطبيق
  static const bool enableNotifications = true;
  static const bool enableAutoBackup = false; // معطل حالياً
  static const bool enableOfflineMode = true;
  static const String defaultLanguage = 'ar';
  static const String supportEmail = 'support@jardaly.com';
  static const String supportPhone = '+201000000000';
  
  // نصوص إضافية
  static const String close = 'إغلاق';
  static const String confirm = 'تأكيد';
  
  // العملة
  static const String currency = 'جنيه';
  static const String currencySymbol = 'ج.م';
  
  // نصوص المحاسبة
  static const String totalBalance = 'الرصيد الإجمالي';
  static const String income = 'الإيرادات';
  static const String expenses = 'المصروفات';
  static const String profit = 'الربح';
  static const String loss = 'الخسارة';
  
  // نصوص المخزون
  static const String currentStock = 'المخزون الحالي';
  static const String minimumStock = 'الحد الأدنى';
  static const String lowStock = 'مخزون منخفض';
  static const String outOfStock = 'نفدت الكمية';
  static const String expiryDate = 'تاريخ الانتهاء';
  static const String expired = 'منتهي الصلاحية';
  static const String expiringSoon = 'ينتهي قريباً';
  
  // أنواع المستخدمين
  static const String normalUser = 'مستخدم عادي';
  static const String businessOwner = 'صاحب شغل';
  static const String professionalAccountant = 'محاسب محترف';
  
  // طرق الدفع
  static const List<String> paymentMethods = [
    'نقدي',
    'بطاقة',
    'آجل',
    'تحويل بنكي',
    'محفظة إلكترونية'
  ];
  
  // تصنيفات المنتجات
  static const List<String> productCategories = [
    'الكل',
    'طعام',
    'مشروبات',
    'أدوية',
    'مستحضرات تجميل',
    'إلكترونيات',
    'ملابس',
    'أدوات منزلية',
    'أخرى'
  ];
  
  // تصنيفات المعاملات للمحاسبة العامة
  static const List<String> incomeCategories = [
    'المبيعات',
    'الخدمات',
    'استثمارات',
    'أرباح أسهم',
    'إيجارات',
    'فوائد',
    'أخرى',
  ];
  
  static const List<String> expenseCategories = [
    'المشتريات',
    'الرواتب',
    'الإيجار',
    'الكهرباء',
    'المياه',
    'الإنترنت',
    'التليفونات',
    'الصيانة',
    'التسويق',
    'النقل',
    'أخرى',
  ];
  
  // وحدات القياس
  static const List<String> units = [
    'قطعة',
    'كجم',
    'جرام',
    'لتر',
    'مل',
    'علبة',
    'كيس',
    'زجاجة',
    'متر',
    'سم',
    'صندوق',
    'كرتونة'
  ];
  
  // حالات الطلبات
  static const String pending = 'قيد الانتظار';
  static const String completed = 'مكتمل';
  static const String cancelled = 'ملغي';
  static const String draft = 'مسودة';
  
  // أنواع التقارير
  static const String dailyReport = 'تقرير يومي';
  static const String weeklyReport = 'تقرير أسبوعي';
  static const String monthlyReport = 'تقرير شهري';
  static const String yearlyReport = 'تقرير سنوي';
  static const String customReport = 'تقرير مخصص';
  
  // رسائل التحقق
  static const String requiredField = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'البريد الإلكتروني غير صحيح';
  static const String invalidPhone = 'رقم الهاتف غير صحيح';
  static const String invalidNumber = 'الرقم غير صحيح';
  static const String passwordTooShort = 'كلمة المرور قصيرة جداً';
  static const String passwordsNotMatch = 'كلمات المرور غير متطابقة';
  
  // حدود النظام
  static const int maxProductNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxNotesLength = 1000;
  static const int minPasswordLength = 6;
  static const int maxSearchResults = 100;
  static const int defaultPageSize = 20;
  
  // أرقام ثابتة
  static const double defaultTaxRate = 0.14; // 14% ضريبة القيمة المضافة
  static const int lowStockThreshold = 10;
  static const int expiryWarningDays = 30;
  
  // مسارات الشاشات
  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';
  static const String productsRoute = '/products';
  static const String customersRoute = '/customers';
  static const String suppliersRoute = '/suppliers';
  static const String posRoute = '/pos';
  static const String inventoryRoute = '/inventory';
  static const String reportsRoute = '/reports';
  static const String invoicesRoute = '/invoices';
  static const String settingsRoute = '/settings';
  static const String addTransactionRoute = '/add_transaction';
  static const String userTypeSelectionRoute = '/user_type_selection';
  
  // مفاتيح التخزين المحلي
  static const String userTypeKey = 'user_type';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String selectedLanguageKey = 'selected_language';
  static const String selectedThemeKey = 'selected_theme';
  static const String lastSyncKey = 'last_sync';
  
  // أنماط التاريخ
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // رسائل النجاح
  static const String productSaved = 'تم حفظ المنتج بنجاح';
  static const String productDeleted = 'تم حذف المنتج بنجاح';
  static const String customerSaved = 'تم حفظ العميل بنجاح';
  static const String customerDeleted = 'تم حذف العميل بنجاح';
  static const String saleCompleted = 'تم إتمام البيع بنجاح';
  static const String purchaseCompleted = 'تم إتمام الشراء بنجاح';
  
  // رسائل الأخطاء
  static const String genericError = 'حدث خطأ غير متوقع';
  static const String networkError = 'خطأ في الاتصال بالإنترنت';
  static const String serverError = 'خطأ في الخادم';
  static const String authError = 'خطأ في تسجيل الدخول';
  static const String permissionError = 'ليس لديك صلاحية للقيام بهذا الإجراء';
  static const String notFoundError = 'العنصر غير موجود';
  static const String duplicateError = 'هذا العنصر موجود بالفعل';
  
  // نصوص إضافية
  static const String selectCustomer = 'اختر العميل';
  static const String cashCustomer = 'عميل نقدي';
  
  // العملات
  static const List<Map<String, String>> currencies = [
    {'code': 'EGP', 'name': 'الجنيه المصري', 'symbol': 'ج.م'},
    {'code': 'USD', 'name': 'الدولار الأمريكي', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'اليورو', 'symbol': '€'},
    {'code': 'SAR', 'name': 'الريال السعودي', 'symbol': '﷼'},
    {'code': 'AED', 'name': 'الدرهم الإماراتي', 'symbol': 'د.إ'},
  ];

  // API Configuration
  static const String baseUrl = 'https://api.gardaly.com';
  static const String apiVersion = 'v1';
  
  // Cache Keys
  static const String userCacheKey = 'user_data';
  static const String planCacheKey = 'user_plan';
  static const String tokenCacheKey = 'auth_token';
  
  // Durations
  static const Duration cacheExpiry = Duration(days: 7);
  static const Duration sessionTimeout = Duration(hours: 24);
  
  // Payment Configuration
  static const String paymobApiKey = 'YOUR_PAYMOB_API_KEY';
  static const String paymobIntegrationId = 'YOUR_INTEGRATION_ID';
  static const String paymobIframeId = 'YOUR_IFRAME_ID';
  
  // Feature Flags
  static const bool enableVoiceAssistant = true;
  static const bool enableOCR = true;
  static const bool enableAnalytics = true;
  
  // Plan Limits
  static const int freeProductLimit = 0;
  static const int starterProductLimit = 50;
  static const int businessProductLimit = 500;
  static const int enterpriseProductLimit = -1; // unlimited
  
  // Colors for User Types
  static const Map<String, dynamic> userTypeColors = {
    'individual': {'primary': 0xFF4A90E2, 'secondary': 0xFF6BB6FF},
    'smallBusiness': {'primary': 0xFF00BFA5, 'secondary': 0xFF1DE9B6},
    'enterprise': {'primary': 0xFF7B1FA2, 'secondary': 0xFF9C27B0},
  };
  
  // Routes
  static const String onboardingRoute = '/onboarding';
  
  // Messages
  static const String logoutMessage = 'تم تسجيل الخروج بنجاح';
  static const String errorMessage = 'حدث خطأ، يرجى المحاولة مرة أخرى';
}

// Enums and Constants for Plans
enum PlanType {
  free,
  starter,
  business,
  enterprise,
}

enum FeatureType {
  products,
  customers,
  suppliers,
  reports,
  ocr,
  voice,
  pos,
  inventory,
  analytics,
  multiUser,
  api,
}
