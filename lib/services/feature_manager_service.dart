import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_plan.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_widgets.dart';

/// خدمة إدارة المميزات والحدود الذكية
class FeatureManagerService {
  static const Duration _animationDuration = Duration(milliseconds: 300);

  /// التحقق من إمكانية الوصول للميزة
  static bool canAccessFeature(String feature, UserPlan? userPlan) {
    if (userPlan == null) return false;
    return userPlan.hasFeature(feature);
  }

  /// التحقق من توفر الميزة (alias لـ canAccessFeature)
  static bool isFeatureAvailable(UserPlan? userPlan, String feature) {
    return canAccessFeature(feature, userPlan);
  }

  /// التحقق من الوصول لحد معين
  static bool hasReachedLimit(String limitType, int currentUsage, UserPlan? userPlan) {
    if (userPlan == null) return true;
    
    final limit = userPlan.getLimit(limitType);
    if (limit == null || limit == -1) return false; // غير محدود
    
    return currentUsage >= limit;
  }

  /// الحصول على الاستخدام الحالي
  static int getCurrentUsage(String usageType, UserPlan? userPlan) {
    if (userPlan == null) return 0;
    return userPlan.currentUsage[usageType] ?? 0;
  }

  /// الحصول على النسبة المئوية للاستخدام
  static double getUsagePercentage(String limitType, UserPlan? userPlan) {
    if (userPlan == null) return 0.0;
    
    final limit = userPlan.getLimit(limitType);
    final usage = getCurrentUsage(limitType, userPlan);
    
    if (limit == null || limit == -1) return 0.0; // غير محدود
    return (usage / limit).clamp(0.0, 1.0);
  }

  /// الحصول على عدد العناصر المتبقية (نسختان)
  static int getRemainingCount(String limitType, UserPlan? userPlan, [int? currentUsage]) {
    if (userPlan == null) return 0;
    
    final limit = userPlan.getLimit(limitType);
    final usage = currentUsage ?? getCurrentUsage(limitType, userPlan);
    
    if (limit == null || limit == -1) return 9999; // غير محدود
    return (limit - usage).clamp(0, limit);
  }

  /// الحصول على اسم الباقة
  static String getPlanName(UserType userType) {
    switch (userType) {
      case UserType.individual:
        return 'الفردي';
      case UserType.smallBusiness:
        return 'الأعمال الصغيرة';
      case UserType.enterprise:
        return 'الشركات الكبيرة';
    }
  }

  /// الحصول على لون الباقة
  static Color getPlanColor(UserType userType) {
    switch (userType) {
      case UserType.individual:
        return Colors.green;
      case UserType.smallBusiness:
        return Colors.blue;
      case UserType.enterprise:
        return Colors.purple;
    }
  }

  /// بوابة فحص الحدود مع UI تفاعلي
  static bool limitGate(
    BuildContext context,
    UserPlan? userPlan,
    String limitType,
    int currentUsage, {
    VoidCallback? onSuccess,
  }) {
    if (userPlan == null) {
      _showLoginRequiredDialog(context);
      return false;
    }
    
    final limit = userPlan.getLimit(limitType);
    if (limit != null && limit != -1 && currentUsage >= limit) {
      _showLimitReachedDialog(context, limitType, userPlan);
      return false;
    }
    
    // نجح - تنفيذ العملية
    onSuccess?.call();
    return true;
  }

  /// فحص أذونات المستخدم مع رسائل ذكية
  static bool checkPermissionWithFeedback({
    required BuildContext context,
    required String feature,
    required String limitType,
    required UserPlan? userPlan,
    VoidCallback? onSuccess,
    bool showSuccessMessage = false,
  }) {
    if (userPlan == null) {
      _showLoginRequiredDialog(context);
      return false;
    }

    // التحقق من الميزة
    if (!canAccessFeature(feature, userPlan)) {
      _showFeatureLockedDialog(context, feature, userPlan);
      return false;
    }

    // التحقق من الحدود
    final usage = getCurrentUsage(limitType, userPlan);
    if (hasReachedLimit(limitType, usage, userPlan)) {
      _showLimitReachedDialog(context, limitType, userPlan);
      return false;
    }

    // نجح - تنفيذ العملية
    onSuccess?.call();
    
    if (showSuccessMessage) {
      _showSuccessAnimation(context);
    }
    
    return true;
  }

  /// عرض رسالة تحتاج تسجيل دخول
  static void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة مع أنيميشن
              TweenAnimationBuilder(
                duration: _animationDuration,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: Colors.blue[600],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'تسجيل الدخول مطلوب',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'سجل دخولك للاستمتاع بجميع مميزات التطبيق',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              Row(
          children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('لاحقاً'),
                    ),
                  ),
            const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('تسجيل الدخول'),
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

