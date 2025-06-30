import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/payment.dart';
import '../models/user_plan.dart';
import '../services/paymob_service.dart';
import 'user_provider.dart';

/// Notifier لإدارة الدفعات
class PaymentNotifier extends StateNotifier<List<Payment>> {
  PaymentNotifier() : super([]) {
    loadPayments();
  }
  
  Payment? _currentPayment;
  bool _isLoading = false;
  
  // Services
  final PayMobService _payMobService = PayMobService.instance;
  
  // Getters
  Payment? get currentPayment => _currentPayment;
  bool get isLoading => _isLoading;
  List<Payment> get payments => state;
  List<Payment> get completedPayments => state.where((p) => p.status == PaymentStatus.completed).toList();
  List<Payment> get pendingPayments => state.where((p) => p.status == PaymentStatus.pending).toList();
  
  /// تحميل الدفعات المحفوظة
  Future<void> loadPayments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paymentsJson = prefs.getStringList('payments') ?? [];
      
      final payments = paymentsJson
          .map((json) => Payment.fromJson(jsonDecode(json)))
          .toList();
      
      // ترتيب حسب التاريخ (الأحدث أولاً)
      payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      state = payments;
    } catch (e) {
      print('خطأ في تحميل الدفعات: $e');
    }
  }
  
  /// حفظ الدفعات
  Future<void> _savePayments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paymentsJson = state
          .map((payment) => jsonEncode(payment.toJson()))
          .toList();
      
      await prefs.setStringList('payments', paymentsJson);
    } catch (e) {
      print('خطأ في حفظ الدفعات: $e');
    }
  }
  
  /// إنشاء دفعة جديدة
  Future<Payment> createPayment(String userId, {
    required UserType planType,
    required bool isAnnual,
    required PaymentMethod method,
    String? notes,
  }) async {
    final payment = Payment.fromPlan(
      userId: userId,
      planType: planType,
      isAnnual: isAnnual,
      method: method,
      notes: notes,
    );
    
    state = [payment, ...state];
    await _savePayments();
    
    return payment;
  }
  
  /// بدء عملية الدفع
  Future<PayMobPaymentResponse> initiatePayment(Payment payment) async {
    _isLoading = true;
    _currentPayment = payment;
    
    try {
      // تحديث حالة الدفعة لـ processing
      await updatePaymentStatus(payment.id, PaymentStatus.processing);
      
      // بدء الدفع مع PayMob
      final response = await _payMobService.initiatePayment(payment);
      
      if (response.success) {
        // تحديث بيانات الدفعة
        await updatePayment(payment.id, 
          paymobOrderId: response.orderId,
        );
      } else {
        // فشل في بدء الدفع
        await updatePaymentStatus(payment.id, PaymentStatus.failed,
          failureReason: response.error,
        );
      }
      
      return response;
    } catch (e) {
      await updatePaymentStatus(payment.id, PaymentStatus.failed,
        failureReason: e.toString(),
      );
      rethrow;
    } finally {
      _isLoading = false;
    }
  }
  
  /// تأكيد نجاح الدفع
  Future<void> confirmPaymentSuccess(String paymentId, {
    String? transactionId,
    Map<String, dynamic>? paymobResponse,
  }) async {
    // تحديث حالة الدفعة
    await updatePayment(paymentId,
      status: PaymentStatus.completed,
      transactionId: transactionId,
      paymobResponse: paymobResponse,
      completedAt: DateTime.now(),
    );
  }
  
  /// تأكيد فشل الدفع
  Future<void> confirmPaymentFailure(String paymentId, {
    String? failureReason,
    Map<String, dynamic>? paymobResponse,
  }) async {
    await updatePayment(paymentId,
      status: PaymentStatus.failed,
      failureReason: failureReason,
      paymobResponse: paymobResponse,
    );
  }
  
  /// إلغاء دفعة
  Future<void> cancelPayment(String paymentId, {String? reason}) async {
    await updatePaymentStatus(paymentId, PaymentStatus.cancelled,
      failureReason: reason,
    );
  }
  
  /// تحديث حالة الدفعة
  Future<void> updatePaymentStatus(String paymentId, PaymentStatus status, {
    String? failureReason,
  }) async {
    final index = state.indexWhere((p) => p.id == paymentId);
    if (index == -1) return;
    
    state = [
      ...state.sublist(0, index),
      state[index].copyWith(
        status: status,
        failureReason: failureReason,
        completedAt: status == PaymentStatus.completed ? DateTime.now() : null,
      ),
      ...state.sublist(index + 1),
    ];
    
    await _savePayments();
  }
  
  /// تحديث بيانات الدفعة
  Future<void> updatePayment(String paymentId, {
    PaymentStatus? status,
    String? transactionId,
    String? paymobOrderId,
    String? bankTransferReceipt,
    Map<String, dynamic>? paymobResponse,
    DateTime? completedAt,
    String? failureReason,
    String? notes,
  }) async {
    final index = state.indexWhere((p) => p.id == paymentId);
    if (index == -1) return;
    
    state = [
      ...state.sublist(0, index),
      state[index].copyWith(
        status: status,
        transactionId: transactionId,
        paymobOrderId: paymobOrderId,
        bankTransferReceipt: bankTransferReceipt,
        paymobResponse: paymobResponse,
        completedAt: completedAt,
        failureReason: failureReason,
        notes: notes,
      ),
      ...state.sublist(index + 1),
    ];
    
    await _savePayments();
  }
  
  /// إعادة محاولة دفعة فاشلة
  Future<PayMobPaymentResponse> retryPayment(String paymentId, String userId) async {
    final payment = state.firstWhere((p) => p.id == paymentId);
    
    if (!payment.canRetry) {
      throw Exception('لا يمكن إعادة محاولة هذه الدفعة');
    }
    
    // إنشاء دفعة جديدة بنفس البيانات
    final newPayment = Payment.fromPlan(
      userId: userId,
      planType: payment.planType,
      isAnnual: payment.isAnnual,
      method: payment.method,
      notes: 'إعادة محاولة للدفعة ${payment.id}',
    );
    
    state = [newPayment, ...state];
    await _savePayments();
    
    return await initiatePayment(newPayment);
  }
  
  /// حذف دفعة
  Future<void> deletePayment(String paymentId) async {
    state = state.where((p) => p.id != paymentId).toList();
    await _savePayments();
  }
  
  /// الحصول على دفعة بالمعرف
  Payment? getPaymentById(String paymentId) {
    try {
      return state.firstWhere((p) => p.id == paymentId);
    } catch (e) {
      return null;
    }
  }
  
  /// الحصول على آخر دفعة ناجحة
  Payment? get lastSuccessfulPayment {
    try {
      return state.firstWhere((p) => p.status == PaymentStatus.completed);
    } catch (e) {
      return null;
    }
  }
  
  /// الحصول على إجمالي المبلغ المدفوع
  double get totalAmountPaid {
    return state
        .where((p) => p.status == PaymentStatus.completed)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }
  
  /// الحصول على عدد الدفعات الناجحة
  int get successfulPaymentsCount {
    return state.where((p) => p.status == PaymentStatus.completed).length;
  }
  
  /// التحقق من وجود دفعة معلقة
  bool get hasPendingPayment {
    return state.any((p) => p.status == PaymentStatus.pending || p.status == PaymentStatus.processing);
  }
  
  /// الحصول على الدفعة المعلقة
  Payment? get pendingPayment {
    try {
      return state.firstWhere((p) => p.status == PaymentStatus.pending || p.status == PaymentStatus.processing);
    } catch (e) {
      return null;
    }
  }
  
  /// تنظيف الدفعات المنتهية الصلاحية
  Future<void> cleanupExpiredPayments() async {
    final now = DateTime.now();
    final initialCount = state.length;
    
    state = state.where((payment) => 
      !(payment.status == PaymentStatus.pending && 
        payment.expiresAt != null && 
        now.isAfter(payment.expiresAt!))
    ).toList();
    
    if (state.length != initialCount) {
      await _savePayments();
    }
  }
  
  /// للاختبار: إنشاء دفعة اختبارية ناجحة
  Future<void> createTestSuccessfulPayment(String userId) async {
    final payment = Payment.fromPlan(
      userId: userId,
      planType: UserType.smallBusiness,
      isAnnual: false,
      method: PaymentMethod.card,
      notes: 'اختبار - دفعة ناجحة',
    );
    
    final completedPayment = payment.copyWith(
      status: PaymentStatus.completed,
      transactionId: 'test_${DateTime.now().millisecondsSinceEpoch}',
      completedAt: DateTime.now(),
    );
    
    state = [completedPayment, ...state];
    await _savePayments();
  }
}

/// Provider الرئيسي للدفعات
final paymentProvider = StateNotifierProvider<PaymentNotifier, List<Payment>>((ref) {
  return PaymentNotifier();
});

/// Provider للدفعات المكتملة
final completedPaymentsProvider = Provider<List<Payment>>((ref) {
  final payments = ref.watch(paymentProvider);
  return payments.where((p) => p.status == PaymentStatus.completed).toList();
});

/// Provider للدفعات المعلقة
final pendingPaymentsProvider = Provider<List<Payment>>((ref) {
  final payments = ref.watch(paymentProvider);
  return payments.where((p) => p.status == PaymentStatus.pending).toList();
});

/// Provider للتحقق من وجود دفعة معلقة
final hasPendingPaymentProvider = Provider<bool>((ref) {
  final payments = ref.watch(paymentProvider);
  return payments.any((p) => p.status == PaymentStatus.pending || p.status == PaymentStatus.processing);
});

/// Provider لإجمالي المبلغ المدفوع
final totalAmountPaidProvider = Provider<double>((ref) {
  final payments = ref.watch(paymentProvider);
  return payments
      .where((p) => p.status == PaymentStatus.completed)
      .fold(0.0, (sum, payment) => sum + payment.amount);
}); 