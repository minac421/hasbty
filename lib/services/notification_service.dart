import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_plan.dart';
import '../providers/user_provider.dart';
import '../providers/products_provider.dart';
import '../providers/customers_provider.dart';
import '../providers/sales_provider.dart';
import '../services/feature_manager_service.dart';

/// خدمة الإشعارات لتنبيه المستخدمين
class NotificationService {
  static final instance = NotificationService._();
  NotificationService._();
  
  /// التحقق من جميع حالات التنبيه وإظهارها
  void checkAndShowNotifications(BuildContext context, WidgetRef ref) {
    final userPlan = ref.read(userPlanProvider);
    if (userPlan == null) return;
    
    // التحقق من انتهاء التجربة قريباً
    _checkTrialExpiry(context, userPlan);
    
    // التحقق من انتهاء الاشتراك قريباً
    _checkSubscriptionExpiry(context, userPlan);
    
    // التحقق من الحدود
    _checkLimits(context, ref, userPlan);
  }
  
  /// التحقق من انتهاء التجربة المجانية
  void _checkTrialExpiry(BuildContext context, UserPlan userPlan) {
    if (userPlan.status != SubscriptionStatus.trial) return;
    
    final remainingDays = userPlan.remainingTrialDays;
    
    if (remainingDays <= 1 && remainingDays > 0) {
      // آخر يوم في التجربة
      _showCriticalNotification(
        context,
        title: '⚠️ آخر يوم في تجربتك المجانية!',
        message: 'تنتهي تجربتك المجانية اليوم. اشترك الآن لتستمر في استخدام جميع المميزات.',
        actionText: 'اشترك الآن',
        onAction: () {
          if (context.mounted) {
            Navigator.pushNamed(context, '/subscriptions');
          }
        },
        color: Colors.red,
      );
    } else if (remainingDays <= 3 && remainingDays > 1) {
      // 3 أيام أو أقل
      _showWarningNotification(
        context,
        title: '⏰ تنتهي تجربتك المجانية قريباً',
        message: 'باقي $remainingDays أيام على انتهاء تجربتك. احصل على باقتك الآن!',
        actionText: 'عرض الباقات',
        onAction: () {
          if (context.mounted) {
            Navigator.pushNamed(context, '/subscriptions');
          }
        },
      );
    }
  }
  
  /// التحقق من انتهاء الاشتراك
  void _checkSubscriptionExpiry(BuildContext context, UserPlan userPlan) {
    if (userPlan.status != SubscriptionStatus.active) return;
    
    final remainingDays = userPlan.remainingSubscriptionDays;
    
    if (remainingDays <= 7 && remainingDays > 0) {
      _showWarningNotification(
        context,
        title: '🔔 اشتراكك ينتهي قريباً',
        message: 'باقي $remainingDays أيام على انتهاء اشتراكك. جدد الآن لتجنب انقطاع الخدمة.',
        actionText: 'تجديد الاشتراك',
        onAction: () {
          if (context.mounted) {
            Navigator.pushNamed(context, '/subscriptions');
          }
        },
      );
    }
  }
  
  /// التحقق من حدود الباقة
  void _checkLimits(BuildContext context, WidgetRef ref, UserPlan userPlan) {
    // تم إزالة FeatureManagerService.instance لأنه static الآن
    
    // فحص المنتجات
    final products = ref.read(productsProvider);
    final productsLimit = userPlan.getLimit('products') ?? 0;
    final productsRemaining = productsLimit == -1 ? -1 : (productsLimit - products.length).clamp(0, productsLimit);
    if (productsRemaining <= 5 && productsRemaining > 0) {
      _showInfoNotification(
        context,
        title: '📦 قريب من حد المنتجات',
        message: 'باقي $productsRemaining منتجات فقط في باقتك الحالية.',
        actionText: 'ترقية الباقة',
        onAction: () {
          if (context.mounted) {
            Navigator.pushNamed(context, '/subscriptions');
          }
        },
      );
    }
    
    // فحص العملاء
    final customers = ref.read(customersProvider);
    final customersLimit = userPlan.getLimit('customers') ?? 0;
    final customersRemaining = customersLimit == -1 ? -1 : (customersLimit - customers.length).clamp(0, customersLimit);
    if (customersRemaining <= 3 && customersRemaining > 0) {
      _showInfoNotification(
        context,
        title: '👥 قريب من حد العملاء',
        message: 'باقي $customersRemaining عملاء فقط في باقتك الحالية.',
        actionText: 'ترقية الباقة',
        onAction: () {
          if (context.mounted) {
            Navigator.pushNamed(context, '/subscriptions');
          }
        },
      );
    }
    
    // فحص المبيعات الشهرية
    final sales = ref.read(salesProvider);
    final now = DateTime.now();
    final currentMonthSales = sales.where((sale) {
      return sale.saleDate.year == now.year && sale.saleDate.month == now.month;
    }).length;
    final salesLimit = userPlan.getLimit('sales_per_month') ?? 0;
    final salesRemaining = salesLimit == -1 ? -1 : (salesLimit - currentMonthSales).clamp(0, salesLimit);
    if (salesRemaining <= 10 && salesRemaining > 0) {
      _showInfoNotification(
        context,
        title: '💰 قريب من حد المبيعات الشهرية',
        message: 'باقي $salesRemaining مبيعة فقط هذا الشهر.',
        actionText: 'ترقية الباقة',
        onAction: () {
          if (context.mounted) {
            Navigator.pushNamed(context, '/subscriptions');
          }
        },
      );
    }
  }
  
