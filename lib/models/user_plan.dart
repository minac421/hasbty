import 'dart:convert';
import 'package:flutter/foundation.dart';

/// أنواع المستخدمين الثلاثة
enum UserType {
  individual,    // فرد عادي - مصاريف شخصية
  smallBusiness, // شركة صغيرة - محل أو مشروع صغير
  enterprise     // شركة كبيرة - مؤسسة أو سلسلة محلات
}

/// حالات الاشتراك
enum SubscriptionStatus {
  free,      // مجاني
  trial,     // تجربة مجانية 7 أيام
  active,    // مشترك ونشط
  expired,   // منتهي الصلاحية
  cancelled  // ملغي
}

/// نموذج باقة المستخدم
class UserPlan {
  final String id;
  final UserType userType;
  final SubscriptionStatus status;
  final DateTime createdAt;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool isAnnual;
  final double monthlyPrice;
  final double annualPrice;
  final String? transactionId;
  final Map<String, dynamic> limits;
  final List<String> features;
  final Map<String, int> currentUsage;
  
  UserPlan({
    required this.id,
    required this.userType,
    required this.status,
    required this.createdAt,
    this.trialStartDate,
    this.trialEndDate,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.isAnnual = false,
    required this.monthlyPrice,
    required this.annualPrice,
    this.transactionId,
    required this.limits,
    required this.features,
    Map<String, int>? currentUsage,
  }) : currentUsage = currentUsage ?? {};

  /// إنشاء باقة Individual مجانية
  factory UserPlan.individualFree() {
    return UserPlan(
      id: 'individual_free_${DateTime.now().millisecondsSinceEpoch}',
      userType: UserType.individual,
      status: SubscriptionStatus.free,
      createdAt: DateTime.now(),
      monthlyPrice: 25.0,
      annualPrice: 250.0, // خصم 17%
      limits: {
        'ocr_per_month': 50,
        'voice_per_month': 50,
        'reports': 'basic',
        'pdf_export': false,
        'backup': false,
        'ads': true,
      },
      features: [
        'expense_tracking',
        'basic_reports',
        'voice_commands',
        'ocr_limited',
      ],
      currentUsage: {
        'ocr_this_month': 0,
        'voice_this_month': 0,
      },
    );
  }

  /// إنشاء باقة Small Business مجانية
  factory UserPlan.smallBusinessFree() {
    return UserPlan(
      id: 'small_business_free_${DateTime.now().millisecondsSinceEpoch}',
      userType: UserType.smallBusiness,
      status: SubscriptionStatus.free,
      createdAt: DateTime.now(),
      monthlyPrice: 50.0,
      annualPrice: 500.0, // خصم 17%
      limits: {
        'products': 50,
        'customers': 25,
        'suppliers': 10,
        'sales_per_month': 100,
        'invoices_per_month': 25,
        'ocr_per_month': 100,
        'voice_per_month': 100,
        'reports': 'medium',
        'pdf_export': false,
        'users': 1,
        'branches': 1,
        'ads': true,
      },
      features: [
        'expense_tracking',
        'product_management',
        'customer_management',
        'supplier_management',
        'pos_system',
        'invoice_generation',
        'inventory_management',
        'medium_reports',
        'voice_commands',
        'ocr_limited',
      ],
      currentUsage: {
        'products': 0,
        'customers': 0,
        'suppliers': 0,
        'sales_this_month': 0,
        'invoices_this_month': 0,
        'ocr_this_month': 0,
        'voice_this_month': 0,
      },
    );
  }

  /// إنشاء باقة Enterprise مجانية
  factory UserPlan.enterpriseFree() {
    return UserPlan(
      id: 'enterprise_free_${DateTime.now().millisecondsSinceEpoch}',
      userType: UserType.enterprise,
      status: SubscriptionStatus.free,
      createdAt: DateTime.now(),
      monthlyPrice: 150.0,
      annualPrice: 1500.0, // خصم 17%
      limits: {
        'products': 100,
        'customers': 50,
        'suppliers': 25,
        'sales_per_month': 500,
        'invoices_per_month': 100,
        'ocr_per_month': 500,
        'voice_per_month': 500,
        'reports': 'advanced',
        'pdf_export': false,
        'users': 3,
        'branches': 2,
        'ads': true,
      },
      features: [
        'expense_tracking',
        'product_management',
        'customer_management',
        'supplier_management',
        'pos_system',
        'invoice_generation',
        'inventory_management',
        'advanced_reports',
        'multi_branch',
        'user_management',
        'voice_commands',
        'ocr_limited',
      ],
      currentUsage: {
        'products': 0,
        'customers': 0,
        'suppliers': 0,
        'sales_this_month': 0,
        'invoices_this_month': 0,
        'ocr_this_month': 0,
        'voice_this_month': 0,
        'users': 1,
        'branches': 1,
      },
    );
  }

