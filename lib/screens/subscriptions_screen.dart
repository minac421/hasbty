import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_plan.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'payment_method_screen.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  bool _isAnnual = false;
  UserType? _selectedPlan;
  String currentPlan = 'free'; // الباقة الحالية
  
  // بيانات الباقات
  final List<Map<String, dynamic>> plans = [
    {
      'id': 'free',
      'name': 'مجاني',
      'price': '0',
      'period': 'شهرياً',
      'color': Colors.grey,
      'features': [
        '📷 50 مسح ضوئي شهرياً',
        '🎤 50 أمر صوتي شهرياً',
        '📊 تقارير أساسية',
        '⚙️ إعدادات بسيطة',
        '💼 مشروع واحد',
      ],
      'limitations': [
        'إعلانات في التطبيق',
        'دعم فني محدود',
        'لا يوجد نسخ احتياطي تلقائي',
      ],
    },
    {
      'id': 'small_business',
      'name': 'شركة صغيرة/متوسطة',
      'price': '99',
      'period': 'شهرياً',
      'color': Colors.blue,
      'popular': true,
      'features': [
        '📷 مسح ضوئي غير محدود',
        '🎤 أوامر صوتية غير محدودة',
        '📦 إدارة المنتجات والمخزون',
        '👥 إدارة العملاء والموردين',
        '🧾 إنشاء الفواتير',
        '📊 تقارير تفصيلية',
        '🔄 نسخ احتياطي تلقائي',
        '🚫 بدون إعلانات',
        '💬 دعم فني أولوية',
      ],
      'limitations': [],
    },
    {
      'id': 'enterprise',
      'name': 'شركة كبيرة',
      'price': '299',
      'period': 'شهرياً',
      'color': Colors.purple,
      'features': [
        '🌟 جميع مميزات الشركة الصغيرة',
        '🏢 إدارة فروع متعددة',
        '👨‍💼 إدارة المستخدمين والصلاحيات',
        '🤖 تحليلات AI متقدمة',
        '📈 تقارير تنفيذية',
        '🔗 تكامل API',
        '📄 تصدير Excel متقدم',
        '🔒 أمان مُحسّن',
        '⚡ دعم VIP',
        '☁️ تخزين سحابي 10GB',
      ],
      'limitations': [],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final userPlan = ref.watch(userPlanProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر باقتك'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // العنوان الرئيسي
            Text(
              'اختر الباقة المناسبة لعملك',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بتجربة مجانية لمدة 7 أيام',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // مبدل الدفع الشهري/السنوي
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isAnnual = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isAnnual ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: !_isAnnual
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'شهري',
                          style: TextStyle(
                            fontWeight: !_isAnnual ? FontWeight.bold : FontWeight.normal,
                            color: !_isAnnual ? AppTheme.primaryColor : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isAnnual = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isAnnual ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: _isAnnual
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'سنوي',
                              style: TextStyle(
                                fontWeight: _isAnnual ? FontWeight.bold : FontWeight.normal,
                                color: _isAnnual ? AppTheme.primaryColor : Colors.grey[600],
                              ),
                            ),
                            if (_isAnnual) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'وفر 20%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // عرض الباقات
            ...plans.map((plan) => _buildPlanCard(plan)),
            
            const SizedBox(height: 32),
            
            // معلومات إضافية
            _buildAdditionalInfo(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final isCurrentPlan = plan['id'] == currentPlan;
    final isPopular = plan['popular'] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentPlan 
              ? plan['color'].withOpacity(0.5)
              : Colors.grey.withOpacity(0.2),
          width: isCurrentPlan ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentPlan 
                ? plan['color'].withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: isCurrentPlan ? 20 : 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // شارة الأكثر شعبية
          if (isPopular)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'الأكثر شعبية ⭐',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          // شارة الباقة الحالية
          if (isCurrentPlan)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'باقتك الحالية ✓',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: isPopular || isCurrentPlan ? 20 : 0),
                
                // اسم الباقة والسعر
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: plan['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        plan['id'] == 'free' 
                            ? Icons.person
                            : plan['id'] == 'small_business'
                                ? Icons.business
                                : Icons.domain,
                        color: plan['color'],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan['name'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: plan['color'],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                plan['price'],
                                style: TextStyle(
                                  fontSize: 32,
                        fontWeight: FontWeight.bold,
                                  color: plan['color'],
                      ),
                    ),
                              if (plan['price'] != '0') ...[
                    const SizedBox(width: 4),
                                const Text(
                                  'جنيه',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                    Text(
                            plan['period'],
                            style: TextStyle(
                              fontSize: 14,
                        color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // المميزات
                const Text(
                  'المميزات:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ...plan['features'].map<Widget>((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                
                // القيود (إن وجدت)
                if (plan['limitations'].isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'القيود:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...plan['limitations'].map<Widget>((limitation) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            limitation,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                
                const SizedBox(height: 24),
                
                // زر الترقية أو الحالة
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: isCurrentPlan
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                          child: const Center(
                  child: Text(
                              'باقتك الحالية',
                    style: TextStyle(
                      fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () => _upgradePlan(plan),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: plan['color'],
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            plan['id'] == 'free' 
                                ? 'اختيار الباقة المجانية'
                                : 'ترقية لهذه الباقة',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAdditionalInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'معلومات مهمة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildInfoItem('💳', 'طرق الدفع المتاحة', 'فيزا، ماستركارد، فودافون كاش، إنستاباي'),
          _buildInfoItem('🔄', 'إلغاء الاشتراك', 'يمكنك إلغاء الاشتراك في أي وقت'),
          _buildInfoItem('📞', 'دعم العملاء', 'فريق الدعم متاح 24/7 لمساعدتك'),
          _buildInfoItem('🔐', 'الأمان', 'جميع المدفوعات آمنة ومشفرة'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _upgradePlan(Map<String, dynamic> plan) {
    if (plan['id'] == 'free') {
      // التبديل للباقة المجانية
      setState(() {
        currentPlan = 'free';
      });
      _showSuccessMessage('تم التبديل للباقة المجانية بنجاح');
      return;
    }
    
    // عرض صفحة الدفع
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.payment,
              color: plan['color'],
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('تأكيد الترقية'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد الترقية إلى باقة "${plan['name']}"؟'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: plan['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('السعر:'),
                      Text(
                        '${plan['price']} جنيه ${plan['period']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: plan['color'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('مدة التجربة:'),
            Text(
                        '7 أيام مجاناً',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToPayment(plan);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: plan['color'],
            ),
            child: const Text('متابعة الدفع'),
          ),
        ],
      ),
    );
  }

  void _navigateToPayment(Map<String, dynamic> plan) {
    // تحديد نوع المستخدم من الباقة
    UserType planType;
    switch (plan['id']) {
      case 'small_business':
        planType = UserType.smallBusiness;
        break;
      case 'enterprise':
        planType = UserType.enterprise;
        break;
      default:
        planType = UserType.individual;
    }
    
    // الانتقال لصفحة طرق الدفع
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          planType: planType,
          isAnnual: _isAnnual,
        ),
      ),
    );
  }

  void _processPayment(Map<String, dynamic> plan) {
    // محاكاة عملية الدفع
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      
      setState(() {
        currentPlan = plan['id'];
      });
      
      _showSuccessMessage('تم الاشتراك بنجاح! استمتع بالمميزات الجديدة 🎉');
    });
  }

  void _showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
            SizedBox(width: 8),
            Text('تم بنجاح!'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // العودة للشاشة السابقة
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('رائع!'),
          ),
        ],
      ),
    );
  }
} 