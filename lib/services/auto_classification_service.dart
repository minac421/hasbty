import 'package:flutter/material.dart';

class AutoClassificationService {
  // خريطة الكلمات المفتاحية للتصنيف - محسنة بالعامية المصرية
  static const Map<String, List<String>> _categoryKeywords = {
    // مصروفات بالعامية المصرية الحلوة
    'طعام ومشروبات': [
      // مطاعم ومقاهي
      'مطعم', 'كافيه', 'مقهى', 'أهوة', 'قهوة', 'شاي', 'عصير', 'كولا', 'بيبسي',
      'مكدونالدز', 'كنتاكي', 'بيتزا', 'برجر', 'ساندوتش', 'هوت دوج',
      
      // أكل مصري
      'فول', 'طعمية', 'كشري', 'مولوخية', 'رز', 'مكرونة', 'فراخ', 'لحمة', 'سمك',
      'خبز', 'عيش', 'فينو', 'توست', 'كعك', 'بسكويت', 'حلاوة', 'عسل',
      
      // منتجات ألبان
      'لبن', 'جبن', 'زبدة', 'بيض', 'لبنة', 'قشطة', 'زبادي', 'آيس كريم',
      
      // خضار وفواكه
      'طماطم', 'خيار', 'جزر', 'بصل', 'بطاطس', 'ملوخية', 'سبانخ', 'كوسة',
      'موز', 'تفاح', 'برتقال', 'عنب', 'مانجو', 'فراولة', 'بطيخ', 'كنتالوب',
      
      // مشروبات
      'مياه', 'عصير', 'شاي', 'قهوة', 'بن', 'كابتشينو', 'إسبريسو', 'نسكافيه'
    ],
    
    'مواصلات ووقود': [
      // وقود
      'بنزين', 'وقود', 'سولار', 'محطة', 'البنزين', 'محطة وقود', 'تعبئة',
      
      // مواصلات
      'تاكسي', 'أوبر', 'كريم', 'سويڤل', 'مترو', 'أتوبيس', 'ميكروباص', 'توك توك',
      'ركوب', 'عربية', 'جراج', 'موقف', 'كوبري', 'رسوم', 'تذكرة',
      
      // خدمات السيارات
      'صيانة عربية', 'كاوتش', 'إطار', 'بطارية', 'زيت', 'فرامل', 'كلتش'
    ],
    
    'فواتير ومرافق': [
      // كهرباء ومياه
      'كهربا', 'كهرباء', 'مياه', 'غاز', 'فاتورة كهربا', 'فاتورة مياه', 'فاتورة غاز',
      
      // اتصالات
      'تليفون', 'موبايل', 'انترنت', 'إنترنت', 'نت', 'واي فاي', 'wifi',
      'كابل', 'فودافون', 'اتصالات', 'أورانج', 'we', 'رصيد موبايل', 'شحن',
      
      // تلفزيون وترفيه
      'نايل سات', 'بي إن سبورت', 'نتفليكس', 'يوتيوب بريميوم', 'سبوتيفاي'
    ],
    
    'سكن وإيجار': [
      // عقارات
      'إيجار', 'ايجار', 'سكن', 'شقة', 'بيت', 'عمارة', 'فيلا', 'استوديو', 'روف',
      'مالك', 'مستأجر', 'عقد', 'إيصال', 'سند', 'تأمين', 'مقدم',
      
      // صيانة وأثاث
      'صيانة', 'أثاث', 'تكييف', 'دهان', 'سيراميك', 'باركيه', 'رخام',
      'نجار', 'كهربائي', 'سباك', 'نقاش', 'حداد', 'عامل', 'مقاول'
    ],
    
    'صحة وأدوية': [
      // أماكن طبية
      'صيدلية', 'دكتور', 'طبيب', 'دكتورة', 'مستشفى', 'عيادة', 'مركز طبي',
      'معمل تحاليل', 'أشعة', 'سونار', 'إيكو', 'رنين مغناطيسي',
      
      // تخصصات طبية
      'أسنان', 'عيون', 'قلب', 'عظام', 'جلدية', 'نساء وتوليد', 'أطفال',
      'باطنة', 'جراحة', 'أنف وأذن', 'مخ وأعصاب', 'نفسية',
      
      // أدوية وعلاج
      'دواء', 'علاج', 'دوا', 'أقراص', 'كبسولات', 'شراب', 'مرهم', 'كريم',
      'حقن', 'أمبولات', 'فيتامينات', 'مضاد حيوي', 'مسكن', 'خافض حرارة',
      
      // عمليات وإجراءات
      'عملية', 'جراحة', 'كشف', 'استشارة', 'تحليل', 'فحص', 'تطعيم', 'حقنة'
    ],
    
    'ملابس وتسوق': [
      // ملابس
      'ملابس', 'هدوم', 'قميص', 'بنطلون', 'تيشيرت', 'فستان', 'جلابية', 'عباية',
      'جاكيت', 'بلوزة', 'تنورة', 'شورت', 'بيجامة', 'ملابس داخلية', 'جوارب',
      
      // أحذية وإكسسوارات
      'جزمة', 'حذاء', 'شبشب', 'صندل', 'كوتشي', 'شنطة', 'حقيبة', 'محفظة',
      'ساعة', 'خاتم', 'سلسلة', 'أسورة', 'حلق', 'نظارة', 'نظارة شمس',
      
      // إلكترونيات
      'موبايل جديد', 'تليفون', 'لابتوب', 'كمبيوتر', 'تابلت', 'آيباد', 'آيفون',
      'سامسونج', 'هواوي', 'شاومي', 'أوبو', 'ريدمي', 'هيدفونز', 'سماعات',
      
      // أماكن التسوق
      'سوق', 'مول', 'متجر', 'محل', 'بوتيك', 'اوت ليت', 'هايبر ماركت',
      'سيتي ستارز', 'مول مصر', 'جنينة مول', 'كايرو فيستيفال'
    ],
    
    'تعليم وثقافة': [
      // مؤسسات تعليمية
      'مدرسة', 'جامعة', 'جامعه', 'كلية', 'معهد', 'أكاديمية', 'مركز تدريب',
      'حضانة', 'كي جي', 'ابتدائي', 'اعدادي', 'ثانوي',
      
      // مصروفات تعليمية
      'مصروفات', 'رسوم', 'مصاريف مدرسة', 'كتب', 'مذكرات', 'أدوات مدرسية',
      'شنطة مدرسة', 'يونيفورم', 'حذاء مدرسة', 'كراسات', 'أقلام',
      
      // دروس ودورات
      'درس خصوصي', 'مدرس خصوصي', 'سنتر', 'مجموعة', 'كورس', 'دورة تدريبية',
      'كورس انجليزي', 'كورس كمبيوتر', 'دورة محاسبة', 'دورة تسويق',
      
      // امتحانات
      'امتحان', 'اختبار', 'تجريبي', 'ثانوية عامة', 'إعدادية', 'دبلوم'
    ],
    
    'ترفيه ورياضة': [
      // ترفيه
      'سينما', 'مسرح', 'كونسيرت', 'حفلة', 'حفل', 'أوبرا', 'ساقية الصاوي',
      'اوركسترا', 'عرض', 'فيلم', 'تذكرة سينما',
      
      // رياضة
      'جيم', 'نادي', 'فيتنس', 'رياضة', 'تمرين', 'كوتش', 'مدرب شخصي',
      'سباحة', 'حمام سباحة', 'تنس', 'سكواش', 'كورة', 'ملعب',
      
      // سفر ومصايف
      'سفر', 'رحلة', 'فندق', 'مصيف', 'بحر', 'شاطئ', 'منتجع', 'فيلا بحر',
      'الساحل الشمالي', 'العين السخنة', 'شرم الشيخ', 'الغردقة', 'أسوان', 'الأقصر',
      
      // ألعاب وتسلية
      'ملاهي', 'لعبة', 'بلايستيشن', 'إكس بوكس', 'جيمز', 'كيدزانيا', 'ماجيك بلانيت'
    ],
    
    // إيرادات بالعامية المصرية
    'مبيعات': [
      'بيع', 'بعت', 'مبيعات', 'عميل', 'زبون', 'زباين', 'فاتورة', 'طلب', 'منتج',
      'بضاعة', 'سلعة', 'صفقة', 'عملية بيع', 'تجارة', 'محل', 'دكان', 'متجر'
    ],
    
    'راتب ومكافآت': [
      'راتب', 'مرتب', 'معاش', 'شهرية', 'أجر', 'اجر', 'حافز', 'مكافأة', 'مكافاة',
      'بونص', 'عمولة', 'نسبة', 'عطية', 'هدية', 'كرمة', 'إكرامية', 'تيب'
    ],
    
    'خدمات': [
      'خدمة', 'خدمات', 'شغلانة', 'فريلانس', 'مشروع', 'تعاقد', 'استشارة',
      'تصميم', 'برمجة', 'ترجمة', 'تدريس', 'درس خصوصي', 'إصلاح', 'صيانة'
    ],
    
    'استثمارات': [
      'استثمار', 'أرباح', 'ربح', 'أسهم', 'عوائد', 'فوائد', 'فايدة', 'ذهب',
      'عقار', 'شقة', 'محل تجاري', 'أرض', 'عملة', 'دولار', 'يورو', 'عملات رقمية'
    ],
    
    // فئات إضافية للمعاملات الشخصية
    'سلف وديون': [
      'سلفة', 'سلف', 'دين', 'استلف', 'اقرض', 'قرض', 'مدين', 'دائن',
      'استلفت', 'اقرضت', 'سلفته', 'سلفتها', 'أخذ مني', 'خد مني',
      'رد', 'رجع', 'سدد', 'قسط', 'تقسيط', 'متأخر', 'مستحق'
    ],
    
    'معاملات عائلية': [
      'أبوي', 'أمي', 'والدي', 'والدتي', 'أخويا', 'أختي', 'جوزي', 'مراتي',
      'ابني', 'بنتي', 'عمي', 'خالي', 'عمتي', 'خالتي', 'جدي', 'تيتتي',
      'حماتي', 'حموي', 'صحبي', 'صاحبي', 'حبيبي', 'صديق', 'صديقة'
    ]
  };

