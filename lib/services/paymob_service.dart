import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/payment.dart';

/// خدمة التكامل مع PayMob
class PayMobService {
  static final instance = PayMobService._();
  PayMobService._();
  
  final Dio _dio = Dio();
  
  // PayMob Configuration (يجب استبدالها بالقيم الفعلية)
  static const String _baseUrl = 'https://accept.paymob.com/api';
  static const String _apiKey = 'YOUR_API_KEY'; // سيتم استبدالها
  static const String _integrationIdCard = 'YOUR_CARD_INTEGRATION_ID';
  static const String _integrationIdWallet = 'YOUR_WALLET_INTEGRATION_ID';
  static const String _integrationIdVodafone = 'YOUR_VODAFONE_INTEGRATION_ID';
  
  String? _authToken;
  
  /// الحصول على token المصادقة
  Future<String> _getAuthToken() async {
    if (_authToken != null) return _authToken!;
    
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/tokens',
        data: {'api_key': _apiKey},
      );
      
      _authToken = response.data['token'];
      return _authToken!;
    } catch (e) {
      throw PayMobException('فشل في المصادقة مع PayMob: $e');
    }
  }
  
  /// إنشاء order جديد
  Future<String> _createOrder(Payment payment) async {
    final authToken = await _getAuthToken();
    
    try {
      final response = await _dio.post(
        '$_baseUrl/ecommerce/orders',
        data: {
          'auth_token': authToken,
          'delivery_needed': false,
          'amount_cents': (payment.amount * 100).toInt(), // تحويل لقروش
          'currency': 'EGP',
          'items': [
            {
              'name': 'اشتراك ${payment.planName}',
              'amount_cents': (payment.amount * 100).toInt(),
              'description': payment.isAnnual ? 'اشتراك سنوي' : 'اشتراك شهري',
              'quantity': 1,
            }
          ],
        },
      );
      
      return response.data['id'].toString();
    } catch (e) {
      throw PayMobException('فشل في إنشاء الطلب: $e');
    }
  }
  
  /// الحصول على payment key للدفع
  Future<String> _getPaymentKey(Payment payment, String orderId) async {
    final authToken = await _getAuthToken();
    
    // تحديد integration ID حسب طريقة الدفع
    String integrationId;
    switch (payment.method) {
      case PaymentMethod.card:
        integrationId = _integrationIdCard;
        break;
      case PaymentMethod.vodafoneCash:
        integrationId = _integrationIdVodafone;
        break;
      default:
        integrationId = _integrationIdWallet;
    }
    
    try {
      final response = await _dio.post(
        '$_baseUrl/acceptance/payment_keys',
        data: {
          'auth_token': authToken,
          'amount_cents': (payment.amount * 100).toInt(),
          'expiration': 3600, // ساعة واحدة
          'order_id': orderId,
          'billing_data': {
            'apartment': 'NA',
            'email': 'customer@jardali.app',
            'floor': 'NA',
            'first_name': 'جردلي',
            'street': 'NA',
            'building': 'NA',
            'phone_number': '+201000000000',
            'shipping_method': 'NA',
            'postal_code': 'NA',
            'city': 'Cairo',
            'country': 'EG',
            'last_name': 'كاستومر',
            'state': 'Cairo'
          },
          'currency': 'EGP',
          'integration_id': integrationId,
        },
      );
      
      return response.data['token'];
    } catch (e) {
      throw PayMobException('فشل في الحصول على مفتاح الدفع: $e');
    }
  }
  
  /// بدء عملية الدفع والحصول على رابط الدفع
  Future<PayMobPaymentResponse> initiatePayment(Payment payment) async {
    try {
      // إنشاء order
      final orderId = await _createOrder(payment);
      
      // الحصول على payment key
      final paymentKey = await _getPaymentKey(payment, orderId);
      
      // إنشاء رابط الدفع
      String paymentUrl;
      if (payment.method == PaymentMethod.card) {
        paymentUrl = 'https://accept.paymob.com/api/acceptance/iframes/YOUR_IFRAME_ID?payment_token=$paymentKey';
      } else {
        paymentUrl = 'https://accept.paymob.com/api/acceptance/payments/pay';
      }
      
      return PayMobPaymentResponse(
        success: true,
        orderId: orderId,
        paymentKey: paymentKey,
        paymentUrl: paymentUrl,
      );
    } catch (e) {
      return PayMobPaymentResponse(
        success: false,
        error: e.toString(),
      );
    }
  }
  
  /// للاختبار: محاكاة دفعة ناجحة
  Future<PayMobPaymentResponse> simulateSuccessfulPayment(Payment payment) async {
    // محاكاة للاختبار
    await Future.delayed(const Duration(seconds: 2));
    
    return PayMobPaymentResponse(
      success: true,
      orderId: 'test_order_${DateTime.now().millisecondsSinceEpoch}',
      paymentKey: 'test_payment_key',
      paymentUrl: 'https://example.com/success',
    );
  }
}

/// استجابة PayMob لبدء الدفع
class PayMobPaymentResponse {
  final bool success;
  final String? orderId;
  final String? paymentKey;
  final String? paymentUrl;
  final String? error;
  
  PayMobPaymentResponse({
    required this.success,
    this.orderId,
    this.paymentKey,
    this.paymentUrl,
    this.error,
  });
}

/// استثناء PayMob
class PayMobException implements Exception {
  final String message;
  PayMobException(this.message);
  
  @override
  String toString() => 'PayMobException: $message';
} 