  /// إنشاء باقة مدفوعة (أي نوع)
  factory UserPlan.createPremium({
    required UserType userType,
    required bool isAnnual,
    required String transactionId,
  }) {
    final now = DateTime.now();
    final endDate = isAnnual 
        ? now.add(const Duration(days: 365))
        : now.add(const Duration(days: 30));
    
    late Map<String, dynamic> limits;
    late List<String> features;
    late double monthlyPrice;
    late double annualPrice;

    switch (userType) {
      case UserType.individual:
        monthlyPrice = 25.0;
        annualPrice = 250.0;
        limits = {
        'ocr_per_month': -1, // غير محدود
          'voice_per_month': -1,
        'reports': 'detailed',
          'pdf_export': true,
          'backup': true,
          'ads': false,
        };
        features = [
        'expense_tracking',
        'detailed_reports',
          'voice_commands_unlimited',
          'ocr_unlimited',
          'pdf_export',
          'cloud_backup',
          'no_ads',
        ];
        break;

      case UserType.smallBusiness:
        monthlyPrice = 50.0;
        annualPrice = 500.0;
        limits = {
          'products': -1,
          'customers': -1,
          'suppliers': -1,
          'sales_per_month': -1,
          'invoices_per_month': -1,
          'ocr_per_month': -1,
          'voice_per_month': -1,
          'reports': 'detailed_ai',
          'pdf_export': true,
          'users': 3,
          'branches': 3,
          'ads': false,
        };
        features = [
          'expense_tracking',
          'product_management_unlimited',
          'customer_management_unlimited',
          'supplier_management_unlimited',
          'pos_system_advanced',
          'invoice_generation_unlimited',
          'inventory_management_advanced',
          'detailed_ai_reports',
          'multi_user',
          'multi_branch',
          'voice_commands_unlimited',
          'ocr_unlimited',
        'pdf_export',
          'excel_export',
          'cloud_backup',
        'no_ads',
        ];
        break;

      case UserType.enterprise:
        monthlyPrice = 150.0;
        annualPrice = 1500.0;
        limits = {
          'products': -1,
          'customers': -1,
          'suppliers': -1,
          'sales_per_month': -1,
          'invoices_per_month': -1,
          'ocr_per_month': -1,
          'voice_per_month': -1,
          'reports': 'ai_analytics',
          'pdf_export': true,
          'users': 15,
          'branches': -1,
          'api_access': true,
          'ads': false,
        };
        features = [
          'expense_tracking',
          'product_management_unlimited',
          'customer_management_unlimited',
          'supplier_management_unlimited',
          'pos_system_enterprise',
          'invoice_generation_unlimited',
          'inventory_management_enterprise',
          'ai_analytics',
          'multi_user_advanced',
          'multi_branch_unlimited',
          'voice_commands_unlimited',
          'ocr_unlimited',
          'pdf_export',
          'excel_export',
          'api_access',
          'custom_integrations',
        'priority_support',
          'cloud_backup_daily',
          'no_ads',
        ];
        break;
    }
    
    return UserPlan(
      id: '${userType.name}_premium_${DateTime.now().millisecondsSinceEpoch}',
      userType: userType,
      status: SubscriptionStatus.active,
      createdAt: now,
      subscriptionStartDate: now,
      subscriptionEndDate: endDate,
      isAnnual: isAnnual,
      monthlyPrice: monthlyPrice,
      annualPrice: annualPrice,
      transactionId: transactionId,
      limits: limits,
      features: features,
      currentUsage: {},
    );
  }

  /// بدء تجربة مجانية
  factory UserPlan.startTrial(UserType userType) {
    final now = DateTime.now();
    final trialEnd = now.add(const Duration(days: 7));

    return UserPlan.createPremium(
      userType: userType,
      isAnnual: false,
      transactionId: 'trial_${DateTime.now().millisecondsSinceEpoch}',
    ).copyWith(
      status: SubscriptionStatus.trial,
      trialStartDate: now,
      trialEndDate: trialEnd,
      subscriptionStartDate: null,
      subscriptionEndDate: null,
    );
  }

  /// الحصول على اسم الباقة للعرض
  String get displayName {
    switch (userType) {
      case UserType.individual:
        return 'فردي';
      case UserType.smallBusiness:
        return 'شركة صغيرة';
      case UserType.enterprise:
        return 'شركة كبيرة';
    }
  }

  /// الحصول على وصف الباقة
  String get description {
    switch (userType) {
      case UserType.individual:
        return 'مثالي للأفراد وتتبع المصاريف الشخصية';
      case UserType.smallBusiness:
        return 'مثالي للمحلات الصغيرة والمشاريع الناشئة';
      case UserType.enterprise:
        return 'مثالي للشركات الكبيرة والمؤسسات';
    }
  }

  /// الحصول على أيقونة الباقة
  String get icon {
    switch (userType) {
      case UserType.individual:
        return '🧍';
      case UserType.smallBusiness:
        return '💼';
      case UserType.enterprise:
        return '🏢';
    }
  }