  // تصنيف المعاملة تلقائياً - محسن بالعامية المصرية
  static String classifyTransaction({
    required String description,
    required String type,
    String? merchantName,
    double? amount,
    String? personName,
  }) {
    final text = '${description.toLowerCase()} ${merchantName?.toLowerCase() ?? ''} ${personName?.toLowerCase() ?? ''}';
    
    // البحث في الكلمات المفتاحية مع الأولوية للمعاملات الشخصية
    final personalCategories = ['سلف وديون', 'معاملات عائلية'];
    
    // أولاً: التحقق من المعاملات الشخصية
    for (final category in personalCategories) {
      final keywords = _categoryKeywords[category] ?? [];
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          if (category == 'سلف وديون') {
            return type == 'income' ? 'استرداد ديون' : 'سلف وديون';
          } else if (category == 'معاملات عائلية') {
            return type == 'income' ? 'مساعدات عائلية' : 'مصروفات عائلية';
          }
        }
      }
    }
    
    // ثانياً: التحقق من الفئات العادية
    for (final category in _categoryKeywords.keys) {
      if (personalCategories.contains(category)) continue; // تجاهل الفئات الشخصية
      
      final keywords = _categoryKeywords[category]!;
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          return category;
        }
      }
    }

    // ثالثاً: تصنيف حسب المبلغ
    if (amount != null) {
      if (type == 'expense') {
        if (amount > 5000) return 'مصروفات كبيرة';
        if (amount < 50) return 'مصروفات صغيرة';
      } else {
        if (amount > 10000) return 'إيرادات كبيرة';
        if (amount < 100) return 'إيرادات صغيرة';
      }
    }

    // التصنيف الافتراضي
    return type == 'income' ? 'إيرادات أخرى' : 'مصروفات أخرى';
  }

  // اقتراح فئات بناءً على النص - محسن
  static List<String> suggestCategories({
    required String description,
    required String type,
    String? merchantName,
    String? personName,
  }) {
    final text = '${description.toLowerCase()} ${merchantName?.toLowerCase() ?? ''} ${personName?.toLowerCase() ?? ''}';
    final suggestions = <String>[];
    final scores = <String, int>{};

    // حساب نقاط كل فئة
    for (final category in _categoryKeywords.keys) {
      final keywords = _categoryKeywords[category]!;
      int score = 0;
      
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          score += keyword.length * 2; // كلمة أطول = نقاط أكثر
          
          // نقاط إضافية للمطابقة الدقيقة
          if (text.split(' ').contains(keyword)) {
            score += 10;
          }
        }
      }
      
      if (score > 0) {
        scores[category] = score;
      }
    }

    // ترتيب الفئات حسب النقاط
    final sortedCategories = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // إرجاع أفضل 5 اقتراحات
    for (final entry in sortedCategories.take(5)) {
      suggestions.add(entry.key);
    }

    return suggestions;
  }

  // تعلم من معاملة جديدة
  static void learnFromTransaction({
    required String description,
    required String category,
    required String type,
    String? merchantName,
    String? personName,
  }) {
    // هنا يمكن إضافة منطق التعلم الآلي
    // حالياً نحفظ في SharedPreferences أو قاعدة البيانات
    _saveUserPattern(description, category, merchantName, personName);
  }

  // حفظ نمط المستخدم - محسن
  static void _saveUserPattern(String description, String category, String? merchantName, String? personName) {
    // تنفيذ حفظ النمط للتعلم المستقبلي
    final pattern = {
      'description': description,
      'category': category,
      'merchant': merchantName,
      'person': personName,
      'timestamp': DateTime.now().toIso8601String(),
    };
    debugPrint('تعلم نمط جديد: $pattern');
  }

  // تحليل أنماط الإنفاق - محسن بالعامية المصرية
  static SpendingAnalysis analyzeSpendingPatterns(List<Map<String, dynamic>> transactions) {
    final categoryTotals = <String, double>{};
    final categoryCount = <String, int>{};
    final merchantFrequency = <String, int>{};
    final personFrequency = <String, int>{};
    
    double totalExpenses = 0;
    double totalIncome = 0;

    for (final transaction in transactions) {
      final amount = (transaction['amount'] as num).toDouble();
      final type = transaction['type'] as String;
      final category = transaction['category'] as String? ?? 'غير مصنف';
      final merchant = transaction['merchant'] as String?;
      final person = transaction['person'] as String?;

      if (type == 'expense') {
        totalExpenses += amount;
        categoryTotals.update(category, (value) => value + amount, ifAbsent: () => amount);
        categoryCount.update(category, (value) => value + 1, ifAbsent: () => 1);
      } else {
        totalIncome += amount;
      }

      if (merchant != null && merchant.isNotEmpty) {
        merchantFrequency.update(merchant, (value) => value + 1, ifAbsent: () => 1);
      }
      
      if (person != null && person.isNotEmpty) {
        personFrequency.update(person, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    // أكثر فئة إنفاق
    String topCategory = 'غير محدد';
    double topCategoryAmount = 0;
    categoryTotals.forEach((category, amount) {
      if (amount > topCategoryAmount) {
        topCategory = category;
        topCategoryAmount = amount;
      }
    });

    // أكثر تاجر تكرار
    String topMerchant = 'غير محدد';
    int topMerchantCount = 0;
    merchantFrequency.forEach((merchant, count) {
      if (count > topMerchantCount) {
        topMerchant = merchant;
        topMerchantCount = count;
      }
    });

    // أكثر شخص تعامل معه
    String topPerson = 'غير محدد';
    int topPersonCount = 0;
    personFrequency.forEach((person, count) {
      if (count > topPersonCount) {
        topPerson = person;
        topPersonCount = count;
      }
    });

    return SpendingAnalysis(
      totalExpenses: totalExpenses,
      totalIncome: totalIncome,
      categoryBreakdown: categoryTotals,
      topCategory: topCategory,
      topCategoryAmount: topCategoryAmount,
      topMerchant: topMerchant,
      topMerchantCount: topMerchantCount,
      topPerson: topPerson,
      topPersonCount: topPersonCount,
      averageTransaction: transactions.isNotEmpty ? totalExpenses / transactions.length : 0,
    );
  }

  // اقتراحات توفير - محسنة بالعامية المصرية
  static List<SavingTip> generateSavingTips(SpendingAnalysis analysis) {
    final tips = <SavingTip>[];

    // نصائح حسب أكثر فئة إنفاق بالعامية المصرية
    if (analysis.topCategory == 'طعام ومشروبات' && analysis.topCategoryAmount > 1500) {
      tips.add(SavingTip(
        title: 'قلل من الأكل بره البيت شوية',
        description: 'إنت بتصرف ${analysis.topCategoryAmount.toInt()} جنيه شهرياً على الطعام والمشروبات. لو طبخت في البيت أكتر هتوفر حوالي ${(analysis.topCategoryAmount * 0.4).toInt()} جنيه.',
        potentialSaving: analysis.topCategoryAmount * 0.4,
        icon: Icons.restaurant_rounded,
      ));
    }

    if (analysis.topCategory == 'مواصلات ووقود' && analysis.topCategoryAmount > 1000) {
      tips.add(SavingTip(
        title: 'جرب المواصلات العامة',
        description: 'مصروفات المواصلات والبنزين عالية شوية. لو استخدمت المترو والأتوبيس أكتر هتوفر ${(analysis.topCategoryAmount * 0.3).toInt()} جنيه.',
        potentialSaving: analysis.topCategoryAmount * 0.3,
        icon: Icons.directions_bus_rounded,
      ));
    }

    if (analysis.topCategory == 'ملابس وتسوق' && analysis.topCategoryAmount > 2000) {
      tips.add(SavingTip(
        title: 'خفف شوية من التسوق',
        description: 'مصروفات الملابس والتسوق كتيرة شوية. حدد ميزانية شهرية وهتوفر ${(analysis.topCategoryAmount * 0.25).toInt()} جنيه.',
        potentialSaving: analysis.topCategoryAmount * 0.25,
        icon: Icons.shopping_bag_rounded,
      ));
    }

    if (analysis.topCategory == 'ترفيه ورياضة' && analysis.topCategoryAmount > 1200) {
      tips.add(SavingTip(
        title: 'نظم مصروفات الترفيه',
        description: 'الترفيه والخروجات بتاخد جزء كبير من فلوسك. لو نظمتها شوية هتوفر ${(analysis.topCategoryAmount * 0.2).toInt()} جنيه.',
        potentialSaving: analysis.topCategoryAmount * 0.2,
        icon: Icons.movie_rounded,
      ));
    }

    // نصيحة عامة للتوفير
    if (analysis.totalExpenses > analysis.totalIncome * 0.85) {
      tips.add(SavingTip(
        title: 'راقب مصروفاتك كويس',
        description: 'مصروفاتك عالية مقارنة بدخلك. حاول توفر على الأقل 15-20% من دخلك الشهري.',
        potentialSaving: analysis.totalIncome * 0.2,
        icon: Icons.savings_rounded,
      ));
    }

    // نصيحة للديون والسلف
    if (analysis.categoryBreakdown['سلف وديون'] != null && 
        analysis.categoryBreakdown['سلف وديون']! > 500) {
      tips.add(SavingTip(
        title: 'قلل من السلف والديون',
        description: 'حاول تقلل من السلف والديون. ده هيخليك تدير فلوسك أحسن وتوفر أكتر.',
        potentialSaving: analysis.categoryBreakdown['سلف وديون']! * 0.5,
        icon: Icons.money_off_rounded,
      ));
    }

    return tips;
  }

  // الحصول على جميع الفئات المتاحة
  static List<String> getAllCategories() {
    return _categoryKeywords.keys.toList()..sort();
  }

  // الحصول على فئات حسب النوع - محسن
  static List<String> getCategoriesByType(String type) {
    final allCategories = _categoryKeywords.keys.toList();
    
    if (type == 'income') {
      return allCategories.where((category) => 
        category.contains('مبيعات') || 
        category.contains('راتب') || 
        category.contains('خدمات') || 
        category.contains('استثمارات') ||
        category.contains('إيرادات') ||
        category.contains('استرداد') ||
        category.contains('مساعدات')
      ).toList();
    } else {
      return allCategories.where((category) => 
        !category.contains('مبيعات') && 
        !category.contains('راتب') && 
        !category.contains('خدمات') && 
        !category.contains('استثمارات') &&
        !category.contains('إيرادات') &&
        !category.contains('استرداد') &&
        !category.contains('مساعدات')
      ).toList();
    }
  }

  // الحصول على الكلمات المفتاحية لفئة معينة
  static List<String> getKeywordsForCategory(String category) {
    return _categoryKeywords[category] ?? [];
  }
}

// نموذج تحليل أنماط الإنفاق - محسن
class SpendingAnalysis {
  final double totalExpenses;
  final double totalIncome;
  final Map<String, double> categoryBreakdown;
  final String topCategory;
  final double topCategoryAmount;
  final String topMerchant;
  final int topMerchantCount;
  final String topPerson;
  final int topPersonCount;
  final double averageTransaction;

  SpendingAnalysis({
    required this.totalExpenses,
    required this.totalIncome,
    required this.categoryBreakdown,
    required this.topCategory,
    required this.topCategoryAmount,
    required this.topMerchant,
    required this.topMerchantCount,
    required this.topPerson,
    required this.topPersonCount,
    required this.averageTransaction,
  });

  double get savingsRate => totalIncome > 0 ? (totalIncome - totalExpenses) / totalIncome : 0;
  
  bool get isHealthySpending => savingsRate >= 0.2; // توفير 20% أو أكثر
  
  String get savingsRateText {
    if (savingsRate >= 0.3) return 'ممتاز في التوفير! 👏';
    if (savingsRate >= 0.2) return 'كويس في التوفير 👍';
    if (savingsRate >= 0.1) return 'محتاج تحسن التوفير شوية ⚠️';
    return 'لازم تراجع مصروفاتك! 🚨';
  }
}

// نموذج نصائح التوفير
class SavingTip {
  final String title;
  final String description;
  final double potentialSaving;
  final IconData icon;

  SavingTip({
    required this.title,
    required this.description,
    required this.potentialSaving,
    required this.icon,
  });
} 