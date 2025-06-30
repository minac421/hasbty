import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import '../models/payment.dart';
import '../models/user_plan.dart';
import '../providers/payment_provider.dart';
import '../providers/user_provider.dart';
import '../services/paymob_service.dart';
import '../theme/app_theme.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final Payment payment;
  
  const PaymentScreen({Key? key, required this.payment}) : super(key: key);

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late WebViewController _webViewController;
  Timer? _expiryTimer;
  Duration _remainingTime = const Duration(minutes: 30);
  bool _isWebViewLoaded = false;
  String? _paymentUrl;
  bool _isTestMode = true;

  @override
  void initState() {
    super.initState();
    _startExpiryTimer();
    _initializePayment();
  }

  void _initializePayment() async {
    try {
      if (widget.payment.method == PaymentMethod.bankTransfer) {
        return;
      }
      
      if (_isTestMode) {
        _paymentUrl = 'https://flutter.dev';
      } else {
        final response = await PayMobService.instance.initiatePayment(widget.payment);
        if (response.success) {
          _paymentUrl = response.paymentUrl;
        } else {
          throw Exception(response.error);
        }
      }
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تهيئة الدفع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startExpiryTimer() {
    final expiry = widget.payment.expiresAt;
    if (expiry != null) {
      _remainingTime = expiry.difference(DateTime.now());
      if (_remainingTime.isNegative) {
        _remainingTime = Duration.zero;
      }
    }
    
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
        _handlePaymentExpiry();
      }
    });
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إتمام الدفع'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isTestMode)
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: _showTestOptions,
            ),
        ],
      ),
      body: Column(
        children: [
          _buildPaymentHeader(),
          Expanded(
            child: widget.payment.method == PaymentMethod.bankTransfer
                ? _buildBankTransferView()
                : _buildWebPaymentView(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPaymentMethodIcon(),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPaymentMethodName(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'المبلغ: ${widget.payment.amount.toStringAsFixed(0)} جنيه',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'وقت انتهاء الصلاحية:',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  _formatDuration(_remainingTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebPaymentView() {
    if (_paymentUrl == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.contains('success') || request.url.contains('callback')) {
            _handlePaymentSuccess();
            return NavigationDecision.prevent;
          }
          if (request.url.contains('failure') || request.url.contains('error')) {
            _handlePaymentFailure();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageFinished: (String url) {
          setState(() {
            _isWebViewLoaded = true;
          });
        },
      ))
      ..loadRequest(Uri.parse(_paymentUrl!));

    _webViewController = controller;
    
    return WebViewWidget(controller: controller);
  }

  Widget _buildBankTransferView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'بيانات التحويل البنكي',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildBankInfoCard(),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'تعليمات هامة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '• احرص على كتابة رقم الفاتورة في بيان التحويل\n'
                  '• احتفظ بإيصال التحويل للمراجعة\n'
                  '• سيتم تفعيل الاشتراك خلال 24 ساعة من التحويل\n'
                  '• يمكنك إرسال صورة الإيصال عبر واتساب: 01234567890',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _confirmBankTransfer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'تأكيد التحويل',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBankInfoRow('البنك:', 'البنك الأهلي المصري'),
          _buildBankInfoRow('اسم الحساب:', 'شركة حاسبتي للبرمجيات'),
          _buildBankInfoRow('رقم الحساب:', '1234567890123456'),
          _buildBankInfoRow('رقم الفاتورة:', widget.payment.id),
          _buildBankInfoRow('المبلغ:', '${widget.payment.amount.toStringAsFixed(0)} جنيه'),
        ],
      ),
    );
  }

  Widget _buildBankInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () => _copyToClipboard(value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showTestOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'خيارات الاختبار',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('محاكاة نجاح الدفع'),
              onTap: () {
                Navigator.pop(context);
                _handlePaymentSuccess();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.error, color: Colors.red),
              title: const Text('محاكاة فشل الدفع'),
              onTap: () {
                Navigator.pop(context);
                _handlePaymentFailure();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.orange),
              title: const Text('محاكاة انتهاء الوقت'),
              onTap: () {
                Navigator.pop(context);
                _handlePaymentExpiry();
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon() {
    switch (widget.payment.method) {
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.vodafoneCash:
      case PaymentMethod.orangeMoney:
      case PaymentMethod.etisalatCash:
        return Icons.phone_android;
      case PaymentMethod.aman:
        return Icons.store;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
    }
  }

  String _getPaymentMethodName() {
    switch (widget.payment.method) {
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _handlePaymentSuccess() {
    _expiryTimer?.cancel();
    
    ref.read(paymentProvider.notifier).updatePaymentStatus(
      widget.payment.id,
      PaymentStatus.completed,
    );
    
    ref.read(userProvider.notifier).upgradePlan(
      userType: widget.payment.planType,
      isAnnual: widget.payment.isAnnual,
      transactionId: widget.payment.transactionId ?? 'test_transaction',
    );
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('تم الدفع بنجاح!'),
          ],
        ),
        content: Text(
          'تم ترقية حسابك إلى ${_getPlanName(widget.payment.planType)} بنجاح.\n'
          'ستتمكن الآن من الاستفادة من جميع المميزات الجديدة.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentFailure() {
    _expiryTimer?.cancel();
    
    ref.read(paymentProvider.notifier).updatePaymentStatus(
      widget.payment.id,
      PaymentStatus.failed,
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('فشل في الدفع'),
          ],
        ),
        content: const Text(
          'لم يتم إتمام عملية الدفع. يرجى المحاولة مرة أخرى أو اختيار طريقة دفع أخرى.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('إعادة المحاولة'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentExpiry() {
    ref.read(paymentProvider.notifier).updatePaymentStatus(
      widget.payment.id,
      PaymentStatus.cancelled,
    );
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.access_time, color: Colors.orange, size: 32),
            SizedBox(width: 12),
            Text('انتهت صلاحية الدفع'),
          ],
        ),
        content: const Text(
          'انتهت مهلة الدفع (30 دقيقة). يرجى البدء من جديد لإتمام عملية الاشتراك.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _confirmBankTransfer() {
    ref.read(paymentProvider.notifier).updatePaymentStatus(
      widget.payment.id,
      PaymentStatus.pending,
    );
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.schedule, color: Colors.blue, size: 32),
            SizedBox(width: 12),
            Text('تم استلام طلب التحويل'),
          ],
        ),
        content: const Text(
          'تم تسجيل طلب التحويل البنكي. سيتم تفعيل اشتراكك خلال 24 ساعة من استلام التحويل.\n\n'
          'يمكنك إرسال صورة إيصال التحويل على واتساب: 01234567890',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  String _getPlanName(UserType planType) {
    switch (planType) {
      case UserType.individual:
        return 'البداية';
      case UserType.smallBusiness:
        return 'النمو';
      case UserType.enterprise:
        return 'الاحتراف';
    }
  }
}