  /// إشعار حرج (أحمر)
  void _showCriticalNotification(
    BuildContext context, {
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
    Color color = Colors.red,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_rounded, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onAction();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
  
  /// إشعار تحذير (برتقالي)
  void _showWarningNotification(
    BuildContext context, {
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: actionText,
          textColor: Colors.white,
          onPressed: onAction,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  /// إشعار معلوماتي (أزرق)
  void _showInfoNotification(
    BuildContext context, {
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(message, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[600],
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: actionText,
          textColor: Colors.white,
          onPressed: onAction,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  /// عرض نصائح للمستخدم
  void showTips(BuildContext context, UserPlan userPlan) {
    final tips = _getTipsForUserType(userPlan.userType);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'نصائح لتحسين استخدامك',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Tips list
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tips.length,
                  itemBuilder: (context, index) {
                    final tip = tips[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tip['title'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tip['description'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  List<Map<String, String>> _getTipsForUserType(UserType userType) {
    switch (userType) {
      case UserType.individual:
        return [
          {
            'title': 'استفد من النسخة المجانية',
            'description': 'يمكنك إدارة 10 منتجات و50 مبيعة شهرياً مجاناً. ابدأ ببناء قاعدة عملائك.',
          },
          {
            'title': 'جرب التقارير الأساسية',
            'description': 'اطلع على تقاريرك الشهرية لفهم أداء مبيعاتك وتحسين استراتيجيتك.',
          },
          {
            'title': 'فكر في الترقية',
            'description': 'عندما تصل لحدود النسخة المجانية، جرب باقة النمو مع تجربة مجانية 7 أيام.',
          },
        ];
      case UserType.smallBusiness:
        return [
          {
            'title': 'استخدم التقارير المتقدمة',
            'description': 'احصل على رؤى أعمق حول مبيعاتك ومخزونك لاتخاذ قرارات أفضل.',
          },
          {
            'title': 'صدّر تقاريرك بـ PDF',
            'description': 'شارك تقاريرك مع شركائك أو محاسبك بسهولة.',
          },
          {
            'title': 'أضف فروع متعددة',
            'description': 'يمكنك إدارة حتى 2 فرع مختلف من حساب واحد.',
          },
        ];
      case UserType.enterprise:
        return [
          {
            'title': 'استخدم التحليلات المتقدمة',
            'description': 'احصل على تقارير BI متقدمة لفهم أعمق لأداء شركتك.',
          },
          {
            'title': 'صدّر تقاريرك بـ Excel',
            'description': 'تحليل بيانات مفصل مع إمكانيات Excel الكاملة.',
          },
          {
            'title': 'أدر فريقك بكفاءة',
            'description': 'يمكنك إضافة حتى 5 مستخدمين مع صلاحيات مختلفة.',
          },
        ];
      case UserType.enterprise:
        return [
          {
            'title': 'استفد من AI التحليلي',
            'description': 'احصل على توقعات ذكية ونصائح مخصصة لتحسين أداء شركتك.',
          },
          {
            'title': 'استخدم API الكامل',
            'description': 'اربط جردلي مع أنظمتك الأخرى لتكامل كامل.',
          },
          {
            'title': 'استمتع بالدعم الأولوية',
            'description': 'فريقنا متاح 24/7 لمساعدتك في أي استفسار.',
          },
        ];
    }
  }
}

/// Provider للوصول السريع لخدمة الإشعارات
final notificationServiceProvider = Provider((ref) => NotificationService.instance);

/// Helper function لإظهار الإشعارات
void showNotifications(BuildContext context, WidgetRef ref) {
  NotificationService.instance.checkAndShowNotifications(context, ref);
} 