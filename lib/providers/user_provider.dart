import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/feature_manager_service.dart';



/// حالة المستخدم
class UserState {
  final UserPlan? currentPlan;
  final bool isLoading;
  final String? error;
  final bool isFirstTime;

  UserState({
    this.currentPlan,
    this.isLoading = false,
    this.error,
    this.isFirstTime = true,
  });

  UserState copyWith({
    UserPlan? currentPlan,
    bool? isLoading,
    String? error,
    bool? isFirstTime,
  }) {
    return UserState(
      currentPlan: currentPlan ?? this.currentPlan,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }
}

/// مزود بيانات المستخدم
class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState()) {
    _loadUserData();
  }

  /// تحميل بيانات المستخدم من التخزين المحلي
  Future<void> _loadUserData() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // التحقق من أول مرة
      final isFirstTime = prefs.getBool('is_first_time') ?? true;
      
      // تحميل بيانات المستخدم
      final userPlanJson = prefs.getString('user_plan');
      UserPlan? userPlan;
      
      if (userPlanJson != null) {
        final planData = jsonDecode(userPlanJson);
        userPlan = UserPlan.fromJson(planData);
        
        // التحقق من انتهاء صلاحية التجربة أو الاشتراك
        if (userPlan.isTrialExpired || userPlan.isSubscriptionExpired) {
          userPlan = _createDefaultPlan(userPlan.userType);
        }
      }
      
      state = state.copyWith(
        currentPlan: userPlan,
        isLoading: false,
        isFirstTime: isFirstTime,
      );
      
      // إعادة تعيين الاستخدام الشهري إذا انتهى الشهر
      if (userPlan != null) {
        await _checkMonthlyReset(userPlan);
      }
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'خطأ في تحميل البيانات: $e',
      );
    }
  }

  /// حفظ بيانات المستخدم
  Future<void> _saveUserData() async {
    if (state.currentPlan == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userPlanJson = jsonEncode(state.currentPlan!.toJson());
      await prefs.setString('user_plan', userPlanJson);
      await prefs.setBool('is_first_time', false);
    } catch (e) {
      state = state.copyWith(error: 'خطأ في حفظ البيانات: $e');
    }
  }

  /// اختيار نوع المستخدم (أول مرة)
  Future<void> selectUserType(UserType userType) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final userPlan = _createDefaultPlan(userType);
      state = state.copyWith(
        currentPlan: userPlan,
        isLoading: false,
        isFirstTime: false,
      );
      
      await _saveUserData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'خطأ في إنشاء الباقة: $e',
      );
    }
  }

  /// إنشاء باقة افتراضية حسب نوع المستخدم
  UserPlan _createDefaultPlan(UserType userType) {
    switch (userType) {
      case UserType.individual:
        return UserPlan.individualFree();
      case UserType.smallBusiness:
        return UserPlan.smallBusinessFree();
      case UserType.enterprise:
        return UserPlan.enterpriseFree();
    }
  }

  /// بدء تجربة مجانية
  Future<void> startFreeTrial(UserType userType) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final trialPlan = UserPlan.startTrial(userType);
      state = state.copyWith(
        currentPlan: trialPlan,
        isLoading: false,
      );
      
      await _saveUserData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'خطأ في بدء التجربة: $e',
      );
    }
  }

  /// الاشتراك المدفوع
  Future<void> subscribeToPremium({
    required UserType userType,
    required bool isAnnual,
    required String transactionId,
  }) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final premiumPlan = UserPlan.createPremium(
        userType: userType,
        isAnnual: isAnnual,
        transactionId: transactionId,
      );
      
      state = state.copyWith(
        currentPlan: premiumPlan,
        isLoading: false,
      );
      
      await _saveUserData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'خطأ في تفعيل الاشتراك: $e',
      );
    }
  }

  /// زيادة استخدام ميزة معينة
  Future<bool> incrementUsage(String usageType, {int increment = 1}) async {
    if (state.currentPlan == null) return false;
    
    final currentUsage = state.currentPlan!.currentUsage[usageType] ?? 0;
    final limit = state.currentPlan!.getLimit(usageType);
    
    // التحقق من الحد الأقصى
    if (limit != null && limit != -1 && currentUsage >= limit) {
      return false; // وصل للحد الأقصى
    }
    
    // زيادة الاستخدام
    final updatedPlan = state.currentPlan!.incrementUsage(usageType, increment: increment);
    state = state.copyWith(currentPlan: updatedPlan);
    
    await _saveUserData();
    return true;
  }

  /// التحقق من إمكانية استخدام ميزة معينة
  bool canUseFeature(String feature) {
    return FeatureManagerService.canAccessFeature(feature, state.currentPlan);
  }

  /// التحقق من الوصول للحد الأقصى
  bool hasReachedLimit(String limitType) {
    if (state.currentPlan == null) return true;
    
    final usage = state.currentPlan!.currentUsage[limitType] ?? 0;
    return FeatureManagerService.hasReachedLimit(limitType, usage, state.currentPlan);
  }

  /// الحصول على الاستخدام الحالي
  int getCurrentUsage(String usageType) {
    return FeatureManagerService.getCurrentUsage(usageType, state.currentPlan);
  }

  /// الحصول على العناصر المتبقية
  int getRemainingCount(String limitType) {
    return FeatureManagerService.getRemainingCount(limitType, state.currentPlan);
  }

  /// الحصول على النسبة المئوية للاستخدام
  double getUsagePercentage(String limitType) {
    return FeatureManagerService.getUsagePercentage(limitType, state.currentPlan);
  }

  /// التحقق من إعادة تعيين الاستخدام الشهري
  Future<void> _checkMonthlyReset(UserPlan userPlan) async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final lastResetString = prefs.getString('last_monthly_reset');
    
    DateTime? lastReset;
    if (lastResetString != null) {
      lastReset = DateTime.parse(lastResetString);
    }
    
    // إذا تغير الشهر، أعد تعيين الاستخدام الشهري
    if (lastReset == null || 
        now.year != lastReset.year || 
        now.month != lastReset.month) {
      
      final resetPlan = userPlan.resetMonthlyUsage();
      state = state.copyWith(currentPlan: resetPlan);
      
      await prefs.setString('last_monthly_reset', now.toIso8601String());
      await _saveUserData();
    }
  }

  /// تجديد التجربة المجانية (مرة واحدة فقط)
  Future<bool> extendFreeTrial() async {
    if (state.currentPlan == null) return false;
    
    final prefs = await SharedPreferences.getInstance();
    final hasExtended = prefs.getBool('trial_extended') ?? false;
    
    if (hasExtended) return false; // لا يمكن التجديد أكثر من مرة
    
    final now = DateTime.now();
    final extendedPlan = state.currentPlan!.copyWith(
      trialEndDate: now.add(const Duration(days: 3)), // 3 أيام إضافية
    );
    
    state = state.copyWith(currentPlan: extendedPlan);
    await prefs.setBool('trial_extended', true);
    await _saveUserData();
    
    return true;
  }

  /// إلغاء الاشتراك
  Future<void> cancelSubscription() async {
    if (state.currentPlan == null) return;
    
    final cancelledPlan = state.currentPlan!.copyWith(
      status: SubscriptionStatus.cancelled,
    );
    
    state = state.copyWith(currentPlan: cancelledPlan);
    await _saveUserData();
  }

  /// استعادة البيانات من النسخة الاحتياطية
  Future<void> restoreFromBackup(Map<String, dynamic> backupData) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final userPlan = UserPlan.fromJson(backupData);
      state = state.copyWith(
        currentPlan: userPlan,
        isLoading: false,
      );
      
      await _saveUserData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'خطأ في استعادة البيانات: $e',
      );
    }
  }

  /// تصدير البيانات للنسخة الاحتياطية
  Map<String, dynamic>? exportForBackup() {
    return state.currentPlan?.toJson();
  }

  /// مسح خطأ
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// إعادة تحميل البيانات
  Future<void> refresh() async {
    await _loadUserData();
  }

  /// تحديث الباقة لنوع مختلف
  Future<void> changeUserType(UserType newUserType) async {
    if (state.currentPlan == null) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final newPlan = _createDefaultPlan(newUserType);
      state = state.copyWith(
        currentPlan: newPlan,
        isLoading: false,
      );
      
      await _saveUserData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'خطأ في تغيير نوع المستخدم: $e',
      );
    }
  }

  /// إحصائيات الاستخدام الشامل
  Map<String, dynamic> getUsageStats() {
    if (state.currentPlan == null) return {};
    
    final plan = state.currentPlan!;
    return {
      'ocr_usage': {
        'current': plan.currentUsage['ocr_this_month'] ?? 0,
        'limit': plan.getLimit('ocr_per_month'),
        'percentage': getUsagePercentage('ocr_this_month'),
        'remaining': getRemainingCount('ocr_this_month'),
      },
      'voice_usage': {
        'current': plan.currentUsage['voice_this_month'] ?? 0,
        'limit': plan.getLimit('voice_per_month'),
        'percentage': getUsagePercentage('voice_this_month'),
        'remaining': getRemainingCount('voice_this_month'),
      },
      'products': {
        'current': plan.currentUsage['products'] ?? 0,
        'limit': plan.getLimit('products'),
        'percentage': getUsagePercentage('products'),
        'remaining': getRemainingCount('products'),
      },
      'customers': {
        'current': plan.currentUsage['customers'] ?? 0,
        'limit': plan.getLimit('customers'),
        'percentage': getUsagePercentage('customers'),
        'remaining': getRemainingCount('customers'),
      },
      'sales': {
        'current': plan.currentUsage['sales_this_month'] ?? 0,
        'limit': plan.getLimit('sales_per_month'),
        'percentage': getUsagePercentage('sales_this_month'),
        'remaining': getRemainingCount('sales_this_month'),
      },
    };
  }

  /// فحص أذونات المستخدم مع UI
  bool checkPermissionWithFeedback({
    required BuildContext context,
    required String feature,
    required String limitType,
    VoidCallback? onSuccess,
    bool showSuccessMessage = false,
  }) {
    return FeatureManagerService.checkPermissionWithFeedback(
      context: context,
      feature: feature,
      limitType: limitType,
      userPlan: state.currentPlan,
      onSuccess: onSuccess,
      showSuccessMessage: showSuccessMessage,
    );
  }

  /// استخدام OCR مع فحص الحدود
  Future<bool> useOCR(BuildContext context) async {
    // التحقق من وجود أي نوع من ميزات OCR
    final hasOCR = canUseFeature('ocr_unlimited') || canUseFeature('ocr_limited');
    
    if (!hasOCR) {
      return checkPermissionWithFeedback(
        context: context,
        feature: 'ocr_unlimited',
        limitType: 'ocr_this_month',
        onSuccess: () async {
          await incrementUsage('ocr_this_month');
        },
        showSuccessMessage: true,
      );
    }
    
    // التحقق من الحدود
    if (hasReachedLimit('ocr_this_month')) {
      return checkPermissionWithFeedback(
        context: context,
        feature: 'ocr_unlimited',
        limitType: 'ocr_this_month',
        onSuccess: () async {
          await incrementUsage('ocr_this_month');
        },
        showSuccessMessage: true,
      );
    }
    
    // السماح بالاستخدام
    await incrementUsage('ocr_this_month');
    return true;
  }

  /// استخدام Voice Assistant مع فحص الحدود
  Future<bool> useVoiceAssistant(BuildContext context) async {
    // التحقق من وجود أي نوع من ميزات Voice
    final hasVoice = canUseFeature('voice_commands_unlimited') || canUseFeature('voice_commands');
    
    if (!hasVoice) {
      return checkPermissionWithFeedback(
        context: context,
        feature: 'voice_commands_unlimited',
        limitType: 'voice_this_month',
        onSuccess: () async {
          await incrementUsage('voice_this_month');
        },
        showSuccessMessage: true,
      );
    }
    
    // التحقق من الحدود
    if (hasReachedLimit('voice_this_month')) {
      return checkPermissionWithFeedback(
        context: context,
        feature: 'voice_commands_unlimited',
        limitType: 'voice_this_month',
        onSuccess: () async {
          await incrementUsage('voice_this_month');
        },
        showSuccessMessage: true,
      );
    }
    
    // السماح بالاستخدام
    await incrementUsage('voice_this_month');
    return true;
  }

  /// إضافة منتج مع فحص الحدود
  Future<bool> addProduct(BuildContext context) async {
    return checkPermissionWithFeedback(
      context: context,
      feature: 'product_management',
      limitType: 'products',
      onSuccess: () async {
        await incrementUsage('products');
      },
      showSuccessMessage: true,
    );
  }

  /// إضافة عميل مع فحص الحدود
  Future<bool> addCustomer(BuildContext context) async {
    return checkPermissionWithFeedback(
      context: context,
      feature: 'customer_management',
      limitType: 'customers',
      onSuccess: () async {
        await incrementUsage('customers');
      },
      showSuccessMessage: true,
    );
  }

  /// إضافة مبيعة مع فحص الحدود
  Future<bool> addSale(BuildContext context) async {
    return checkPermissionWithFeedback(
      context: context,
      feature: 'pos_system',
      limitType: 'sales_this_month',
      onSuccess: () async {
        await incrementUsage('sales_this_month');
      },
      showSuccessMessage: true,
    );
  }

  /// إنشاء مستخدم تجريبي (للتوافق مع الكود القديم)
  Future<void> createDemoUser(UserType userType) async {
    await selectUserType(userType);
  }

  /// ترقية الباقة (للتوافق مع الكود القديم)
  Future<void> upgradePlan({
    required UserType userType,
    required bool isAnnual,
    required String transactionId,
  }) async {
    await subscribeToPremium(
      userType: userType,
      isAnnual: isAnnual,
      transactionId: transactionId,
    );
  }
}

