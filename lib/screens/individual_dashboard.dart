import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_plan.dart';
import '../providers/user_provider.dart';
import '../providers/sales_provider.dart';
import '../providers/theme_provider.dart';
import '../services/ocr_service.dart';
import '../services/feature_manager_service.dart';
import '../services/smart_notifications_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/common_widgets.dart';
import '../utils/constants.dart';
import '../utils/smart_data_generator.dart';

class IndividualDashboard extends ConsumerStatefulWidget {
  const IndividualDashboard({super.key});

  @override
  ConsumerState<IndividualDashboard> createState() => _IndividualDashboardState();
}

class _IndividualDashboardState extends ConsumerState<IndividualDashboard> {
  // بيانات المصروفات الشهرية - ديناميكية
  double budgetAmount = 3000;
  bool _isLoading = false;
  
  // الشهر الحالي
  DateTime selectedMonth = DateTime.now();
  
  // متتبع إشعارات الميزانية لتجنب التكرار
  Set<int> _budgetNotificationsSent = <int>{};

  // مولد البيانات الذكي
  late SmartDataGenerator _dataGenerator;

  @override
  void initState() {
    super.initState();
    _dataGenerator = SmartDataGenerator();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    // محاكاة تحميل البيانات
    await Future.delayed(Duration(milliseconds: 800));
    
    setState(() {
      _isLoading = false;
    });
    
    // تشغيل التحليل الذكي بعد التحميل
    _runSmartAnalysis();
  }

  // البيانات الديناميكية الذكية
  String get userName => _dataGenerator.getUserName();
  String get avatarUrl => _dataGenerator.getAvatarUrl(userName);
  double get totalExpenses => _dataGenerator.getTotalExpenses(selectedMonth);
  
  int get ocrUsed {
    final userState = ref.watch(userProvider);
    return userState.currentPlan?.currentUsage['ocr_this_month'] ?? _dataGenerator.getOcrUsed();
  }

  int get ocrLimit {
    final userState = ref.watch(userProvider);
    final limit = userState.currentPlan?.getLimit('ocr_per_month') ?? 50;
    return limit == -1 ? 999 : limit;
  }

  int get voiceUsed {
    final userState = ref.watch(userProvider);
    return userState.currentPlan?.currentUsage['voice_this_month'] ?? _dataGenerator.getVoiceUsed();
  }

  int get voiceLimit {
    final userState = ref.watch(userProvider);
    final limit = userState.currentPlan?.getLimit('voice_per_month') ?? 50;
    return limit == -1 ? 999 : limit;
  }

  List<Map<String, dynamic>> get recentTransactions {
    return _dataGenerator.getRecentTransactions(selectedMonth);
  }
  
  // قائمة أشهر للعرض
  List<DateTime> months = [
    DateTime(2025, 6), // يونيو
    DateTime(2025, 5), // مايو
    DateTime(2025, 4), // أبريل
    DateTime(2025, 3), // مارس
    DateTime(2025, 2), // فبراير
  ];
  
  // بيانات المصروفات الحديثة (نموذجية)
  final List<Map<String, dynamic>> recentExpenses = [
    {
      'id': '1',
      'title': 'Purchase details',
      'details': 'Kentaqi (500), Malabis (1000), Taxi (20)',
      'category': 'Shopping',
      'amount': 1520,
      'date': '2025-06-17',
      'icon': Icons.shopping_cart,
      'color': Color(0xFF0087B8),
    },
    {
      'id': '2',
      'title': 'Payment',
      'details': 'محمد (500)',
      'category': 'Other',
      'amount': 500,
      'date': '2025-06-17',
      'icon': Icons.payments_outlined,
      'color': Color(0xFF6c757d),
    },
    {
      'id': '3',
      'title': 'مطعم العائلة',
      'details': 'عشاء',
      'category': 'Dining',
      'amount': 350,
      'date': '2025-06-15',
      'icon': Icons.restaurant,
      'color': Color(0xFFf8961e),
    },
    {
      'id': '4',
      'title': 'محطة وقود',
      'details': 'بنزين 92',
      'category': 'Transport',
      'amount': 280,
      'date': '2025-06-14',
      'icon': Icons.local_gas_station,
      'color': Color(0xFFe63946),
    },
  ];
  
  // تم حذف initState المكررة - تم استبدالها بالإصدار الجديد أعلاه

