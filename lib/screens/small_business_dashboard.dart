import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/animated_widgets.dart';
import '../theme/app_theme.dart';
import '../utils/smart_data_generator.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';

class SmallBusinessDashboard extends ConsumerStatefulWidget {
  const SmallBusinessDashboard({super.key});

  @override
  ConsumerState<SmallBusinessDashboard> createState() => _SmallBusinessDashboardState();
}

class _SmallBusinessDashboardState extends ConsumerState<SmallBusinessDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  int _selectedNavIndex = 0;
  
  // مولد البيانات الذكي
  late SmartDataGenerator _dataGenerator;
  bool _isLoading = false;
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _dataGenerator = SmartDataGenerator();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    // محاكاة تحميل البيانات
    await Future.delayed(const Duration(milliseconds: 1000));
    
    setState(() {
      _isLoading = false;
    });
    
    _fadeController.forward();
    _slideController.forward();
  }

  // البيانات الديناميكية الذكية
  String get businessName => _dataGenerator.getBusinessName();
  double get monthlyRevenue => _dataGenerator.getMonthlyRevenue(selectedMonth);
  double get monthlyExpenses => _dataGenerator.getMonthlyExpenses(selectedMonth);
  int get invoiceCount => _dataGenerator.getMonthlyInvoiceCount(selectedMonth);
  int get productCount => _dataGenerator.getTotalProductCount();
  int get customerCount => _dataGenerator.getTotalCustomerCount();
  int get lowStockCount => _dataGenerator.getLowStockCount();
  int get vipCustomerCount => _dataGenerator.getVIPCustomerCount();

  int get ocrUsed {
    final userState = ref.watch(userProvider);
    return userState.currentPlan?.currentUsage['ocr_this_month'] ?? _dataGenerator.getOcrUsed();
  }

  int get ocrLimit {
    final userState = ref.watch(userProvider);
    final limit = userState.currentPlan?.getLimit('ocr_per_month') ?? 100;
    return limit == -1 ? 999 : limit;
  }

  int get voiceUsed {
    final userState = ref.watch(userProvider);
    return userState.currentPlan?.currentUsage['voice_this_month'] ?? _dataGenerator.getVoiceUsed();
  }

  int get voiceLimit {
    final userState = ref.watch(userProvider);
    final limit = userState.currentPlan?.getLimit('voice_per_month') ?? 100;
    return limit == -1 ? 999 : limit;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Quick Theme Toggle Button
  Widget _buildQuickThemeToggle() {
    final themeInfo = ref.watch(themeInfoProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            themeNotifier.toggleTheme();
            
            // إظهار رسالة تأكيد للأعمال
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      themeInfo['isDark'] ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      themeInfo['isDark'] 
                          ? 'مظهر فاتح لعملك 💼' 
                          : 'مظهر مظلم للعمل ليلاً 🌙',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                backgroundColor: Colors.blue.shade700,
                duration: const Duration(milliseconds: 1500),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                themeInfo['icon'],
                key: ValueKey(themeInfo['icon']),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'جاري تحميل بيانات العمل...',
                      style: TextStyle(
                        color: AppTheme.textLightColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : FadeTransition(
                opacity: _fadeController,
                child: Column(
                  children: [
                    // الشريط العلوي المحسن
                    _buildModernHeader(),
                    
                    // المحتوى الرئيسي
                    Expanded(
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _slideController,
                          curve: Curves.easeOutCubic,
                        )),
                        child: RefreshIndicator(
                          onRefresh: _loadData,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // البطاقات الموجزة المحسنة (2x2)
                                _buildEnhancedStatsGrid(),
                                const SizedBox(height: 24),
                                
                                // إحصائيات ذكية للأعمال
                                _buildBusinessInsights(),
                                const SizedBox(height: 24),
                                
                                // أزرار الميزات الرئيسية
                                _buildMainFeatureButtons(),
                                const SizedBox(height: 24),
                                
                                // المبيعات الحديثة
                                _buildRecentSales(),
                                const SizedBox(height: 24),
                                
                                // روابط سريعة
                                _buildQuickActions(),
                                const SizedBox(height: 100), // مساحة إضافية للأزرار العائمة
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      
      // الأزرار العائمة للـ OCR والـ Voice Assistant
      floatingActionButton: _buildBusinessFloatingButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  // الشريط العلوي المحسن
  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // شعار واسم المشروع
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  businessName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Small Business',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                ),
                const SizedBox(width: 8),
                      const Text(
                      '💼 متجر صغير',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // إعدادات
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Quick Theme Toggle
          _buildQuickThemeToggle(),
        ],
      ),
    );
  }
  
  // البطاقات الموجزة المحسنة
  Widget _buildEnhancedStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
        children: [
        AnimatedWidgets.animatedStatCard(
          title: 'إيرادات الشهر',
          value: monthlyRevenue,
          suffix: ' جنيه',
          icon: Icons.trending_up,
          color: Colors.green,
          animationDelay: 0,
        ),
        AnimatedWidgets.animatedStatCard(
          title: 'مصروفات الشهر',
          value: monthlyExpenses,
          suffix: ' جنيه',
          icon: Icons.trending_down,
          color: Colors.red,
          animationDelay: 200,
        ),
        AnimatedWidgets.animatedStatCard(
          title: 'عدد الفواتير',
          value: invoiceCount.toDouble(),
          suffix: '',
          icon: Icons.receipt_long,
          color: Colors.blue,
          animationDelay: 400,
        ),
        AnimatedWidgets.animatedStatCard(
          title: 'عدد المنتجات',
          value: productCount.toDouble(),
          suffix: '',
          icon: Icons.inventory,
          color: Colors.orange,
          animationDelay: 600,
        ),
      ],
    );
  }

  // إحصائيات ذكية للأعمال
  Widget _buildBusinessInsights() {
    final insights = _dataGenerator.getBusinessInsights(selectedMonth);
    final profit = monthlyRevenue - monthlyExpenses;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade100,
            Colors.blue.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'تحليل الأعمال الذكي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  '💰',
                  'صافي الربح',
                  '${profit.toStringAsFixed(0)} ج.م',
                  profit > 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  '🏆',
                  'أفضل منتج',
                  insights['topProduct'] ?? 'غير محدد',
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  '👥',
                  'عملاء VIP',
                  '$vipCustomerCount من $customerCount',
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  '⚠️',
                  'مخزون منخفض',
                  '$lowStockCount من $productCount',
                  lowStockCount > 5 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String emoji, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // المبيعات الحديثة
  Widget _buildRecentSales() {
    final recentSales = _dataGenerator.getRecentSales(3);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'آخر المبيعات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/reports'),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentSales.isEmpty)
            const Center(
              child: Text(
                'لا توجد مبيعات حديثة',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            )
          else
            ...recentSales.map((sale) => _buildSaleItem(sale)).toList(),
        ],
      ),
    );
  }

  Widget _buildSaleItem(Map<String, dynamic> sale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale['customerName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${sale['productName']} (${sale['quantity']}x)',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${sale['totalAmount'].toStringAsFixed(0)} ج.م',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // أزرار الميزات الرئيسية
  Widget _buildMainFeatureButtons() {
    return Row(
        children: [
        Expanded(
          child: _buildFeatureButton(
            text: 'مساعد صوتي',
            subtitle: '$voiceUsed/$voiceLimit',
            icon: Icons.mic,
            color: const Color(0xFFe63946),
            onPressed: () {
              if (voiceUsed >= voiceLimit) {
                _showLimitReachedDialog('Voice Assistant');
              } else {
                ref.read(userProvider.notifier).incrementUsage('voice_this_month');
                Navigator.pushNamed(context, '/voice_assistant');
              }
            },
          ),
          ),
          const SizedBox(width: 16),
          Expanded(
          child: _buildFeatureButton(
            text: 'مسح ضوئي',
            subtitle: '$ocrUsed/$ocrLimit',
            icon: Icons.camera_alt,
            color: const Color(0xFFf8961e),
            onPressed: () {
              if (ocrUsed >= ocrLimit) {
                _showLimitReachedDialog('OCR Scanner');
              } else {
                ref.read(userProvider.notifier).incrementUsage('ocr_this_month');
                Navigator.pushNamed(context, '/ocr_scanner');
              }
            },
                    ),
                  ),
                ],
    );
  }

  Widget _buildFeatureButton({
    required String text,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLimitReachedDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 24,
            ),
            SizedBox(width: 8),
            Text("وصلت للحد الأقصى"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("لقد وصلت للحد الأقصى لاستخدام $featureName هذا الشهر."),
            const SizedBox(height: 16),
            const Text(
              "يمكنك:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("• ترقية باقتك"),
            const Text("• مشاهدة إعلان للحصول على استخدامات إضافية"),
            const Text("• انتظار الشهر القادم"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscriptions');
            },
            child: const Text("ترقية الباقة"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/rewards');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("مشاهدة إعلان"),
          ),
        ],
      ),
    );
  }

  // روابط سريعة
  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إجراءات سريعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionItem(
                icon: Icons.add_circle,
                label: 'منتج جديد',
                color: Colors.green,
                onTap: () => Navigator.pushNamed(context, '/products'),
              ),
              _buildQuickActionItem(
                icon: Icons.receipt_long,
                label: 'فاتورة جديدة',
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, '/invoices'),
              ),
              _buildQuickActionItem(
                icon: Icons.people_alt,
                label: 'عميل جديد',
                color: Colors.purple,
                onTap: () => Navigator.pushNamed(context, '/customers'),
              ),
              _buildQuickActionItem(
                icon: Icons.analytics,
                label: 'التقارير',
                color: Colors.orange,
                onTap: () => Navigator.pushNamed(context, '/reports'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
              child: Icon(
                icon,
                color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: (index) {
        setState(() {
          _selectedNavIndex = index;
        });
        _navigateToPage(index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 10,
      selectedFontSize: 12,
      unselectedFontSize: 10,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2),
          label: 'المنتجات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.point_of_sale),
          label: 'نقطة البيع',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'العملاء',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'التقارير',
        ),
      ],
    );
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        // Dashboard - current page
        break;
      case 1:
        Navigator.pushNamed(context, '/products');
        break;
      case 2:
        Navigator.pushNamed(context, '/pos');
        break;
      case 3:
        Navigator.pushNamed(context, '/customers');
        break;
      case 4:
        Navigator.pushNamed(context, '/reports');
        break;
    }
  }

  // الأزرار العائمة الدائرية للأعمال
  Widget _buildBusinessFloatingButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // زر OCR دائري للأعمال
        _buildBusinessCircularOcrButton(),
        
        // زر Voice Assistant دائري للأعمال
        _buildBusinessCircularVoiceButton(),
      ],
    );
  }

  // زر OCR دائري مبسط للأعمال
  Widget _buildBusinessCircularOcrButton() {
    final canUseOcr = ocrUsed < ocrLimit;
    
    return FloatingActionButton(
      onPressed: canUseOcr ? () {
        ref.read(userProvider.notifier).incrementUsage('ocr_this_month');
        Navigator.pushNamed(context, '/ocr_scanner');
      } : () {
        _showLimitReachedDialog('OCR Scanner');
      },
      backgroundColor: Colors.transparent,
      elevation: 8,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canUseOcr 
                ? [Colors.blue.shade500, Colors.indigo.shade600]
                : [Colors.grey.shade400, Colors.grey.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (canUseOcr ? Colors.blue.shade500 : Colors.grey.shade400)
                  .withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          canUseOcr ? Icons.receipt_long : Icons.block,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  // زر Voice Assistant دائري مبسط للأعمال
  Widget _buildBusinessCircularVoiceButton() {
    final canUseVoice = voiceUsed < voiceLimit;
    
    return FloatingActionButton(
      onPressed: canUseVoice ? () {
        ref.read(userProvider.notifier).incrementUsage('voice_this_month');
        Navigator.pushNamed(context, '/voice_assistant');
      } : () {
        _showLimitReachedDialog('Voice Assistant');
      },
      backgroundColor: Colors.transparent,
      elevation: 8,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canUseVoice 
                ? [Colors.green.shade500, Colors.teal.shade600]
                : [Colors.grey.shade400, Colors.grey.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (canUseVoice ? Colors.green.shade500 : Colors.grey.shade400)
                  .withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          canUseVoice ? Icons.business : Icons.mic_off,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
} 