/// مزود بيانات المستخدم
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

/// مزود للحصول على الباقة الحالية
final currentPlanProvider = Provider<UserPlan?>((ref) {
  return ref.watch(userProvider).currentPlan;
});



/// مزود للتحقق من حالة التحميل
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isLoading;
});

/// مزود للتحقق من أول مرة
final isFirstTimeProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isFirstTime;
});

/// مزود لإحصائيات الاستخدام
final usageStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(userProvider.notifier).getUsageStats();
});

/// مزود للتحقق من إمكانية استخدام ميزة معينة
final canUseFeatureProvider = Provider.family<bool, String>((ref, feature) {
  return ref.watch(userProvider.notifier).canUseFeature(feature);
});

/// مزود للتحقق من الوصول للحد الأقصى
final hasReachedLimitProvider = Provider.family<bool, String>((ref, limitType) {
  return ref.watch(userProvider.notifier).hasReachedLimit(limitType);
});

/// مزود للحصول على العناصر المتبقية
final remainingCountProvider = Provider.family<int, String>((ref, limitType) {
  return ref.watch(userProvider.notifier).getRemainingCount(limitType);
});

/// مزود للحصول على النسبة المئوية للاستخدام
final usagePercentageProvider = Provider.family<double, String>((ref, limitType) {
  return ref.watch(userProvider.notifier).getUsagePercentage(limitType);
});