  /// عرض رسالة الميزة مقفلة
  static void _showFeatureLockedDialog(BuildContext context, String feature, UserPlan userPlan) {
    final featureInfo = _getFeatureInfo(feature);
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor.withOpacity(0.1), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة مقفلة مع أنيميشن
              TweenAnimationBuilder(
                duration: _animationDuration,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 48,
                        color: AppTheme.warningColor,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'ميزة ${featureInfo['name']} مقفلة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                featureInfo['description']!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // معلومات الباقة الحالية
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(userPlan.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'باقتك الحالية: ${userPlan.displayName}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            userPlan.description,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
                      child: const Text('لاحقاً'),
          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/subscriptions');
            },
            child: const Text('ترقية الباقة'),
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

  /// عرض رسالة الوصول للحد الأقصى
  static void _showLimitReachedDialog(BuildContext context, String limitType, UserPlan userPlan) {
    final limitInfo = _getLimitInfo(limitType);
    final currentUsage = getCurrentUsage(limitType, userPlan);
    final limit = userPlan.getLimit(limitType);
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [AppTheme.warningColor.withOpacity(0.1), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة تحذير مع أنيميشن
              TweenAnimationBuilder(
                duration: _animationDuration,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        size: 48,
                        color: AppTheme.warningColor,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'وصلت للحد الأقصى!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.warningColor,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'لقد استخدمت $currentUsage من $limit ${limitInfo['unit']}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // شريط التقدم
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${limitInfo['name']}:', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('$currentUsage / $limit', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: AppTheme.borderColor,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.warningColor),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // رسالة تحفيزية مخصصة حسب نوع المستخدم
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getMotivationalMessage(userPlan.userType, limitType),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('لاحقاً'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/subscriptions');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('ترقية الآن'),
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.successColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 48,
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

  /// الحصول على معلومات الميزة
  static Map<String, String> _getFeatureInfo(String feature) {
    final features = {
      'pdf_export': {
        'name': 'تصدير PDF',
        'description': 'يمكنك تصدير التقارير والفواتير كملفات PDF احترافية',
      },
      'excel_export': {
        'name': 'تصدير Excel',
        'description': 'يمكنك تصدير البيانات كملفات Excel للتحليل المتقدم',
      },
      'advanced_reports': {
        'name': 'التقارير المتقدمة',
        'description': 'احصل على تحليلات عميقة ورسوم بيانية تفاعلية',
      },
      'api_access': {
        'name': 'واجهة API',
        'description': 'ربط التطبيق مع الأنظمة الأخرى والتكاملات المخصصة',
      },
      'multi_branch': {
        'name': 'فروع متعددة',
        'description': 'إدارة عدة فروع ومخازن من مكان واحد',
      },
    };
    
    return features[feature] ?? {
      'name': 'الميزة',
      'description': 'هذه الميزة متاحة للمشتركين فقط',
    };
  }

  /// الحصول على معلومات الحد
  static Map<String, String> _getLimitInfo(String limitType) {
    final limits = {
      'ocr_this_month': {'name': 'مسح الفواتير', 'unit': 'فاتورة'},
      'voice_this_month': {'name': 'الأوامر الصوتية', 'unit': 'أمر'},
      'products': {'name': 'المنتجات', 'unit': 'منتج'},
      'customers': {'name': 'العملاء', 'unit': 'عميل'},
      'suppliers': {'name': 'الموردين', 'unit': 'مورد'},
      'sales_this_month': {'name': 'المبيعات الشهرية', 'unit': 'مبيعة'},
      'invoices_this_month': {'name': 'الفواتير الشهرية', 'unit': 'فاتورة'},
    };
    
    return limits[limitType] ?? {'name': 'العنصر', 'unit': 'عنصر'};
  }

  /// الحصول على رسالة تحفيزية حسب نوع المستخدم
  static String _getMotivationalMessage(UserType userType, String limitType) {
    switch (userType) {
      case UserType.individual:
        return 'اشترك بـ25 جنيه/شهر واستمتع باستخدام غير محدود لجميع مميزات التطبيق! 🚀';
        
      case UserType.smallBusiness:
        return 'ارتقِ بعملك! اشترك بـ50 جنيه/شهر واحصل على مميزات لا محدودة + تقارير ذكية 📈';
        
      case UserType.enterprise:
        return 'قُد شركتك للنجاح! اشترك بـ150 جنيه/شهر واحصل على تحليلات AI + API كامل 💼';
    }
  }

  /// Widget لعرض حالة الاستخدام مع أنيميشن
  static Widget buildUsageIndicator({
    required String limitType,
    required UserPlan? userPlan,
    required Color color,
    required IconData icon,
  }) {
    if (userPlan == null) return const SizedBox.shrink();
    
    final usage = getCurrentUsage(limitType, userPlan);
    final limit = userPlan.getLimit(limitType);
    final percentage = getUsagePercentage(limitType, userPlan);
    final isUnlimited = limit == -1;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLimitInfo(limitType)['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      isUnlimited ? 'غير محدود' : '$usage / $limit',
                      style: TextStyle(
                        color: AppTheme.textLightColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isUnlimited)
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          
          if (!isUnlimited) ...[
            const SizedBox(height: 12),
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0, end: percentage),
              builder: (context, double value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  /// Widget لعرض ملخص الباقة مع أنيميشن
  static Widget buildPlanSummaryCard({
    required UserPlan userPlan,
    required VoidCallback onUpgrade,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(userPlan.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userPlan.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userPlan.description,
                      style: TextStyle(
                        color: AppTheme.textLightColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // حالة الاشتراك
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(userPlan.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusText(userPlan.status),
              style: TextStyle(
                color: _getStatusColor(userPlan.status),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          
          if (userPlan.status == SubscriptionStatus.free) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgrade,
                child: const Text('ترقية الباقة'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// الحصول على لون الحالة
  static Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return AppTheme.successColor;
      case SubscriptionStatus.trial:
        return AppTheme.warningColor;
      case SubscriptionStatus.free:
        return AppTheme.textLightColor;
      case SubscriptionStatus.expired:
      case SubscriptionStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  /// الحصول على نص الحالة
  static String _getStatusText(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return 'نشط';
      case SubscriptionStatus.trial:
        return 'تجربة مجانية';
      case SubscriptionStatus.free:
        return 'مجاني';
      case SubscriptionStatus.expired:
        return 'منتهي الصلاحية';
      case SubscriptionStatus.cancelled:
        return 'ملغي';
    }
  }
}

/// Provider للوصول السريع لخدمة إدارة المميزات
final featureManagerProvider = Provider((ref) => FeatureManagerService); 