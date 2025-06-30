import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment.dart';
import '../models/user_plan.dart';
import '../providers/payment_provider.dart';
import '../providers/user_provider.dart';
import 'payment_screen.dart';
import '../theme/app_theme.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  final UserType planType;
  final bool isAnnual;
  
  const PaymentMethodScreen({
    Key? key,
    required this.planType,
    required this.isAnnual,
  }) : super(key: key);

  @override
  ConsumerState<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  PaymentMethod? selectedMethod;
  bool isLoading = false;
  
  Map<String, double> get prices {
    switch (widget.planType) {
      case UserType.individual:
        return {'monthly': 25.0, 'annual': 249.0};
      case UserType.smallBusiness:
        return {'monthly': 50.0, 'annual': 498.0};
      case UserType.enterprise:
        return {'monthly': 150.0, 'annual': 1494.0};
    }
  }
  
  double get finalPrice => widget.isAnnual ? prices['annual']! : prices['monthly']!;
  double get originalPrice => widget.isAnnual ? (prices['monthly']! * 12) : prices['monthly']!;
  double get discount => widget.isAnnual ? (originalPrice - finalPrice) : 0.0;
  int get discountPercentage => widget.isAnnual ? 17 : 0;
  
  String get planName {
    switch (widget.planType) {
      case UserType.individual:
        return 'الفردي';
      case UserType.smallBusiness:
        return 'الشركة الصغيرة';
      case UserType.enterprise:
        return 'الشركة الكبيرة';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار طريقة الدفع'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildOrderSummary(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 16),
                const Text(
                  'اختر طريقة الدفع المناسبة لك:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                _buildPaymentMethodCard(
                  method: PaymentMethod.card,
                  title: 'بطاقة ائتمان',
                  subtitle: 'فيزا، ماستركارد',
                  icon: Icons.credit_card,
                  color: Colors.blue,
                  isRecommended: true,
                ),
                
                _buildPaymentMethodCard(
                  method: PaymentMethod.vodafoneCash,
                  title: 'فودافون كاش',
                  subtitle: 'ادفع من محفظة فودافون',
                  icon: Icons.phone_android,
                  color: Colors.red,
                ),
                
                _buildPaymentMethodCard(
                  method: PaymentMethod.orangeMoney,
                  title: 'Orange Money',
                  subtitle: 'ادفع من محفظة أورانج',
                  icon: Icons.phone_android,
                  color: Colors.orange,
                ),
                
                _buildPaymentMethodCard(
                  method: PaymentMethod.etisalatCash,
                  title: 'Etisalat Cash',
                  subtitle: 'ادفع من محفظة اتصالات',
                  icon: Icons.phone_android,
                  color: Colors.green,
                ),
                
                _buildPaymentMethodCard(
                  method: PaymentMethod.aman,
                  title: 'أمان',
                  subtitle: 'من محلات أمان في جميع أنحاء مصر',
                  icon: Icons.store,
                  color: Colors.purple,
                ),
                
                _buildPaymentMethodCard(
                  method: PaymentMethod.bankTransfer,
                  title: 'تحويل بنكي',
                  subtitle: 'تحويل مباشر للحساب البنكي',
                  icon: Icons.account_balance,
                  color: Colors.teal,
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
          _buildContinueButton(),
        ],
      ),
    );
  }
  
  Widget _buildOrderSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'باقة $planName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.isAnnual)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'خصم $discountPercentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Icon(
                widget.isAnnual ? Icons.event : Icons.calendar_today,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isAnnual ? 'اشتراك سنوي' : 'اشتراك شهري',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (widget.isAnnual && discount > 0) ...[
            Row(
              children: [
                Text(
                  '${originalPrice.toStringAsFixed(0)} جنيه',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'وفر ${discount.toStringAsFixed(0)} جنيه',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إجمالي المبلغ:',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                '${finalPrice.toStringAsFixed(0)} جنيه',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentMethodCard({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isRecommended = false,
  }) {
    final isSelected = selectedMethod == method;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => selectedMethod = method),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : Colors.white,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ] : [],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: isSelected ? color : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          
          if (isRecommended)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'مُوصى به',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (selectedMethod != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getPaymentMethodInfo(selectedMethod!),
                      style: TextStyle(color: Colors.blue.shade800, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: isLoading
                ? ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    onPressed: selectedMethod != null ? _proceedToPayment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedMethod != null 
                          ? AppTheme.primaryColor 
                          : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: selectedMethod != null ? 3 : 0,
                    ),
                    child: Text(
                      selectedMethod != null
                          ? 'متابعة إلى الدفع - ${finalPrice.toStringAsFixed(0)} جنيه'
                          : 'اختر طريقة دفع أولاً',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  String _getPaymentMethodInfo(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return 'دفع آمن عبر بوابة PayMob. يتم تشفير جميع البيانات.';
      case PaymentMethod.vodafoneCash:
        return 'سيتم إرسال رسالة نصية لتأكيد الدفع من فودافون كاش.';
      case PaymentMethod.orangeMoney:
        return 'سيتم إرسال رسالة نصية لتأكيد الدفع من Orange Money.';
      case PaymentMethod.etisalatCash:
        return 'سيتم إرسال رسالة نصية لتأكيد الدفع من Etisalat Cash.';
      case PaymentMethod.aman:
        return 'سيتم إنشاء كود دفع يمكن استخدامه في أي محل أمان.';
      case PaymentMethod.bankTransfer:
        return 'سيتم عرض بيانات التحويل البنكي. يرجى إرسال إيصال التحويل.';
    }
  }
  
  Future<void> _proceedToPayment() async {
    if (selectedMethod == null) return;
    
    setState(() => isLoading = true);
    
    try {
      final user = ref.read(userProvider);
      if (user == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }
      
      final payment = await ref.read(paymentProvider.notifier).createPayment(
        'demo-user', // استخدام ID ثابت للتجربة
        planType: widget.planType,
        isAnnual: widget.isAnnual,
        method: selectedMethod!,
        notes: 'دفع اشتراك $planName',
      );
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(payment: payment),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}