/// مزود للحصول على الاستخدام الحالي
final currentUsageProvider = Provider.family<int, String>((ref, usageType) {
  return ref.watch(userProvider.notifier).getCurrentUsage(usageType);
});

/// مزود للتحقق من انتهاء التجربة
final isTrialExpiredProvider = Provider<bool>((ref) {
  final plan = ref.watch(currentPlanProvider);
  return plan?.isTrialExpired ?? false;
});

/// مزود للحصول على أيام التجربة المتبقية
final remainingTrialDaysProvider = Provider<int>((ref) {
  final plan = ref.watch(currentPlanProvider);
  return plan?.remainingTrialDays ?? 0;
});

/// مزود للتحقق من الاشتراك النشط
final isActiveSubscriberProvider = Provider<bool>((ref) {
  final plan = ref.watch(currentPlanProvider);
  return plan?.status == SubscriptionStatus.active;
});

/// مزود للتحقق من المستخدم المجاني
final isFreeUserProvider = Provider<bool>((ref) {
  final plan = ref.watch(currentPlanProvider);
  return plan?.status == SubscriptionStatus.free;
});

/// مزود لنوع المستخدم الحالي
final currentUserTypeProvider = Provider<UserType?>((ref) {
  final plan = ref.watch(currentPlanProvider);
  return plan?.userType;
});

/// مزود للتوافق مع الكود القديم - لنموذج المستخدم البسيط
final userPlanProvider = Provider<UserPlan?>((ref) {
  return ref.watch(currentPlanProvider);
});