  // تشغيل التحليل الذكي للبيانات
  Future<void> _runSmartAnalysis() async {
    final salesData = {
      'today': totalExpenses,
      'yesterday': totalExpenses * 0.8, // محاكاة بيانات الأمس
    };
    
    final inventoryData = {
      'lowStockItems': [
        {'name': 'نقود الطوارئ', 'quantity': 2},
      ],
    };
    
    final customersData = {
      'overdueCustomers': [
        {'name': 'صديق مدين', 'daysPast': 10},
      ],
    };

    // تشغيل التحليل الذكي
    await SmartNotificationsService.analyzeAndNotify(
      salesData: salesData,
      inventoryData: inventoryData,
      customersData: customersData,
    );

    // إرسال تحفيز إذا كان الأداء جيد
    if (totalExpenses < budgetAmount * 0.8) {
      await SmartNotificationsService.showAchievementUnlocked(
        'مدير مالي ذكي',
        'أنت تدير أموالك بحكمة! وفرت ${(budgetAmount - totalExpenses).toStringAsFixed(0)} جنيه هذا الشهر'
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressPercentage = (totalExpenses / budgetAmount).clamp(0.0, 1.0);
    final isDark = ref.watch(isDarkModeProvider);
    
    // فحص إشعارات الميزانية البسيط
    _checkBudgetAlerts(progressPercentage);
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
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
                            'جاري تحميل البيانات...',
                            style: TextStyle(
                              color: AppTheme.textLightColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildExpenseSummary(progressPercentage),
                            _buildSmartInsights(),
                            _buildMonthSelector(),
                            _buildRecentExpenses(),
                            // _buildActionButtons(), // تم إزالة الأزرار العادية لأن الأزرار العائمة موجودة
                            const SizedBox(height: 100), // مساحة إضافية للأزرار العائمة
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      
      // الأزرار العائمة للـ OCR والـ Voice Assistant
      floatingActionButton: _buildFloatingActionButtons(isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

    // الأزرار العائمة الدائرية المبسطة
  Widget _buildFloatingActionButtons(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // زر OCR دائري
        _buildCircularOcrButton(isDark),
        
        // زر Voice Assistant دائري
        _buildCircularVoiceButton(isDark),
      ],
    );
  }

  // زر OCR دائري مبسط
  Widget _buildCircularOcrButton(bool isDark) {
    final canUseOcr = ocrUsed < ocrLimit;
    
    return FloatingActionButton(
      onPressed: canUseOcr ? () {
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
                ? [Colors.orange.shade400, Colors.deepOrange.shade500]
                : [Colors.grey.shade400, Colors.grey.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (canUseOcr ? Colors.orange.shade400 : Colors.grey.shade400)
                  .withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          canUseOcr ? Icons.camera_alt : Icons.block,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  // زر Voice Assistant دائري مبسط
  Widget _buildCircularVoiceButton(bool isDark) {
    final canUseVoice = voiceUsed < voiceLimit;
    
    return FloatingActionButton(
      onPressed: canUseVoice ? () {
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
                ? [Colors.purple.shade400, Colors.indigo.shade500]
                : [Colors.grey.shade400, Colors.grey.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (canUseVoice ? Colors.purple.shade400 : Colors.grey.shade400)
                  .withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          canUseVoice ? Icons.mic : Icons.mic_off,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }



  // Quick Theme Toggle Button
  Widget _buildQuickThemeToggle() {
    final themeInfo = ref.watch(themeInfoProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeInfo['isDark']
              ? [const Color(0xFF4FC3F7), const Color(0xFF29B6F6)]
              : [const Color(0xFF0087B8), const Color(0xFF4FB6E3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (themeInfo['isDark'] 
                ? const Color(0xFF4FC3F7) 
                : const Color(0xFF0087B8)).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            themeNotifier.toggleTheme();
            
            // إظهار رسالة تأكيد
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
                          ? 'تم التبديل للوضع الفاتح 🌅' 
                          : 'تم التبديل للوضع المظلم 🌙',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                backgroundColor: themeInfo['isDark'] 
                    ? const Color(0xFF4FC3F7) 
                    : const Color(0xFF0087B8),
                duration: const Duration(milliseconds: 1500),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8),
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
  
  // الشريط العلوي مع معلومات المستخدم
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // معلومات المستخدم
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                const SizedBox(width: 12),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "أهلاً ${userName.split(" ")[0]}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDarkColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "👋",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0087B8).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  "🇪🇬 EGP",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0087B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF28a745).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  "FREE",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF28a745),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFf8961e).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "📷 ",
                                  style: TextStyle(fontSize: 8),
                                ),
                                Text(
                                  "$ocrUsed/$ocrLimit",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFf8961e),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFe63946).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "🎤 ",
                                  style: TextStyle(fontSize: 8),
                                ),
                                Text(
                                  "$voiceUsed/$voiceLimit",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFe63946),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // أيقونة الإعدادات مع أنيميشن
          AnimatedWidgets.pulsingButton(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.settings, color: AppTheme.textLightColor),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ),
          ),
          
          // زر الإشعارات مع مؤشر
          _buildNotificationButton(),
          
          // Quick Theme Toggle
          _buildQuickThemeToggle(),
        ],
      ),
    );
  }

  // بطاقة ملخص المصروفات
  Widget _buildExpenseSummary(double progressPercentage) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان المصروفات
          Text(
            "مصروفاتي في ${_getMonthName(selectedMonth)}",
            style: const TextStyle(
              color: AppTheme.textLightColor,
              fontSize: 15,
            ),
          ),
          
          // المبلغ بشكل كبير مع أنيميشن
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                "EGP ",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDarkColor,
                ),
              ),
              AnimatedWidgets.animatedMoneyCounter(
                amount: totalExpenses,
                currency: '',
                color: AppTheme.textDarkColor,
                fontSize: 34,
              ),
            ],
          ),
          
