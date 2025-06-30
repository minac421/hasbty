import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/user_plan.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/smart_data_generator.dart';
import 'voice_assistant_screen.dart';
import 'ocr_scanner_screen.dart';
import 'products_screen.dart';
import 'customers_screen.dart';
import 'suppliers_screen.dart';
import 'inventory_screen.dart';
import 'invoices_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'branches_screen.dart';

class EnterpriseDashboard extends ConsumerStatefulWidget {
  const EnterpriseDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<EnterpriseDashboard> createState() => _EnterpriseDashboardState();
}

class _EnterpriseDashboardState extends ConsumerState<EnterpriseDashboard> with SingleTickerProviderStateMixin {
  // متغير للتنقل السفلي
  int _selectedBottomNavIndex = 0;
  
  // مولد البيانات الذكي
  late SmartDataGenerator _dataGenerator;
  bool _isLoading = false;
  DateTime selectedMonth = DateTime.now();

  // قائمة التحكم في التبويبات
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _dataGenerator = SmartDataGenerator();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    // محاكاة تحميل البيانات الشركة المتقدمة
    await Future.delayed(const Duration(milliseconds: 1200));
    
    setState(() {
      _isLoading = false;
    });
  }

  // البيانات الديناميكية الذكية للشركة
  String get companyName => _dataGenerator.getEnterpriseName();
  String get adminName => _dataGenerator.getUserName();
  double get totalRevenue => _dataGenerator.getEnterpriseMonthlyRevenue(selectedMonth);
  double get totalExpenses => _dataGenerator.getEnterpriseMonthlyExpenses(selectedMonth);
  double get inventoryValue => _dataGenerator.getEnterpriseInventoryValue();
  int get totalProducts => _dataGenerator.getEnterpriseProductCount();
  int get totalCustomers => _dataGenerator.getEnterpriseCustomerCount();
  int get lowStockItems => _dataGenerator.getEnterpriseLowStockCount();
  int get branchCount => _dataGenerator.getEnterpriseBranchCount();
  int get employeeCount => _dataGenerator.getEnterpriseEmployeeCount();
  int get transactionCount => _dataGenerator.getEnterpriseTransactionCount(selectedMonth);
  List<double> get monthlySales => _dataGenerator.getEnterpriseMonthlyPerformance();
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Quick Theme Toggle للشركات المتقدمة
  Widget _buildEnterpriseQuickThemeToggle() {
    final themeInfo = ref.watch(themeInfoProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            themeNotifier.toggleTheme();
            
            // إظهار رسالة تأكيد للشركات
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
                          ? 'وضع الشركة المضيء ✨' 
                          : 'الوضع المظلم للشركات 🏢',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                backgroundColor: Colors.indigo.shade700,
                duration: const Duration(milliseconds: 1500),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                themeInfo['icon'],
                key: ValueKey(themeInfo['icon']),
                color: Colors.white,
                size: 18,
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'جاري تحميل بيانات الشركة...',
                      style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'تحليل البيانات المتقدمة',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // الشريط العلوي الاحترافي
                  _buildProfessionalHeader(),
                  
                  // المحتوى الرئيسي
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // شبكة البطاقات الرئيسية (3×2)
                            _buildMainStatsGrid(),
                            const SizedBox(height: 24),
                            
                            // إحصائيات ذكية للشركة
                            _buildEnterpriseInsights(),
                            const SizedBox(height: 24),
                            
                            // الرسم البياني التفاعلي
                            _buildInteractiveChart(),
                            const SizedBox(height: 24),
                            
                            // أفضل الفروع
                            _buildTopBranches(),
                            const SizedBox(height: 24),
                            
                            // المبيعات الحديثة
                            _buildRecentSales(),
                            const SizedBox(height: 24),
                            
                            // التنبيهات الذكية
                            _buildSmartAlerts(),
                            const SizedBox(height: 100), // مساحة إضافية للأزرار العائمة
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      
      // شريط التنقل السفلي
      bottomNavigationBar: _buildBottomNavigation(),
      
      // الأزرار العائمة للـ OCR والـ Voice Assistant
      floatingActionButton: _buildEnterpriseFloatingButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  Widget _buildProfessionalHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade800, Colors.indigo.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // شعار واسم الشركة
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
                      companyName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                    const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'المدير العام',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
              // أيقونات الإعدادات والإشعارات
              Row(
                children: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications, color: Colors.white),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                            child: const Text(
                              '3',
                              style: TextStyle(
        color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
          ),
        ],
      ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  
                  // Quick Theme Toggle للشركات
                  _buildEnterpriseQuickThemeToggle(),
                ],
          ),
        ],
      ),
          const SizedBox(height: 16),
          
          // مؤشرات سريعة
          Row(
            children: [
              Expanded(
                child: _buildQuickIndicator(
                  '∞',
                  'OCR غير محدود',
                  Icons.camera_alt,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickIndicator(
                  '∞',
                  'Voice غير محدود',
                  Icons.mic,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickIndicator(
                  '24/7',
                  'دعم VIP',
                  Icons.support_agent,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickIndicator(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
                  value,
            style: const TextStyle(
              color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
            ),
          ),
          Text(
                  label,
            style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildEnterpriseStatCard(
          'المبيعات الإجمالية',
          '${(totalRevenue / 1000000).toStringAsFixed(1)}M ج.م',
          Icons.trending_up,
          Colors.green,
          '+${(12 + (totalRevenue / 100000) % 8).toInt()}%',
        ),
        _buildEnterpriseStatCard(
          'الأرباح الصافية',
          '${((totalRevenue - totalExpenses) / 1000000).toStringAsFixed(1)}M ج.م',
          Icons.account_balance_wallet,
          Colors.blue,
          '+${(8 + (totalRevenue / 150000) % 6).toInt()}%',
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InventoryScreen()),
            );
          },
          child: _buildEnterpriseStatCard(
            'المخزون المتاح',
            '${(inventoryValue / 1000000).toStringAsFixed(1)}M ج.م',
            Icons.warehouse,
            Colors.orange,
            inventoryValue > 1000000 ? '+5%' : '-2%',
          ),
        ),
        _buildEnterpriseStatCard(
          'عدد الفروع',
          '$branchCount',
          Icons.business,
          Colors.purple,
          branchCount > 8 ? '+2' : '+1',
        ),
        _buildEnterpriseStatCard(
          'إجمالي الموظفين',
          '$employeeCount',
          Icons.people,
          Colors.teal,
          '+${(employeeCount * 0.05).toInt()}',
        ),
        _buildEnterpriseStatCard(
          'المعاملات الشهرية',
          '$transactionCount',
          Icons.receipt_long,
          Colors.red,
          '+${(15 + (transactionCount / 50) % 10).toInt()}%',
        ),
      ],
    );
  }
  
  Widget _buildEnterpriseStatCard(String title, String value, IconData icon, Color color, String change) {
    final isPositive = change.startsWith('+');
    
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              change,
                      style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInteractiveChart() {
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
            children: [
              const Icon(Icons.analytics, color: Colors.indigo),
              const SizedBox(width: 8),
              const Text(
                'الأداء الشهري - 2024',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'export', child: Text('تصدير البيانات')),
                  const PopupMenuItem(value: 'analyze', child: Text('تحليل AI')),
                  const PopupMenuItem(value: 'share', child: Text('مشاركة التقرير')),
                ],
                onSelected: (value) {
                  if (value == 'analyze') {
                    _showAIAnalysis();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // رسم بياني تفاعلي مبسط
          Container(
            height: 200,
            child: _buildAdvancedChart(),
          ),
          
          const SizedBox(height: 16),
          
          // مفاتيح الرسم البياني
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend('المبيعات', Colors.green),
              const SizedBox(width: 24),
              _buildChartLegend('الأرباح', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAdvancedChart() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: monthlySales.map<Widget>((sales) {
        final salesHeight = (sales / 350000) * 150;
        
    return Column(
          mainAxisAlignment: MainAxisAlignment.end,
      children: [
            // أعمدة الرسم البياني
            Container(
              width: 16,
              height: salesHeight,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
        Text(
              '${sales.toInt()}',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // إحصائيات ذكية للشركة المتقدمة
  Widget _buildEnterpriseInsights() {
    final insights = _dataGenerator.getEnterpriseInsights(selectedMonth);
    final netProfit = totalRevenue - totalExpenses;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade100,
            Colors.indigo.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.indigo.shade200,
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
                  color: Colors.indigo.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.indigo,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'نظرة تحليلية شاملة',
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
                child: _buildEnterpriseInsightCard(
                  '💰',
                  'صافي الربح',
                  '${(netProfit / 1000000).toStringAsFixed(1)}M ج.م',
                  netProfit > 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnterpriseInsightCard(
                  '🏆',
                  'أفضل فرع',
                  insights['topBranch'] ?? 'غير محدد',
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEnterpriseInsightCard(
                  '⭐',
                  'أفضل موظف',
                  insights['topEmployee'] ?? 'غير محدد',
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnterpriseInsightCard(
                  '📊',
                  'هامش الربح',
                  '${(insights['profitMargin'] ?? 0).toStringAsFixed(1)}%',
                  (insights['profitMargin'] ?? 0) > 30 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnterpriseInsightCard(String emoji, String title, String value, Color color) {
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

  // المبيعات الحديثة للشركة
  Widget _buildRecentSales() {
    final recentSales = _dataGenerator.getEnterpriseRecentSales(5);
    
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
              const Row(
                children: [
                  Icon(Icons.receipt_long, color: Colors.indigo),
                  SizedBox(width: 8),
                  Text(
                    'أحدث المبيعات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/reports'),
                child: const Text('عرض التقرير الكامل'),
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
            ...recentSales.map((sale) => _buildEnterpriseSaleItem(sale)).toList(),
        ],
      ),
    );
  }

  Widget _buildEnterpriseSaleItem(Map<String, dynamic> sale) {
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
              gradient: LinearGradient(
                colors: [Colors.indigo.shade400, Colors.indigo.shade600],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.business_center,
              color: Colors.white,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sale['productName'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        sale['branchName'],
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(sale['totalAmount'] / 1000).toStringAsFixed(0)}K ج.م',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 14,
                ),
              ),
              Text(
                sale['salesPerson'],
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopBranches() {
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
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
          const Text(
                'أفضل الفروع أداءً',
            style: TextStyle(
                  fontSize: 18,
              fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showBranchesScreen(),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ..._dataGenerator.getEnterpriseTopBranches(4).map<Widget>((branch) {
            final index = _dataGenerator.getEnterpriseTopBranches(4).indexOf(branch);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
            children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: index == 0 ? Colors.amber : Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          branch['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              'مبيعات: ${(branch['monthlyRevenue'] / 1000).toStringAsFixed(0)}K ج.م',
                                style: TextStyle(
                                  fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${branch['employeeCount']} موظف',
                                style: TextStyle(
                                  fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${branch['performance']}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSmartAlerts() {
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
            children: [
              const Icon(Icons.notification_important, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                'التنبيهات الذكية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
                child: const Text('عرض الكل'),
          ),
        ],
      ),
          const SizedBox(height: 16),
          
          // تنبيهات ذكية للشركة
          _buildSmartAlert(
            Icons.trending_up,
            Colors.green,
            'مبيعات ممتازة: ${(totalRevenue / 1000000).toStringAsFixed(1)}M ج.م هذا الشهر',
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InventoryScreen()),
              );
            },
            child: _buildSmartAlert(
              Icons.warning,
              Colors.orange,
              'تنبيه مخزون: ${lowStockItems} منتج يحتاج إعادة تموين - اضغط للمراجعة',
            ),
          ),
          _buildSmartAlert(
            Icons.people,
            Colors.blue,
            'نمو العملاء: +${(totalCustomers * 0.12).toInt()} عميل جديد',
          ),
          _buildSmartAlert(
            Icons.business,
            Colors.purple,
            'أداء الفروع: ${branchCount} فرع بمعدل أداء ${((85 + (totalRevenue / 100000) % 15)).toInt()}%',
          ),
        ],
      ),
    );
  }

  Widget _buildSmartAlert(IconData icon, Color color, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAdvancedAnalytics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.indigo),
              const SizedBox(width: 8),
              const Text(
                'تحليلات الذكاء الاصطناعي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAIAnalysis(),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('تحليل متقدم'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          const Text(
            '🤖 توصيات ذكية لهذا الشهر:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildAIRecommendation(
            '📈 زيادة المخزون لـ "لابتوب Dell" - متوقع ارتفاع الطلب 25%',
            Colors.green,
          ),
          _buildAIRecommendation(
            '⚠️ مراجعة أسعار "مواد البناء" - منافسين أقل بـ 8%',
            Colors.orange,
          ),
          _buildAIRecommendation(
            '🎯 فرع النزهة يحتاج موظف إضافي - زيادة العبء 15%',
            Colors.blue,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAIRecommendation(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
        color: Colors.white,
              borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedBottomNavIndex,
      onTap: (index) {
        setState(() => _selectedBottomNavIndex = index);
        _navigateToPage(index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.indigo,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.warehouse),
          label: 'المخزون',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'التقارير',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'العملاء',
        ),
      ],
    );
  }

  Widget _buildVIPSupportButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showVIPSupport(),
      backgroundColor: Colors.amber,
      foregroundColor: Colors.black,
      icon: const Icon(Icons.support_agent),
      label: const Text('دعم VIP'),
    );
  }

  void _showAIAnalysis() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.indigo),
            SizedBox(width: 8),
            Text('تحليل الذكاء الاصطناعي'),
          ],
        ),
        content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
              children: [
              Text('📊 تحليل الأداء العام:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• نمو المبيعات: +12% مقارنة بالشهر الماضي'),
              Text('• كفاءة المخزون: 85% (ممتازة)'),
              Text('• رضا العملاء: 4.2/5 نجوم'),
              SizedBox(height: 16),
              
              Text('🎯 التوصيات الاستراتيجية:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. تطوير خدمات فرع المعادي لزيادة الأرباح'),
              Text('2. استثمار في تقنيات المخزون الذكي'),
              Text('3. برنامج ولاء العملاء لزيادة الاحتفاظ'),
              SizedBox(height: 16),
              
              Text('⚡ فرص فورية:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• عرض خاص على المنتجات بطيئة الحركة'),
              Text('• حملة تسويقية لفئة الشباب'),
              Text('• شراكات مع موردين جدد'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ التحليل في التقارير'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('حفظ التحليل'),
                ),
              ],
            ),
    );
  }

  void _showBranchesScreen() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إدارة الفروع والموظفين'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
            children: [
            ListTile(
              leading: const Icon(Icons.business, color: Colors.blue),
              title: const Text('إدارة الفروع'),
              subtitle: const Text('عرض وإدارة جميع الفروع'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BranchesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.green),
              title: const Text('إدارة الموظفين'),
              subtitle: const Text('الصلاحيات والمستخدمين'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/employees');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2, color: Colors.purple),
              title: const Text('إدارة المنتجات'),
              subtitle: const Text('عرض وإدارة كتالوج المنتجات'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.orange),
              title: const Text('تحليلات الفروع'),
              subtitle: const Text('مقارنة أداء الفروع'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/reports');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
                  ),
                ],
              ),
    );
  }

  void _showVIPSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
                children: [
            Icon(Icons.support_agent, color: Colors.amber),
            SizedBox(width: 8),
            Text('دعم VIP - 24/7'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('مرحباً! كيف يمكننا مساعدتك اليوم؟'),
            SizedBox(height: 16),
            
            ListTile(
              leading: Icon(Icons.chat, color: Colors.blue),
              title: Text('دردشة مباشرة'),
              subtitle: Text('متاح الآن - وقت الاستجابة: < 2 دقيقة'),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.green),
              title: Text('مكالمة مباشرة'),
              subtitle: Text('01012345678 - متاح 24/7'),
            ),
            ListTile(
              leading: Icon(Icons.video_call, color: Colors.purple),
              title: Text('مكالمة فيديو'),
              subtitle: Text('دعم تقني متخصص'),
                  ),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('جاري الاتصال بفريق الدعم...'),
                  backgroundColor: Colors.amber,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('ابدأ الدردشة'),
          ),
        ],
      ),
    );
  }
  
  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        // Dashboard - current page
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InventoryScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportsScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CustomersScreen()),
        );
        break;
    }
  }

  // الأزرار العائمة الدائرية للمؤسسات
  Widget _buildEnterpriseFloatingButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // زر OCR دائري للمؤسسات
        _buildEnterpriseCircularOcrButton(),
        
        // زر Voice Assistant دائري للمؤسسات
        _buildEnterpriseCircularVoiceButton(),
      ],
    );
  }

  // زر OCR دائري مبسط للمؤسسات
  Widget _buildEnterpriseCircularOcrButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/ocr_scanner');
      },
      backgroundColor: Colors.transparent,
      elevation: 8,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade500, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.shade500.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.corporate_fare,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  // زر Voice Assistant دائري مبسط للمؤسسات
  Widget _buildEnterpriseCircularVoiceButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/voice_assistant');
      },
      backgroundColor: Colors.transparent,
      elevation: 8,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade600, Colors.orange.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.shade600.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.precision_manufacturing,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

// فئة لبيانات الرسم البياني
class SalesCategory {
  final String name;
  final int percentage;
  final Color color;
  
  SalesCategory(this.name, this.percentage, this.color);
} 