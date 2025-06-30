import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceAssistantService {
  static final SpeechToText _speechToText = SpeechToText();
  static bool _isInitialized = false;
  static bool _isListening = false;

  // كولكشن أسماء مصرية شائعة
  static const List<String> _egyptianNames = [
    // أسماء رجال
    'أحمد', 'محمد', 'علي', 'حسن', 'عبدالله', 'عمر', 'يوسف', 'إبراهيم', 'خالد', 'مصطفى',
    'محمود', 'عبدالرحمن', 'سعد', 'طارق', 'هشام', 'أشرف', 'وليد', 'كريم', 'عماد', 'أيمن',
    'رامي', 'شريف', 'مجدي', 'سمير', 'جمال', 'كمال', 'فؤاد', 'منصور', 'رفعت', 'صلاح',
    'فهد', 'بسام', 'عادل', 'نبيل', 'فاروق', 'حمدي', 'رضا', 'تامر', 'عصام', 'حاتم',
    'مينا', 'جورج', 'فادي', 'شنودة', 'مجدي', 'عماد', 'ناجي', 'صبحي', 'رؤوف', 'ملاك',
    
    // أسماء نساء
    'فاطمة', 'عائشة', 'خديجة', 'زينب', 'مريم', 'سارة', 'نورا', 'دينا', 'ريم', 'هبة',
    'أميرة', 'نادية', 'سميرة', 'فريدة', 'نجلاء', 'إيمان', 'سعاد', 'منال', 'نيفين', 'رانيا',
    'داليا', 'شيماء', 'إسراء', 'حنان', 'وفاء', 'أمل', 'سلوى', 'عبير', 'نهى', 'رشا',
    'ياسمين', 'نسرين', 'غادة', 'لمياء', 'نوال', 'سناء', 'إلهام', 'نور', 'مها', 'ميادة',
    'ماري', 'نانسي', 'نرمين', 'سوسن', 'فيفي', 'ليلى', 'بسمة', 'رضوى', 'أسماء', 'آية',
    
    // أسماء أجنبية شائعة في مصر
    'جون', 'بيتر', 'مايكل', 'أنطون', 'باسم', 'شادي', 'مارك', 'سايمون', 'إدوارد', 'أنطونيو',
    'جولي', 'نانسي', 'ساندرا', 'كريستين', 'فيكتوريا', 'باتريشيا', 'إيفا', 'لينا', 'كارمن', 'سيلفيا',
    
    // ألقاب مصرية شائعة
    'أبو', 'أم', 'حاج', 'حاجة', 'دكتور', 'دكتورة', 'أستاذ', 'أستاذة', 'مدام', 'بيه',
    'أفندي', 'باشا', 'شيخ', 'معلم', 'عم', 'خال', 'عمو', 'تيتة', 'جدو'
  ];

  // كولكشن كلمات الديون والسلف والمعاملات الشخصية
  static const Map<String, List<String>> _transactionKeywords = {
    'debt_lending': [
      // سلف وديون
      'سلفة', 'سلف', 'دين', 'استلف', 'اقرض', 'قرض', 'مدين', 'عليه', 'ليه',
      'مديون', 'دائن', 'استلفت', 'اقرضت', 'سلفته', 'سلفتها', 'أخذ مني',
      'خد مني', 'ادالي', 'اداني', 'رد', 'رجع', 'سدد', 'دفع', 'قسط',
      'تقسيط', 'متأخر', 'مستحق', 'باقي', 'فاضل', 'تمام', 'خلاص'
    ],
    
    'buying_selling': [
      // بيع وشراء
      'بيع', 'باع', 'بعت', 'اشترى', 'اشتريت', 'شراء', 'بضاعة', 'سلعة',
      'منتج', 'حاجة', 'خدمة', 'صفقة', 'عملية', 'تجارة', 'مبيعات',
      'عميل', 'زبون', 'مشتري', 'بائع', 'تاجر', 'محل', 'دكان'
    ],
    
    'rent_services': [
      // إيجار وخدمات
      'إيجار', 'ايجار', 'شقة', 'بيت', 'محل', 'مكتب', 'عمارة', 'فيلا',
      'مالك', 'مستأجر', 'عقد', 'إيصال', 'سند', 'شهري', 'سنوي',
      'مقدم', 'تأمين', 'عمولة', 'وساطة', 'سمسرة', 'عقار'
    ],
    
    'work_salary': [
      // عمل ومرتب
      'شغل', 'عمل', 'وظيفة', 'راتب', 'مرتب', 'أجر', 'حافز', 'مكافأة',
      'بونص', 'عمولة', 'نسبة', 'فريلانس', 'مشروع', 'تعاقد', 'استشارة',
      'خدمة', 'موظف', 'عامل', 'مدير', 'صاحب شغل', 'شريك'
    ],
    
    'family_personal': [
      // معاملات عائلية وشخصية
      'أبوي', 'أمي', 'أخويا', 'أختي', 'جوزي', 'مراتي', 'ابني', 'بنتي',
      'عمي', 'خالي', 'عمتي', 'خالتي', 'جدي', 'تيتتي', 'حماتي', 'حموي',
      'صحبي', 'صاحبي', 'حبيبي', 'صديق', 'صديقة', 'جار', 'جارة',
      'قريب', 'حد من أهلي', 'واحد أعرفه', 'معارف'
    ]
  };

  // تهيئة المساعد الصوتي
  static Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) => debugPrint('خطأ في التعرف الصوتي: $error'),
        onStatus: (status) => debugPrint('حالة التعرف الصوتي: $status'),
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('خطأ في تهيئة المساعد الصوتي: $e');
      return false;
    }
  }

  // بدء الاستماع
  static Future<String?> startListening({
    Duration timeout = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return null;
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      final isAvailable = await _speechToText.hasPermission;
      if (!isAvailable) {
        throw Exception('لا يوجد إذن للميكروفون');
      }

      String recognizedText = '';
      
      await _speechToText.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
        },
        listenFor: timeout,
        pauseFor: pauseFor,
        localeId: 'ar_EG', // العربية المصرية
        cancelOnError: true,
        partialResults: false,
      );

      _isListening = true;
      
      // انتظار حتى ينتهي الاستماع
      while (_speechToText.isListening) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      _isListening = false;
      return recognizedText.isNotEmpty ? recognizedText : null;
    } catch (e) {
      _isListening = false;
      throw Exception('خطأ في الاستماع: ${e.toString()}');
    }
  }

  // إيقاف الاستماع
  static Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    _isListening = false;
  }

  // التحقق من حالة الاستماع
  static bool get isListening => _isListening;

  // التحقق من توفر الخدمة
  static bool get isAvailable => _isInitialized;

  // تحليل النص المنطوق وتحويله لمعاملة - محسن بالأسماء والمعاملات الشخصية
  static TransactionInput? parseVoiceInput(String voiceText) {
    final text = voiceText.toLowerCase().trim();
    
    // البحث عن نوع المعاملة بالعامية المصرية
    String type = 'expense';
    
    // كلمات للإيرادات بالعامية المصرية
    final incomeWords = [
      'حصلت', 'كسبت', 'دخل', 'ربحت', 'جالي', 'وصلني', 'اتقبضت', 
      'قبضت', 'استلمت', 'جمعت', 'باعت', 'بعت', 'شغلت', 'اشتغلت',
      'عملت', 'حققت', 'لقيت', 'اخدت', 'جاني', 'وصل', 'دخلولي',
      'رد', 'رجع', 'سدد', 'اداني', 'ادالي'  // إضافة كلمات استرداد الديون
    ];
    
    for (final word in incomeWords) {
      if (text.contains(word)) {
        type = 'income';
        break;
      }
    }

    // البحث عن المبلغ
    double? amount = _extractAmount(text);
    if (amount == null) return null;

    // البحث عن الوصف/المصدر
    String description = _extractDescription(text);

    // البحث عن اسم الشخص
    String? personName = _extractPersonName(text);
    if (personName != null) {
      description = description.isEmpty ? personName : '$description - $personName';
    }

    // البحث عن الفئة
    String category = _extractCategory(text, type);

    return TransactionInput(
      type: type,
      amount: amount,
      description: description,
      category: category,
      confidence: _calculateConfidence(text, amount, description),
      personName: personName,
    );
  }

  // استخراج اسم الشخص من النص
  static String? _extractPersonName(String text) {
    // البحث عن أنماط مثل "لأحمد" أو "من علي" أو "مع سارة"
    final prepositionPatterns = [
      RegExp(r'ل\s*([أا-ي]+)', caseSensitive: false),       // لأحمد
      RegExp(r'من\s*([أا-ي]+)', caseSensitive: false),      // من علي
      RegExp(r'مع\s*([أا-ي]+)', caseSensitive: false),      // مع سارة
      RegExp(r'عند\s*([أا-ي]+)', caseSensitive: false),     // عند حسن
      RegExp(r'على\s*([أا-ي]+)', caseSensitive: false),     // على محمد
      RegExp(r'إيجار\s*([أا-ي]+)', caseSensitive: false),   // إيجار أحمد
      RegExp(r'سلفة\s*([أا-ي]+)', caseSensitive: false),    // سلفة مينا
      RegExp(r'دين\s*([أا-ي]+)', caseSensitive: false),     // دين سعد
    ];

    for (final pattern in prepositionPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final potentialName = match.group(1)?.trim();
        if (potentialName != null && _isValidName(potentialName)) {
          return potentialName;
        }
      }
    }

    // البحث المباشر في الأسماء
    for (final name in _egyptianNames) {
      if (text.contains(name.toLowerCase())) {
        return name;
      }
    }

    return null;
  }

  // التحقق من صحة الاسم
  static bool _isValidName(String name) {
    return _egyptianNames.any((validName) => 
      validName.toLowerCase() == name.toLowerCase());
  }

  // استخراج المبلغ من النص - محسن بالعامية المصرية
  static double? _extractAmount(String text) {
    // أنماط مختلفة للمبالغ بالعامية المصرية
    final patterns = [
      // أنماط رسمية
      RegExp(r'(\d+)\s*جنيه'),
      RegExp(r'(\d+)\s*ج\.م'),
      RegExp(r'(\d+)\s*£'),
      RegExp(r'(\d+)\s*ج'),
      
      // أنماط عامية مصرية
      RegExp(r'(\d+)\s*جني'),
      RegExp(r'(\d+)\s*قرش'),
      RegExp(r'(\d+)\s*ملي'),
      RegExp(r'(\d+)\s*الف'),
      RegExp(r'(\d+)\s*مليون'),
      
      // أنماط إنجليزية
      RegExp(r'(\d+)\s*pound'),
      RegExp(r'(\d+)\s*egp'),
      RegExp(r'(\d+)\s*le'),
      
      // أي رقم
      RegExp(r'(\d+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1);
        final amount = double.tryParse(amountStr!);
        if (amount != null && amount > 0 && amount < 999999) {
          return amount;
        }
      }
    }

    // البحث عن الأرقام المكتوبة بالكلمات بالعامية المصرية
    return _parseWrittenNumbers(text);
  }

  // تحويل الأرقام المكتوبة بالكلمات - محسن بالعامية المصرية
  static double? _parseWrittenNumbers(String text) {
    final numberWords = {
      // أرقام أساسية
      'واحد': 1, 'اتنين': 2, 'ثلاثة': 3, 'أربعة': 4, 'خمسة': 5,
      'ستة': 6, 'سبعة': 7, 'ثمانية': 8, 'تسعة': 9, 'عشرة': 10,
      
      // أرقام عامية مصرية
      'واحده': 1, 'اثنان': 2, 'اثنين': 2, 'تلاتة': 3, 'اربعة': 4, 'خمسه': 5,
      'سته': 6, 'سبعه': 7, 'تمانية': 8, 'تسعه': 9, 'عشره': 10,
      
      // عشرات
      'عشرين': 20, 'ثلاثين': 30, 'أربعين': 40, 'خمسين': 50,
      'ستين': 60, 'سبعين': 70, 'ثمانين': 80, 'تسعين': 90,
      
      // عشرات عامية
      'عشرين': 20, 'تلاتين': 30, 'اربعين': 40, 'خمسين': 50,
      'ستين': 60, 'سبعين': 70, 'تمانين': 80, 'تسعين': 90,
      
      // مئات وآلاف
      'مية': 100, 'مائة': 100, 'ميه': 100, 'مئة': 100,
      'ألف': 1000, 'الف': 1000, 'ميت': 100,
      
      // أرقام كبيرة عامية
      'الفين': 2000, 'تلات آلاف': 3000, 'اربع آلاف': 4000,
      'خمس آلاف': 5000, 'عشر آلاف': 10000, 'عشرين الف': 20000,
    };

    double total = 0;
    for (final entry in numberWords.entries) {
      if (text.contains(entry.key)) {
        total += entry.value;
      }
    }

    return total > 0 ? total : null;
  }

  // استخراج الوصف بالعامية المصرية
  static String _extractDescription(String text) {
    // إزالة الكلمات الشائعة بالعامية المصرية
    final commonWords = [
      // كلمات دفع
      'دفعت', 'صرفت', 'اشتريت', 'خدت', 'ادفع', 'دفعت',
      'اتصرف', 'اتخد', 'اخدت', 'جبت', 'دفع',
      
      // كلمات استلام
      'حصلت', 'كسبت', 'جالي', 'وصلني', 'قبضت', 'استلمت',
      'جمعت', 'باعت', 'بعت', 'جاني', 'وصل', 'رد', 'رجع',
      
      // عملة
      'جنيه', 'جني', 'ج', 'قرش', 'ملي', 'الف', 'مية',
      
      // حروف جر وأدوات
      'من', 'في', 'على', 'عند', 'لـ', 'ل', 'بـ', 'ب', 'مع',
      'عشان', 'علشان', 'عاوز', 'عايز', 'محتاج',
    ];
    
    List<String> words = text.split(' ');
    
    // إزالة الأرقام والكلمات الشائعة والأسماء
    words = words.where((word) {
      final cleanWord = word.trim();
      return !commonWords.contains(cleanWord) && 
             !RegExp(r'^\d+$').hasMatch(cleanWord) &&
             !_egyptianNames.any((name) => name.toLowerCase() == cleanWord.toLowerCase());
    }).toList();

    return words.join(' ').trim();
  }

  // استخراج الفئة بالعامية المصرية مع التركيز على المعاملات الشخصية
  static String _extractCategory(String text, String type) {
    // التحقق من وجود كلمات الديون والسلف أولاً
    for (final entry in _transactionKeywords.entries) {
      for (final keyword in entry.value) {
        if (text.contains(keyword)) {
          switch (entry.key) {
            case 'debt_lending':
              return type == 'income' ? 'استرداد ديون' : 'سلف وديون';
            case 'buying_selling':
              return type == 'income' ? 'مبيعات' : 'مشتريات';
            case 'rent_services':
              return type == 'income' ? 'إيجارات' : 'إيجار وخدمات';
            case 'work_salary':
              return type == 'income' ? 'راتب وأجور' : 'مصروفات عمل';
            case 'family_personal':
              return type == 'income' ? 'مساعدات عائلية' : 'مصروفات شخصية';
          }
        }
      }
    }

    if (type == 'income') {
      // فئات الإيرادات بالعامية المصرية
      if (text.contains('مبيعات') || text.contains('بيع') || text.contains('بعت') || 
          text.contains('شغل') || text.contains('زبون') || text.contains('عميل')) {
        return 'مبيعات';
      }
      if (text.contains('راتب') || text.contains('مرتب') || text.contains('معاش') || 
          text.contains('شهرية') || text.contains('اجر')) {
        return 'راتب';
      }
      if (text.contains('خدمة') || text.contains('خدمات') || text.contains('شغلانة') || 
          text.contains('فريلانس') || text.contains('مشروع')) {
        return 'خدمات';
      }
      if (text.contains('فايدة') || text.contains('فوائد') || text.contains('أرباح') || 
          text.contains('عوائد') || text.contains('استثمار')) {
        return 'استثمارات';
      }
      return 'إيرادات أخرى';
    } else {
      // فئات المصروفات بالعامية المصرية
      
      // طعام ومشروبات
      if (text.contains('أكل') || text.contains('طعام') || text.contains('مطعم') || 
          text.contains('كشري') || text.contains('فول') || text.contains('طعمية') ||
          text.contains('مولوخية') || text.contains('رز') || text.contains('فراخ') ||
          text.contains('لحمة') || text.contains('سمك') || text.contains('عصير') ||
          text.contains('شاي') || text.contains('قهوة') || text.contains('كافيه') ||
          text.contains('احوة') || text.contains('شيشة') || text.contains('مقهى')) {
        return 'طعام ومشروبات';
      }
      
      // مواصلات ووقود
      if (text.contains('بنزين') || text.contains('وقود') || text.contains('سولار') || 
          text.contains('تاكسي') || text.contains('أوبر') || text.contains('كريم') ||
          text.contains('مترو') || text.contains('أتوبيس') || text.contains('ميكروباص') ||
          text.contains('توك توك') || text.contains('عربية') || text.contains('جراج') ||
          text.contains('موقف') || text.contains('كوبري') || text.contains('رسوم') ||
          text.contains('محطة') || text.contains('المحطة')) {
        return 'مواصلات ووقود';
      }
      
      // فواتير ومرافق
      if (text.contains('كهربا') || text.contains('كهرباء') || text.contains('مياه') ||
          text.contains('غاز') || text.contains('تليفون') || text.contains('موبايل') ||
          text.contains('انترنت') || text.contains('إنترنت') || text.contains('نت') ||
          text.contains('كابل') || text.contains('فودافون') || text.contains('اتصالات') ||
          text.contains('أورانج') || text.contains('we') || text.contains('فاتورة')) {
        return 'فواتير ومرافق';
      }
      
      // سكن وإيجار
      if (text.contains('إيجار') || text.contains('ايجار') || text.contains('سكن') ||
          text.contains('شقة') || text.contains('بيت') || text.contains('عمارة') ||
          text.contains('فيلا') || text.contains('صيانة') || text.contains('أثاث') ||
          text.contains('تكييف') || text.contains('دهان') || text.contains('نجار') ||
          text.contains('كهربائي') || text.contains('سباك') || text.contains('عمارة')) {
        return 'سكن وإيجار';
      }
      
      // صحة وأدوية
      if (text.contains('صيدلية') || text.contains('دكتور') || text.contains('طبيب') ||
          text.contains('دواء') || text.contains('علاج') || text.contains('مستشفى') ||
          text.contains('عيادة') || text.contains('أسنان') || text.contains('عيون') ||
          text.contains('تحليل') || text.contains('أشعة') || text.contains('عملية') ||
          text.contains('كشف') || text.contains('دكتورة') || text.contains('ممرضة')) {
        return 'صحة وأدوية';
      }
      
      // ملابس وتسوق
      if (text.contains('ملابس') || text.contains('هدوم') || text.contains('جزمة') ||
          text.contains('حذاء') || text.contains('شنطة') || text.contains('ساعة') ||
          text.contains('موبايل جديد') || text.contains('لابتوب') || text.contains('تابلت') ||
          text.contains('سوق') || text.contains('مول') || text.contains('متجر') ||
          text.contains('محل') || text.contains('جلابية') || text.contains('فستان') ||
          text.contains('قميص') || text.contains('بنطلون') || text.contains('تيشيرت')) {
        return 'ملابس وتسوق';
      }
      
      // تعليم وثقافة
      if (text.contains('مدرسة') || text.contains('جامعة') || text.contains('كورس') ||
          text.contains('دورة') || text.contains('كتاب') || text.contains('مذكرة') ||
          text.contains('مدرس خصوصي') || text.contains('رسوم') || text.contains('مصروفات') ||
          text.contains('أدوات') || text.contains('تعليم') || text.contains('درس') ||
          text.contains('امتحان') || text.contains('جامعه') || text.contains('كلية')) {
        return 'تعليم وثقافة';
      }
      
      // ترفيه ورياضة
      if (text.contains('سينما') || text.contains('مسرح') || text.contains('حفلة') ||
          text.contains('مباراة') || text.contains('جيم') || text.contains('نادي') ||
          text.contains('رياضة') || text.contains('ملاهي') || text.contains('رحلة') ||
          text.contains('سفر') || text.contains('فندق') || text.contains('مصيف') ||
          text.contains('بحر') || text.contains('جيم') || text.contains('كورة') ||
          text.contains('فيتنس') || text.contains('تمرين')) {
        return 'ترفيه ورياضة';
      }
      
      return 'مصروفات أخرى';
    }
  }

  // حساب مستوى الثقة - محسن للعامية المصرية
  static double _calculateConfidence(String text, double amount, String description) {
    double confidence = 0.0;

    // وجود مبلغ واضح
    if (amount > 0) confidence += 0.3;

    // وجود كلمات مفتاحية بالعامية المصرية
    final keywords = [
      // كلمات دفع
      'دفعت', 'صرفت', 'اشتريت', 'خدت', 'ادفع', 'اتصرف',
      
      // كلمات استلام
      'حصلت', 'كسبت', 'جالي', 'وصلني', 'قبضت', 'استلمت',
      
      // عملة
      'جنيه', 'جني', 'ج', 'قرش', 'ملي',
      
      // أماكن مصرية شائعة
      'كشري', 'فول', 'طعمية', 'مولوخية', 'كافيه', 'احوة',
      'تاكسي', 'أوبر', 'كريم', 'مترو', 'ميكروباص', 'توك توك',
      'صيدلية', 'دكتور', 'مستشفى', 'سوق', 'مول',
      
      // كلمات ديون وسلف
      'سلفة', 'دين', 'استلف', 'اقرض', 'رد', 'سدد'
    ];
    
    int keywordCount = 0;
    for (final keyword in keywords) {
      if (text.contains(keyword)) keywordCount++;
    }
    confidence += (keywordCount / keywords.length) * 0.2;

    // وجود وصف
    if (description.isNotEmpty) confidence += 0.2;

    // وجود اسم شخص
    if (_extractPersonName(text) != null) confidence += 0.3;

    return confidence.clamp(0.0, 1.0);
  }

  // أمثلة للمساعدة - بالعامية المصرية الحلوة مع الأسماء
  static List<String> getVoiceExamples() {
    return [
      // أمثلة مصروفات مع أسماء
      'دفعت خمسمية جنيه إيجار لأحمد سعد',
      'صرفت أربعمية جنيه لمينا',
      'سلفت علي مائتين جنيه',
      'دفعت لمحمد تلتمية جنيه دين',
      'اشتريت من فاطمة بضاعة بخمسين جنيه',
      'خدت دواء من صيدلية دكتور حسن بمائة جنيه',
      'دفعت لسارة مية جنيه',
      'اشتريت هدوم من محل نادية بتلتمية جنيه',
      'صرفت في كافيه مع رامي عشرين جنيه',
      'دفعت لحاج محمود الف جنيه إيجار المحل',
      
      // أمثلة إيرادات مع أسماء
      'حصلت من أحمد ألف جنيه راتب',
      'كسبت من بيع بضاعة لعلي خمسمية جنيه',
      'جالي من طارق الفين جنيه',
      'قبضت من العميل هشام تلاتمية جنيه',
      'رد لي كريم مائتين جنيه دين',
      'بعت لأميرة حاجة بمائة جنيه',
      'عملت شغلانة لدينا بخمسمية جنيه',
      'وصلني من شريف الف وخمسمية راتب',
      'اداني مجدي مية جنيه كان مستلفها',
      'جمعت من مبيعات اليوم ألف جنيه',
      
      // أمثلة عائلية
      'دفعت لأبوي خمسمية جنيه',
      'حصلت من أمي مائة جنيه',
      'سلفت أخويا تلتمية جنيه',
      'جالي من عمي ألف جنيه هدية',
      'دفعت لصحبي أحمد مائتين جنيه',
    ];
  }

  // التحقق من الصلاحيات
  static Future<bool> hasPermission() async {
    return await _speechToText.hasPermission;
  }

  // طلب الصلاحيات
  static Future<bool> requestPermission() async {
    return await _speechToText.hasPermission;
  }

  // تنظيف الموارد
  static void dispose() {
    _speechToText.cancel();
    _isInitialized = false;
    _isListening = false;
  }

  // الحصول على قائمة الأسماء المصرية
  static List<String> getEgyptianNames() => _egyptianNames;

  // الحصول على كلمات المعاملات
  static Map<String, List<String>> getTransactionKeywords() => _transactionKeywords;
}

// نموذج لمدخلات المعاملة الصوتية - محسن بإضافة اسم الشخص
class TransactionInput {
  final String type;
  final double amount;
  final String description;
  final String category;
  final double confidence;
  final String? personName;

  TransactionInput({
    required this.type,
    required this.amount,
    required this.description,
    required this.category,
    required this.confidence,
    this.personName,
  });

  bool get isValid => confidence > 0.5 && amount > 0;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'description': description,
      'category': category,
      'confidence': confidence,
      'personName': personName,
    };
  }
} 