          // خط فاصل
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 20),
          
          // الميزانية وزر تعيين الميزانية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "الميزانية",
                style: TextStyle(color: AppTheme.textLightColor, fontSize: 15),
              ),
              TextButton.icon(
                onPressed: () {
                  // عرض مربع حوار لتعيين الميزانية
                  _showSetBudgetDialog();
                },
                icon: const Icon(Icons.add, size: 18, color: Color(0xFF0087B8)),
                label: const Text(
                  "تعيين الميزانية",
                  style: TextStyle(
                    color: Color(0xFF0087B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // الإحصائيات الذكية
  Widget _buildSmartInsights() {
    final insights = _dataGenerator.getSmartInsights(selectedMonth);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0087B8).withOpacity(0.1),
            const Color(0xFF0087B8).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0087B8).withOpacity(0.2),
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
                  color: const Color(0xFF0087B8).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Color(0xFF0087B8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'إحصائيات ذكية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDarkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  '📊',
                  'الفئة الأكثر',
                  insights['topCategory'] ?? 'غير محدد',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightItem(
                  '📈',
                  'متوسط يومي',
                  '${(insights['averageDailySpent'] ?? 0).toStringAsFixed(0)} ج.م',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  '🔢',
                  'إجمالي المعاملات',
                  '${insights['totalTransactions'] ?? 0}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightItem(
                  '💰',
                  'أغلى يوم',
                  insights['mostExpensiveDay'] ?? 'لا يوجد',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String emoji, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
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
                    color: AppTheme.textLightColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  // اختيار الشهر
  Widget _buildMonthSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: AppTheme.textLightColor,
              ),
              const SizedBox(width: 6),
              const Text(
                "اختر الشهر",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDarkColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              final isSelected = month.month == selectedMonth.month && 
                                month.year == selectedMonth.year;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMonth = month;
                    // إعادة تعيين إشعارات الميزانية عند تغيير الشهر
                    _budgetNotificationsSent.clear();
                  });
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getMonthName(month),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppTheme.textDarkColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        month.year.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.white70 : AppTheme.textLightColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  // أزرار الإجراءات السفلية
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // زر المساعد الصوتي مع أنيميشن
          AnimatedWidgets.pulsingButton(
            child: GestureDetector(
              onTap: () {
                if (voiceUsed >= voiceLimit) {
                  _showLimitReachedDialog('Voice Assistant');
                } else {
                  // تحديث الاستخدام في الـ provider
                  ref.read(userProvider.notifier).incrementUsage('voice_this_month');
                  Navigator.pushNamed(context, '/voice_assistant');
                }
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFe63946),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFe63946).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "🎤",
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      "صوتي",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // زر OCR مع أنيميشن
          AnimatedWidgets.pulsingButton(
            child: GestureDetector(
              onTap: () {
                if (ocrUsed >= ocrLimit) {
                  _showLimitReachedDialog('OCR Scanner');
                } else {
                  // تحديث الاستخدام في الـ provider
                  ref.read(userProvider.notifier).incrementUsage('ocr_this_month');
                  Navigator.pushNamed(context, '/ocr_scanner');
                }
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFf8961e),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFf8961e).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "📷",
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      "مسح",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // المصروفات الحديثة
  Widget _buildRecentExpenses() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان وزر إضافة مصروف
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "المصروفات الحديثة",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDarkColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showAddExpenseDialog();
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text("إضافة مصروف"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          
          // قائمة المصروفات
          const SizedBox(height: 16),
          recentTransactions.isEmpty
              ? _buildEmptyExpensesState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final expense = recentTransactions[index];
                    return _buildExpenseItem(expense);
                  },
                ),
        ],
      ),
    );
  }
  
  // عنصر مصروف واحد
  Widget _buildExpenseItem(Map<String, dynamic> expense) {
    // تنسيق التاريخ
    final date = DateTime.parse(expense['date']);
    final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // أيقونة المصروف
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (expense['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                expense['icon'] as IconData,
                color: expense['color'] as Color,
                size: 20,
              ),
            ),
            
            // تفاصيل المصروف
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textDarkColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          expense['details'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textLightColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expense['category'] + " • " + formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // المبلغ
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "EGP ${expense['amount']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textDarkColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // حالة فارغة للمصروفات  
  Widget _buildEmptyExpensesState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد مصروفات هذا الشهر',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ بإضافة أول مصروف لك',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textLightColor,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showAddExpenseDialog(),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('إضافة مصروف'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  

  // دالة لعرض مربع حوار تعيين الميزانية
  void _showSetBudgetDialog() {
    final TextEditingController budgetController = TextEditingController(
      text: budgetAmount.toStringAsFixed(0),
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text("تعيين الميزانية الشهرية"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                labelText: "الميزانية الشهرية",
                hintText: "مثال: 3000",
                prefixIcon: Icon(Icons.account_balance_wallet),
                suffixText: "ج.م",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "الميزانية الحالية: ${budgetAmount.toStringAsFixed(0)} ج.م\nالمصروفات هذا الشهر: ${totalExpenses.toStringAsFixed(0)} ج.م",
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLightColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              final newBudget = double.tryParse(budgetController.text);
              if (newBudget != null && newBudget > 0) {
                setState(() {
                  budgetAmount = newBudget;
                  // إعادة تعيين إشعارات الميزانية عند تغيير الميزانية
                  _budgetNotificationsSent.clear();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text("تم تحديث الميزانية إلى ${newBudget.toStringAsFixed(0)} ج.م"),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("يرجى إدخال مبلغ صحيح"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  // دالة لعرض مربع حوار إضافة مصروف
  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إضافة مصروف جديد"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "العنوان",
                hintText: "مثال: تسوق في السوبرماركت",
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "المبلغ",
                hintText: "أدخل المبلغ",
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  // دالة لعرض رسالة تجاوز الحد
  void _showLimitReachedDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text("وصلت للحد الأقصى"),
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

  // دالة لعرض مربع حوار المساعد الصوتي
  void _showVoiceAssistantDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.mic,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            SizedBox(width: 8),
            Text("المساعد الصوتي"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("أنا جاهز للاستماع!"),
            SizedBox(height: 12),
            Text(
              "يمكنك قول:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text("• أضف مصروف 100 جنيه طعام"),
            Text("• أظهر مصروفات الشهر الماضي"),
            Text("• كم أنفقت على الوقود هذا الشهر؟"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              // هنا يمكن تفعيل المساعد الصوتي
              Navigator.pop(context);
            },
            child: const Text("ابدأ الاستماع"),
          ),
        ],
      ),
    );
  }
  
  // دالة مساعدة للحصول على اسم الشهر بالعربية
  String _getMonthName(DateTime date) {
    final List<String> arabicMonths = [
      "يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو",
      "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"
    ];
    
    return arabicMonths[date.month - 1];
  }

  // فحص بسيط لإشعارات الميزانية
  void _checkBudgetAlerts(double progressPercentage) {
    final percentage = (progressPercentage * 100).round();
    
    // فحص النسب الرئيسية وإرسال إشعار مرة واحدة فقط
    if (percentage >= 25 && !_budgetNotificationsSent.contains(25) && percentage < 50) {
      _budgetNotificationsSent.add(25);
      _showBudgetAlert("⚠️ تحذير الميزانية", "وصلت لـ 25% من ميزانيتك الشهرية", Colors.yellow.shade700);
    } else if (percentage >= 50 && !_budgetNotificationsSent.contains(50) && percentage < 75) {
      _budgetNotificationsSent.add(50);
      _showBudgetAlert("🟡 نصف الميزانية", "وصلت لـ 50% من ميزانيتك الشهرية", Colors.orange);
    } else if (percentage >= 75 && !_budgetNotificationsSent.contains(75) && percentage < 100) {
      _budgetNotificationsSent.add(75);
      _showBudgetAlert("🔶 تحذير مهم", "وصلت لـ 75% من ميزانيتك الشهرية", Colors.deepOrange);
    } else if (percentage >= 100 && !_budgetNotificationsSent.contains(100)) {
      _budgetNotificationsSent.add(100);
      _showBudgetAlert("🚨 تجاوزت الميزانية", "تجاوزت 100% من ميزانيتك الشهرية!", Colors.red);
    }
  }

  // إظهار إشعار الميزانية البسيط
  void _showBudgetAlert(String title, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title - $message'),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // زر الإشعارات المتطور مع مؤشر
  Widget _buildNotificationButton() {
    final unreadCount = 2; // محاكاة عدد الإشعارات غير المقروءة
    
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_rounded, color: Colors.white),
            onPressed: () {
              // فحص الإشعارات أولاً
              NotificationService.instance.checkAndShowNotifications(context, ref);
              
              // تجربة الإشعارات الذكية
              SmartNotificationsService.simulateSmartNotifications();
              
              // فتح صفحة الإشعارات
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ),
        
        // مؤشر الإشعارات غير المقروءة
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

