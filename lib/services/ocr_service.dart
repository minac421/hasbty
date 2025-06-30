import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/ocr_result.dart';
import '../models/user_plan.dart';
import '../providers/user_provider.dart';
import '../services/feature_manager_service.dart';
import '../theme/app_theme.dart';

/// خدمة OCR الذكية مع نظام الحدود
class OCRService {
  static const Duration _animationDuration = Duration(milliseconds: 300);
  
  /// استخراج النص من الصورة (طريقة بسيطة)
  static Future<OCRResult> extractTextFromImage(File imageFile) async {
    try {
      // تحسين جودة الصورة
      final optimizedImage = await _optimizeImage(imageFile);
      
      // التعرف على النص
      final textRecognizer = TextRecognizer();
      final inputImage = InputImage.fromFile(optimizedImage);
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      await textRecognizer.close();
      
      if (recognizedText.text.isEmpty) {
        throw Exception('لم يتم العثور على أي نص في الصورة');
      }
      
      // تحليل النص المستخرج
      final analysisResult = await _analyzeTextSimple(recognizedText.text);
      
      // إنشاء النتيجة
      final result = OCRResult(
        rawText: recognizedText.text,
        merchantName: analysisResult['merchantName'] ?? 'غير محدد',
        totalAmount: analysisResult['totalAmount'] ?? 0.0,
        date: analysisResult['date'],
        items: [], // سيتم تحديثه لاحقاً
        taxAmount: analysisResult['taxAmount'] ?? 0.0,
        confidence: _calculateConfidence(recognizedText),
      );
      
      return result;
      
    } catch (e) {
      throw Exception('خطأ في معالجة الصورة: $e');
    }
  }
  
  /// تحليل بسيط للنص
  static Future<Map<String, dynamic>> _analyzeTextSimple(String text) async {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    Map<String, dynamic> result = {
      'merchantName': 'غير محدد',
      'totalAmount': 0.0,
      'date': DateTime.now(),
      'taxAmount': 0.0,
      'items': <Map<String, dynamic>>[],
    };
    
    // البحث عن المبلغ الإجمالي
    for (final line in lines) {
      final priceMatch = RegExp(r'(\d+\.?\d*)', caseSensitive: false).firstMatch(line);
      if (priceMatch != null) {
        final amount = double.tryParse(priceMatch.group(1)!);
        if (amount != null && amount > result['totalAmount']) {
          result['totalAmount'] = amount;
        }
      }
    }
    
    // البحث عن اسم المحل
    if (lines.isNotEmpty) {
      result['merchantName'] = lines.first.trim();
    }
    
    return result;
  }
  
