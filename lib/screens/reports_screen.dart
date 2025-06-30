import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart'; // For charts
import '../theme/app_theme.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/empty_states.dart';
import '../providers/products_provider.dart';
import '../providers/sales_provider.dart';
import '../providers/customers_provider.dart';
import '../providers/suppliers_provider.dart';
import '../providers/purchases_provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/user_provider.dart';
import '../services/feature_manager_service.dart';


class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String _selectedPeriod = 'شهر';
  final List<String> _periods = ['يوم', 'أسبوع', 'شهر'];
  
  // بيانات تجريبية للتقارير
  final Map<String, Map<String, dynamic>> _reportData = {
    'يوم': {
      'sales': 2500.0,
      'purchases': 1200.0,
      'profit': 1300.0,
      'invoices': 12,
      'customers': 8,
      'topProducts': [
        {'name': 'لابتوب Dell', 'sales': 3, 'revenue': 3600.0},
        {'name': 'تيشيرت قطني', 'sales': 15, 'revenue': 2250.0},
      ],
      'chartData': [
        {'day': 'اليوم', 'sales': 2500.0, 'purchases': 1200.0},
      ],
    },
    'أسبوع': {
      'sales': 18500.0,
      'purchases': 8200.0,
      'profit': 10300.0,
      'invoices': 45,
      'customers': 28,
      'topProducts': [
        {'name': 'لابتوب Dell', 'sales': 12, 'revenue': 14400.0},
        {'name': 'تيشيرت قطني', 'sales': 67, 'revenue': 10050.0},
        {'name': 'رز بسمتي', 'sales': 25, 'revenue': 2000.0},
      ],
      'chartData': [
        {'day': 'السبت', 'sales': 3200.0, 'purchases': 1500.0},
        {'day': 'الأحد', 'sales': 2800.0, 'purchases': 1200.0},
        {'day': 'الاثنين', 'sales': 2100.0, 'purchases': 900.0},
        {'day': 'الثلاثاء', 'sales': 2650.0, 'purchases': 1100.0},
        {'day': 'الأربعاء', 'sales': 3150.0, 'purchases': 1300.0},
        {'day': 'الخميس', 'sales': 2900.0, 'purchases': 1050.0},
        {'day': 'الجمعة', 'sales': 1700.0, 'purchases': 1150.0},
      ],
    },
    'شهر': {
      'sales': 75000.0,
      'purchases': 32000.0,
      'profit': 43000.0,
      'invoices': 186,
      'customers': 94,
      'topProducts': [
        {'name': 'لابتوب Dell', 'sales': 45, 'revenue': 54000.0},
        {'name': 'تيشيرت قطني', 'sales': 234, 'revenue': 35100.0},
        {'name': 'رز بسمتي', 'sales': 120, 'revenue': 9600.0},
        {'name': 'أسمنت بورتلاند', 'sales': 85, 'revenue': 15300.0},
      ],
      'chartData': [
        {'day': 'الأسبوع 1', 'sales': 18500.0, 'purchases': 8200.0},
        {'day': 'الأسبوع 2', 'sales': 22300.0, 'purchases': 9100.0},
        {'day': 'الأسبوع 3', 'sales': 17800.0, 'purchases': 7500.0},
        {'day': 'الأسبوع 4', 'sales': 16400.0, 'purchases': 7200.0},
      ],
    },
  };

  Map<String, dynamic> get currentData => _reportData[_selectedPeriod]!;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchReportData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchReportData() async {
    setState(() {
      _isLoading = true;
    });
    
    // محاكاة تحميل البيانات
    await Future.delayed(const Duration(seconds: 2));
    
    // في المستقبل سيتم جلب البيانات من قاعدة البيانات
    // try {
    //   final userId = supabase.auth.currentUser!.id;
    //   // Fetch real data...
    // } catch (error) {
    //   // Handle error...
    // }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildReportsHeader(BuildContext context, double totalIncome, double totalExpenses) {
    final colorScheme = Theme.of(context).colorScheme;
    final netBalance = totalIncome - totalExpenses;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'نظرة عامة',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'الرصيد الصافي',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${netBalance.toStringAsFixed(2)} جنيه',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: netBalance >= 0 ? AppTheme.successColor : AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSummaryCards(BuildContext context, double totalIncome, double totalExpenses) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            'إجمالي الإيرادات',
            '${totalIncome.toStringAsFixed(2)} جنيه',
             Icons.trending_up_rounded,
             AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            context,
            'إجمالي المصروفات',
            '${totalExpenses.toStringAsFixed(2)} جنيه',
             Icons.trending_down_rounded,
             AppTheme.errorColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String amount, IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernChartsSection(BuildContext context, Map<String, dynamic> salesStats, Map<String, dynamic> purchasesStats) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // بيانات للرسم البياني
    final paymentMethods = purchasesStats['paymentMethods'] as Map<String, double>? ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'التحليل البياني', Icons.pie_chart_rounded),
        const SizedBox(height: 16),
        
        // التحقق من ميزة التقارير المتقدمة
        Builder(
          builder: (context) {
            final userPlan = ref.watch(userPlanProvider);
            final featureManager = ref.read(featureManagerProvider);
            
            if (FeatureManagerService.isFeatureAvailable(userPlan, 'advanced_reports')) {
              return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              if (paymentMethods.isNotEmpty) ...[
                Text(
                  'توزيع المشتريات حسب طريقة الدفع',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: paymentMethods.entries.map((entry) {
                        final index = paymentMethods.keys.toList().indexOf(entry.key);
                        return PieChartSectionData(
                          color: Colors.primaries[index % Colors.primaries.length],
                          value: entry.value,
                          title: '${entry.key}\n${entry.value.toStringAsFixed(0)}',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ] else ...[
                Column(
                  children: [
                    Icon(
                      Icons.pie_chart_outline_rounded,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد بيانات للعرض',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
              );
            } else {
              // إظهار رسالة للمستخدمين بدون الميزة
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 48,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'التقارير المتقدمة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'احصل على رسوم بيانية تفاعلية وتحليلات متقدمة',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/subscriptions');
                      },
                      icon: const Icon(Icons.rocket_launch_rounded),
                      label: const Text('ترقية الباقة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildModernCategoryBreakdown(BuildContext context, Map<String, dynamic> salesStats, Map<String, dynamic> purchasesStats, double totalIncome, double totalExpenses) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'تحليل ذكي', Icons.psychology_rounded),
        const SizedBox(height: 16),
        
        // التحقق من ميزة التقارير الاحترافية
        Builder(
          builder: (context) {
            final userPlan = ref.watch(userPlanProvider);
            final featureManager = ref.read(featureManagerProvider);
            
            if (FeatureManagerService.isFeatureAvailable(userPlan, 'premium_reports')) {
              return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _buildInsightCard(
                context,
                'أكثر طريقة دفع للمشتريات',
                _getTopExpenseCategory(purchasesStats),
                Icons.trending_down_rounded,
                AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              _buildInsightCard(
                context,
                'أفضل مصدر دخل',
                _getTopIncomeSource(salesStats),
                Icons.trending_up_rounded,
                AppTheme.successColor,
              ),
              const SizedBox(height: 16),
              _buildInsightCard(
                context,
                'نصيحة لتحسين الربح',
                _getProfitImprovementTip(totalIncome, totalExpenses),
                Icons.lightbulb_rounded,
                AppTheme.warningColor,
              ),
            ],
          ),
              );
            } else if (FeatureManagerService.isFeatureAvailable(userPlan, 'advanced_reports')) {
              // إظهار معاينة محدودة للباقات المتوسطة
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildInsightCard(
                      context,
                      'أفضل مصدر دخل',
                      _getTopIncomeSource(salesStats),
                      Icons.trending_up_rounded,
                      AppTheme.successColor,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'احصل على تحليلات AI متقدمة مع باقة الشركات الكبيرة',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/subscriptions');
                            },
                            child: const Text('ترقية'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // للباقة المجانية
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      size: 48,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'التحليل الذكي غير متاح في النسخة المجانية',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(BuildContext context, String title, String content, IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTopExpenseCategory(Map<String, dynamic> purchasesStats) {
    final paymentMethods = purchasesStats['paymentMethods'] as Map<String, double>? ?? {};
    if (paymentMethods.isEmpty) return 'لا توجد مشتريات';
    var topMethod = paymentMethods.entries.reduce((a, b) => a.value > b.value ? a : b);
    return '${topMethod.key} (${topMethod.value.toStringAsFixed(2)} جنيه)';
  }

  String _getTopIncomeSource(Map<String, dynamic> salesStats) {
    final totalRevenue = salesStats['totalRevenue'] ?? 0.0;
    if (totalRevenue == 0) return 'لا توجد إيرادات';
    return 'المبيعات الإجمالية (${totalRevenue.toStringAsFixed(2)} جنيه)';
  }

  String _getProfitImprovementTip(double totalIncome, double totalExpenses) {
    double netProfit = totalIncome - totalExpenses;
    if (netProfit > 0) {
      return 'أداء جيد! حاول زيادة الإيرادات أكثر.';
    } else if (netProfit == 0) {
      return 'أنت في نقطة التعادل. حاول تقليل المصروفات أو زيادة الإيرادات.';
    } else {
      return 'تحتاج لتقليل المصروفات أو زيادة الإيرادات لتحقيق الربح.';
    }
  }

  Widget _buildStatisticsSection(BuildContext context, Map<String, dynamic> salesStats, Map<String, dynamic> purchasesStats, Map<String, dynamic> productsStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'إحصائيات مفصلة', Icons.bar_chart_rounded),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'إجمالي المبيعات',
                '${salesStats['totalSales'] ?? 0}',
                Icons.shopping_cart_rounded,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'إجمالي المشتريات',
                '${purchasesStats['totalPurchases'] ?? 0}',
                Icons.shopping_bag_rounded,
                AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'إجمالي المنتجات',
                '${productsStats['totalProducts'] ?? 0}',
                Icons.inventory_rounded,
                AppTheme.successColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInsights(BuildContext context, double totalIncome, double totalExpenses, Map<String, dynamic> inventoryStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'رؤى الأعمال', Icons.lightbulb_rounded),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildInsightCard(
                context,
                'أعلى حركة مخزون',
                'اليوم: ${inventoryStats['todayIn'] ?? 0} إدخال، ${inventoryStats['todayOut'] ?? 0} إخراج',
                Icons.swap_horiz_rounded,
                AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              _buildInsightCard(
                context,
                'قيمة المخزون الصافي',
                '${(inventoryStats['netInventoryValue'] ?? 0.0).toStringAsFixed(2)} جنيه',
                Icons.account_balance_wallet_rounded,
                AppTheme.successColor,
              ),
              const SizedBox(height: 16),
              _buildInsightCard(
                context,
                'نصيحة لتحسين الربح',
                _getProfitImprovementTip(totalIncome, totalExpenses),
                Icons.psychology_rounded,
                AppTheme.warningColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // جلب البيانات من Providers
    final salesStats = ref.watch(salesStatsProvider);
    final purchasesStats = ref.watch(purchasesStatsProvider);
    final productsStats = ref.watch(productsStatsProvider);
    final customersStats = ref.watch(customersStatsProvider);
    final suppliersStats = ref.watch(suppliersStatsProvider);
    final inventoryStats = ref.watch(inventoryStatsProvider);
    
    final totalIncome = salesStats['totalRevenue'] ?? 0.0;
    final totalExpenses = purchasesStats['totalAmount'] ?? 0.0;
    final monthlyIncome = salesStats['monthlyRevenue'] ?? 0.0;
    final monthlyExpenses = purchasesStats['monthlyPurchases'] ?? 0.0;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            AppTheme.iconContainer(
              icon: Icons.analytics_rounded,
              color: Colors.white,
              size: 24,
              containerSize: 40,
            ),
            const SizedBox(width: 12),
            const Text('التقارير والتحليلات'),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث البيانات')),
              );
            },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'تحديث البيانات',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث البيانات')),
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildReportsHeader(context, totalIncome, totalExpenses),
              const SizedBox(height: 32),
              
              // Summary Cards
              _buildModernSummaryCards(context, totalIncome, totalExpenses),
              const SizedBox(height: 32),
              
              // Statistics Section
              _buildStatisticsSection(context, salesStats, purchasesStats, productsStats),
              const SizedBox(height: 32),
              
              // Business Insights
              _buildBusinessInsights(context, totalIncome, totalExpenses, inventoryStats),
              const SizedBox(height: 32),
              
              // Charts Section
              _buildModernChartsSection(context, salesStats, purchasesStats),
              const SizedBox(height: 32),
              
              // Category Breakdown
              _buildModernCategoryBreakdown(context, salesStats, purchasesStats, totalIncome, totalExpenses),
            ],
          ),
        ),
      ),
    );
  }
}