  /// التحقق من انتهاء التجربة
  bool get isTrialExpired {
    if (status != SubscriptionStatus.trial || trialEndDate == null) return false;
    return DateTime.now().isAfter(trialEndDate!);
  }

  /// التحقق من انتهاء الاشتراك
  bool get isSubscriptionExpired {
    if (status != SubscriptionStatus.active || subscriptionEndDate == null) return false;
    return DateTime.now().isAfter(subscriptionEndDate!);
  }

  /// الأيام المتبقية في التجربة
  int get remainingTrialDays {
    if (status != SubscriptionStatus.trial || trialEndDate == null) return 0;
    final remaining = trialEndDate!.difference(DateTime.now()).inDays;
    return remaining.clamp(0, 7);
  }

  /// الأيام المتبقية في الاشتراك
  int get remainingSubscriptionDays {
    if (status != SubscriptionStatus.active || subscriptionEndDate == null) return 0;
    final remaining = subscriptionEndDate!.difference(DateTime.now()).inDays;
    return remaining.clamp(0, 9999);
  }

  /// التحقق من وجود ميزة معينة
  bool hasFeature(String feature) {
    return features.contains(feature);
  }

  /// الحصول على حد معين
  dynamic getLimit(String limitType) {
    return limits[limitType];
  }

  /// التحقق من الوصول لحد معين
  bool hasReachedLimit(String limitType) {
    final limit = getLimit(limitType);
    final usage = currentUsage[limitType] ?? 0;
    
    if (limit == null || limit == -1) return false; // غير محدود
    return usage >= limit;
  }

  /// تحديث الاستخدام
  UserPlan updateUsage(String usageType, int newValue) {
    final updatedUsage = Map<String, int>.from(currentUsage);
    updatedUsage[usageType] = newValue;
    return copyWith(currentUsage: updatedUsage);
  }

  /// زيادة الاستخدام
  UserPlan incrementUsage(String usageType, {int increment = 1}) {
    final currentValue = currentUsage[usageType] ?? 0;
    return updateUsage(usageType, currentValue + increment);
  }

  /// إعادة تعيين الاستخدام الشهري
  UserPlan resetMonthlyUsage() {
    final updatedUsage = Map<String, int>.from(currentUsage);
    updatedUsage.removeWhere((key, value) => key.endsWith('_this_month'));
    return copyWith(currentUsage: updatedUsage);
  }
  
  /// نسخ مع تعديلات
  UserPlan copyWith({
    String? id,
    UserType? userType,
    SubscriptionStatus? status,
    DateTime? createdAt,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    bool? isAnnual,
    double? monthlyPrice,
    double? annualPrice,
    String? transactionId,
    Map<String, dynamic>? limits,
    List<String>? features,
    Map<String, int>? currentUsage,
  }) {
    return UserPlan(
      id: id ?? this.id,
      userType: userType ?? this.userType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      isAnnual: isAnnual ?? this.isAnnual,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      annualPrice: annualPrice ?? this.annualPrice,
      transactionId: transactionId ?? this.transactionId,
      limits: limits ?? this.limits,
      features: features ?? this.features,
      currentUsage: currentUsage ?? this.currentUsage,
    );
  }

  /// تحويل لـ JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userType': userType.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'trialStartDate': trialStartDate?.toIso8601String(),
      'trialEndDate': trialEndDate?.toIso8601String(),
      'subscriptionStartDate': subscriptionStartDate?.toIso8601String(),
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
      'isAnnual': isAnnual,
      'monthlyPrice': monthlyPrice,
      'annualPrice': annualPrice,
      'transactionId': transactionId,
      'limits': limits,
      'features': features,
      'currentUsage': currentUsage,
    };
  }

  /// تحويل من JSON
  factory UserPlan.fromJson(Map<String, dynamic> json) {
    return UserPlan(
      id: json['id'],
      userType: UserType.values.firstWhere((e) => e.name == json['userType']),
      status: SubscriptionStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      trialStartDate: json['trialStartDate'] != null 
          ? DateTime.parse(json['trialStartDate']) 
          : null,
      trialEndDate: json['trialEndDate'] != null 
          ? DateTime.parse(json['trialEndDate']) 
          : null,
      subscriptionStartDate: json['subscriptionStartDate'] != null 
          ? DateTime.parse(json['subscriptionStartDate']) 
          : null,
      subscriptionEndDate: json['subscriptionEndDate'] != null 
          ? DateTime.parse(json['subscriptionEndDate']) 
          : null,
      isAnnual: json['isAnnual'] ?? false,
      monthlyPrice: (json['monthlyPrice'] ?? 0.0).toDouble(),
      annualPrice: (json['annualPrice'] ?? 0.0).toDouble(),
      transactionId: json['transactionId'],
      limits: Map<String, dynamic>.from(json['limits'] ?? {}),
      features: List<String>.from(json['features'] ?? []),
      currentUsage: Map<String, int>.from(json['currentUsage'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'UserPlan(${userType.name}, ${status.name}, ${limits.toString()})';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UserPlan &&
            runtimeType == other.runtimeType &&
            id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}