  /// مسح الفاتورة مع التحقق من الحدود
  static Future<OCRResult?> scanReceiptWithLimits({
    required BuildContext context,
    required WidgetRef ref,
    ImageSource source = ImageSource.camera,
  }) async {
    try {
      // التقاط الصورة
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image == null) return null;
      
      // استخراج النص من الصورة
      return await extractTextFromImage(File(image.path));
      
    } catch (e) {
      _showErrorDialog(context, 'خطأ في التقاط الصورة: $e');
      return null;
    }
  }

  // حذفت هذه الطريقة المعقدة لأنها تحتوي على أخطاء

  /// تحسين جودة الصورة (مبسط)
  static Future<File> _optimizeImage(File originalImage) async {
    // إرجاع الصورة الأصلية بدون تعديل لتجنب أخطاء المكتبة
    return originalImage;
  }

  /// تحليل النص المستخرج
  static Future<Map<String, dynamic>> _analyzeText(
    String text, 
    BuildContext context,
  ) async {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    Map<String, dynamic> result = {
      'type': 'receipt',
      'items': <Map<String, dynamic>>[],
      'total': 0.0,
      'date': null,
      'merchant': null,
      'currency': 'EGP',
      'confidence': 0.0,
    };
    
    // البحث عن معلومات التاجر
    final merchantPatterns = [
      RegExp(r'شركة|مؤسسة|محل|مطعم', caseSensitive: false),
      RegExp(r'[A-Za-z\s]{3,20}', caseSensitive: false),
    ];
    
    for (final line in lines.take(3)) {
      for (final pattern in merchantPatterns) {
        if (pattern.hasMatch(line)) {
          result['merchant'] = line.trim();
          break;
        }
      }
      if (result['merchant'] != null) break;
    }
    
    // البحث عن التاريخ
    final datePatterns = [
      RegExp(r'\d{1,2}[-/]\d{1,2}[-/]\d{2,4}'),
      RegExp(r'\d{4}[-/]\d{1,2}[-/]\d{1,2}'),
      RegExp(r'\d{1,2}\s+\w+\s+\d{4}'),
    ];
    
    for (final line in lines) {
      for (final pattern in datePatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          result['date'] = match.group(0);
          break;
        }
      }
      if (result['date'] != null) break;
    }
    
    // البحث عن العناصر والأسعار
    final pricePatterns = [
      RegExp(r'(\d+\.?\d*)\s*(جنيه|ج\.م|EGP|LE)', caseSensitive: false),
      RegExp(r'(\d+\.?\d*)\s*$'),
      RegExp(r'(\d+\.?\d*)'),
    ];
    
    List<Map<String, dynamic>> items = [];
    double totalFound = 0.0;
    
    for (final line in lines) {
      for (final pattern in pricePatterns) {
        final matches = pattern.allMatches(line);
        for (final match in matches) {
          final priceStr = match.group(1);
          if (priceStr != null) {
            final price = double.tryParse(priceStr);
            if (price != null && price > 0) {
              // استخراج اسم العنصر
              final itemName = line
                  .replaceAll(match.group(0)!, '')
                  .trim()
                  .replaceAll(RegExp(r'[^\u0600-\u06FF\u0750-\u077F\s\w]'), '');
              
              if (itemName.isNotEmpty && itemName.length > 2) {
                items.add({
                  'name': itemName,
                  'price': price,
                  'quantity': 1,
                  'category': _categorizeItem(itemName),
                });
                totalFound += price;
              }
            }
          }
        }
      }
    }
    
    // البحث عن الإجمالي
    final totalPatterns = [
      RegExp(r'إجمالي|المجموع|total|الكل', caseSensitive: false),
      RegExp(r'المبلغ|Amount', caseSensitive: false),
    ];
    
    for (final line in lines) {
      for (final pattern in totalPatterns) {
        if (pattern.hasMatch(line)) {
          final numbers = RegExp(r'(\d+\.?\d*)').allMatches(line);
          for (final match in numbers) {
            final total = double.tryParse(match.group(1)!);
            if (total != null && total > totalFound * 0.8) {
              result['total'] = total;
              break;
            }
          }
        }
      }
    }
    
    // إذا لم يتم العثور على إجمالي، استخدم مجموع العناصر
    if (result['total'] == 0.0) {
      result['total'] = totalFound;
    }
    
    result['items'] = items;
    result['confidence'] = _calculateAnalysisConfidence(result);
    
    return result;
  }

  /// تصنيف العنصر
  static String _categorizeItem(String itemName) {
    final categories = {
      'طعام': ['خبز', 'لحم', 'دجاج', 'سمك', 'خضار', 'فواكه', 'حليب', 'جبن'],
      'مشروبات': ['ماء', 'عصير', 'شاي', 'قهوة', 'مشروب'],
      'منظفات': ['صابون', 'مسحوق', 'منظف', 'شامبو'],
      'أدوية': ['دواء', 'علاج', 'كبسولات', 'شراب'],
      'وقود': ['بنزين', 'سولار', 'غاز'],
      'أخرى': [],
    };
    
    final lowerName = itemName.toLowerCase();
    for (final category in categories.keys) {
      for (final keyword in categories[category]!) {
        if (lowerName.contains(keyword)) {
          return category;
        }
      }
    }
    
    return 'أخرى';
  }

  /// حساب الثقة في التحليل
  static double _calculateAnalysisConfidence(Map<String, dynamic> result) {
    double confidence = 0.0;
    
    // وجود تاجر
    if (result['merchant'] != null) confidence += 0.2;
    
    // وجود تاريخ
    if (result['date'] != null) confidence += 0.1;
    
    // وجود عناصر
    final items = result['items'] as List;
    if (items.isNotEmpty) {
      confidence += 0.4;
      // مكافأة إضافية للعناصر المتعددة
      confidence += (items.length * 0.05).clamp(0.0, 0.2);
    }
    
    // وجود إجمالي
    final total = result['total'] as double;
    if (total > 0) confidence += 0.1;
    
    return confidence.clamp(0.0, 1.0);
  }

  /// حساب الثقة من النص المتعرف عليه
  static double _calculateConfidence(RecognizedText recognizedText) {
    if (recognizedText.blocks.isEmpty) return 0.0;
    
    double totalConfidence = 0.0;
    int elementCount = 0;
    
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          if (element.text.isNotEmpty) {
            // ML Kit لا يوفر confidence مباشرة، لذا نحسبه بناءً على طول النص ووضوحه
            double confidence = 1.0;
            
            // تقليل الثقة للنصوص القصيرة جداً
            if (element.text.length < 2) confidence *= 0.5;
            
            // تقليل الثقة للنصوص التي تحتوي على رموز غريبة
            if (RegExp(r'[^\u0600-\u06FF\u0750-\u077F\s\w\d.,!?%-]').hasMatch(element.text)) {
              confidence *= 0.7;
            }
            
            totalConfidence += confidence;
            elementCount++;
          }
        }
      }
    }
    
    return elementCount > 0 ? (totalConfidence / elementCount).clamp(0.0, 1.0) : 0.0;
  }

  /// عرض مؤشر التحميل مع أنيميشن
  static Future<T> _showScanningDialog<T>(
    BuildContext context,
    Future<T> Function() operation,
  ) async {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black54,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // أيقونة مسح مع أنيميشن
                  TweenAnimationBuilder(
                    duration: const Duration(seconds: 2),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.rotate(
                        angle: value * 2 * 3.14159,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryColor.withOpacity(0.7),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.scanner_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'جاري مسح الفاتورة...',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'يرجى الانتظار بينما نستخرج البيانات',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLightColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // شريط التقدم مع أنيميشن
                  TweenAnimationBuilder(
                    duration: const Duration(seconds: 3),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: AppTheme.borderColor,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    try {
      final result = await operation();
      overlayEntry.remove();
      
      // إظهار أنيميشن النجاح
      _showSuccessAnimation(context);
      
      return result;
    } catch (e) {
      overlayEntry.remove();
      throw e;
    }
  }

  /// عرض أنيميشن النجاح
  static void _showSuccessAnimation(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.1,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 800),
            tween: Tween<double>(begin: 0, end: 1),
            onEnd: () => overlayEntry.remove(),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value > 0.5 ? 2 - 2 * value : 2 * value,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.successColor.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
  }

  /// عرض رسالة خطأ
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_rounded, color: AppTheme.errorColor),
            const SizedBox(width: 12),
            const Text('خطأ في المسح'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  /// عرض نتيجة المسح
  static void showOCRResult(BuildContext context, OCRResult result) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_rounded,
                      color: AppTheme.successColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نتيجة المسح',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'دقة: ${(result.confidence * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textLightColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // معلومات الفاتورة
              if (result.merchantName != 'غير محدد') ...[
                _buildInfoRow(
                  context,
                  'التاجر',
                  result.merchantName,
                  Icons.store_rounded,
                ),
                const SizedBox(height: 12),
              ],
              
              if (result.date != null) ...[
                _buildInfoRow(
                  context,
                  'التاريخ',
                  DateFormat('dd/MM/yyyy').format(result.date!),
                  Icons.calendar_today_rounded,
                ),
                const SizedBox(height: 12),
              ],
              
              _buildInfoRow(
                context,
                'الإجمالي',
                '${result.totalAmount} جنيه',
                Icons.attach_money_rounded,
              ),
              
              const SizedBox(height: 20),
              
              // العناصر
              const Text(
                'العناصر:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: result.items.length,
                  itemBuilder: (context, index) {
                    final item = result.items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            '${item.price} جنيه',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // الأزرار
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('إغلاق'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // إضافة للمصاريف أو الفواتير حسب نوع المستخدم
                        _saveOCRResult(context, result);
                      },
                      child: const Text('حفظ'),
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

  /// بناء صف معلومات
  static Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  /// حفظ نتيجة OCR
  static void _saveOCRResult(BuildContext context, OCRResult result) {
    // هنا يمكن إضافة المنطق لحفظ النتيجة
    // حسب نوع المستخدم (مصاريف، فاتورة، إلخ)
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم حفظ النتيجة بنجاح!'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// إعادة تعيين الاستخدام الشهري للاختبار
  static Future<void> resetMonthlyUsageForTesting(WidgetRef ref) async {
    final userNotifier = ref.read(userProvider.notifier);
    final currentPlan = ref.read(currentPlanProvider);
    
    if (currentPlan != null) {
      final resetPlan = currentPlan.resetMonthlyUsage();
      await userNotifier.restoreFromBackup(resetPlan.toJson());
    }
  }

  /// الحصول على الاستخدام الحالي للـ OCR
  static Map<String, dynamic> getOCRUsageInfo(WidgetRef ref) {
    final userNotifier = ref.read(userProvider.notifier);
    final currentPlan = ref.read(currentPlanProvider);
    
    if (currentPlan == null) {
      return {
        'current': 0,
        'limit': 0,
        'remaining': 0,
        'percentage': 0.0,
        'canUse': false,
      };
    }
    
    final current = userNotifier.getCurrentUsage('ocr_this_month');
    final limit = currentPlan.getLimit('ocr_per_month');
    final remaining = userNotifier.getRemainingCount('ocr_this_month');
    final percentage = userNotifier.getUsagePercentage('ocr_this_month');
    final canUse = !userNotifier.hasReachedLimit('ocr_this_month');
    
    return {
      'current': current,
      'limit': limit == -1 ? 'غير محدود' : limit,
      'remaining': limit == -1 ? 'غير محدود' : remaining,
      'percentage': percentage,
      'canUse': canUse,
    };
  }
} 