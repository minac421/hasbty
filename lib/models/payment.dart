import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'user_plan.dart';

/// أنواع طرق الدفع المتاحة
enum PaymentMethod {
  card,           // فيزا/ماستركارد
  vodafoneCash,   // فودافون كاش
  orangeMoney,    // Orange Money
  etisalatCash,   // Etisalat Cash
  aman,           // أمان
  bankTransfer    // تحويل بنكي
}

/// حالات الدفع
enum PaymentStatus {
  pending,        // في الانتظار
  processing,     // قيد المعالجة
  completed,      // مكتمل
  failed,         // فاشل
  cancelled,      // ملغي
  refunded        // مسترد
}

/// نموذج عملية الدفع
class Payment {
  final String id;
  final String userId;
  final UserType planType;
  final bool isAnnual;
  final double amount;
  final double originalPrice;
  final double discountAmount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;
  final String? paymobOrderId;
  final String? bankTransferReceipt;
  final Map<String, dynamic>? paymobResponse;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? expiresAt;
  final String? failureReason;
  final String? notes;
  
  Payment({
    String? id,
    required this.userId,
    required this.planType,
    required this.isAnnual,
    required this.amount,
    required this.originalPrice,
    this.discountAmount = 0.0,
    required this.method,
    this.status = PaymentStatus.pending,
    this.transactionId,
    this.paymobOrderId,
    this.bankTransferReceipt,
    this.paymobResponse,
    DateTime? createdAt,
    this.completedAt,
    this.expiresAt,
    this.failureReason,
    this.notes,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();
  
  /// إنشاء دفعة جديدة من باقة
  factory Payment.fromPlan({
    required String userId,
    required UserType planType,
    required bool isAnnual,
    required PaymentMethod method,
    String? notes,
  }) {
    final prices = _getPlanPrices(planType);
    final monthlyPrice = prices['monthly']!;
    final annualPrice = prices['annual']!;
    
    final originalPrice = isAnnual ? annualPrice : monthlyPrice;
    final discountAmount = isAnnual ? (monthlyPrice * 12) - annualPrice : 0.0;
    
    return Payment(
      userId: userId,
      planType: planType,
      isAnnual: isAnnual,
      amount: originalPrice,
      originalPrice: originalPrice,
      discountAmount: discountAmount,
      method: method,
      expiresAt: DateTime.now().add(const Duration(minutes: 30)), // تنتهي خلال 30 دقيقة
      notes: notes,
    );
  }
  
  /// الحصول على أسعار الباقات
  static Map<String, double> _getPlanPrices(UserType planType) {
    switch (planType) {
      case UserType.individual:
        return {'monthly': 25.0, 'annual': 249.0}; // خصم 17%
      case UserType.smallBusiness:
        return {'monthly': 50.0, 'annual': 498.0}; // خصم 17%
      case UserType.enterprise:
        return {'monthly': 150.0, 'annual': 1494.0}; // خصم 17%
    }
  }
  
  /// الحصول على نص طريقة الدفع بالعربي
  String get methodName {
    switch (method) {
      case PaymentMethod.card:
        return 'بطاقة ائتمان';
      case PaymentMethod.vodafoneCash:
        return 'فودافون كاش';
      case PaymentMethod.orangeMoney:
        return 'Orange Money';
      case PaymentMethod.etisalatCash:
        return 'Etisalat Cash';
      case PaymentMethod.aman:
        return 'أمان';
      case PaymentMethod.bankTransfer:
        return 'تحويل بنكي';
    }
  }
  
  /// الحصول على نص حالة الدفع بالعربي
  String get statusName {
    switch (status) {
      case PaymentStatus.pending:
        return 'في الانتظار';
      case PaymentStatus.processing:
        return 'قيد المعالجة';
      case PaymentStatus.completed:
        return 'مكتمل';
      case PaymentStatus.failed:
        return 'فاشل';
      case PaymentStatus.cancelled:
        return 'ملغي';
      case PaymentStatus.refunded:
        return 'مسترد';
    }
  }
  
  /// الحصول على لون حالة الدفع
  String get statusColor {
    switch (status) {
      case PaymentStatus.pending:
        return 'orange';
      case PaymentStatus.processing:
        return 'blue';
      case PaymentStatus.completed:
        return 'green';
      case PaymentStatus.failed:
        return 'red';
      case PaymentStatus.cancelled:
        return 'grey';
      case PaymentStatus.refunded:
        return 'purple';
    }
  }
  
  /// الحصول على اسم الباقة
  String get planName {
    switch (planType) {
      case UserType.individual:
        return 'الفردي';
      case UserType.smallBusiness:
        return 'الشركة الصغيرة';
      case UserType.enterprise:
        return 'الشركة الكبيرة';
    }
  }
  
  /// هل انتهت صلاحية عملية الدفع؟
  bool get isExpired {
    return expiresAt != null && DateTime.now().isAfter(expiresAt!);
  }
  
  /// هل يمكن إلغاء عملية الدفع؟
  bool get canCancel {
    return status == PaymentStatus.pending && !isExpired;
  }
  
  /// هل يمكن إعادة المحاولة؟
  bool get canRetry {
    return status == PaymentStatus.failed || status == PaymentStatus.cancelled || isExpired;
  }
  
  /// الحصول على الوقت المتبقي لانتهاء صلاحية الدفعة
  Duration? get timeRemaining {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }
  
  /// تحديث حالة الدفع
  Payment copyWith({
    PaymentStatus? status,
    String? transactionId,
    String? paymobOrderId,
    String? bankTransferReceipt,
    Map<String, dynamic>? paymobResponse,
    DateTime? completedAt,
    String? failureReason,
    String? notes,
  }) {
    return Payment(
      id: id,
      userId: userId,
      planType: planType,
      isAnnual: isAnnual,
      amount: amount,
      originalPrice: originalPrice,
      discountAmount: discountAmount,
      method: method,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      paymobOrderId: paymobOrderId ?? this.paymobOrderId,
      bankTransferReceipt: bankTransferReceipt ?? this.bankTransferReceipt,
      paymobResponse: paymobResponse ?? this.paymobResponse,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt,
      failureReason: failureReason ?? this.failureReason,
      notes: notes ?? this.notes,
    );
  }
  
  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'planType': planType.toString().split('.').last,
      'isAnnual': isAnnual,
      'amount': amount,
      'originalPrice': originalPrice,
      'discountAmount': discountAmount,
      'method': method.toString().split('.').last,
      'status': status.toString().split('.').last,
      'transactionId': transactionId,
      'paymobOrderId': paymobOrderId,
      'bankTransferReceipt': bankTransferReceipt,
      'paymobResponse': paymobResponse,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'failureReason': failureReason,
      'notes': notes,
    };
  }
  
  /// تحويل من JSON
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['userId'],
      planType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == json['planType']
      ),
      isAnnual: json['isAnnual'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0.0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0.0).toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['method']
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status']
      ),
      transactionId: json['transactionId'],
      paymobOrderId: json['paymobOrderId'],
      bankTransferReceipt: json['bankTransferReceipt'],
      paymobResponse: json['paymobResponse'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      failureReason: json['failureReason'],
      notes: json['notes'],
    );
  }
} 