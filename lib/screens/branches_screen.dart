import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../utils/smart_data_generator.dart';

class BranchesScreen extends ConsumerStatefulWidget {
  const BranchesScreen({super.key});

  @override
  ConsumerState<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends ConsumerState<BranchesScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // مولد البيانات الذكي
  late SmartDataGenerator _dataGenerator;
  bool _isLoading = false;
  String _selectedView = 'grid'; // grid or list
  
  // محاكاة بيانات الفروع
  final List<Map<String, dynamic>> _branches = [
    {
      'id': '1',
      'name': 'فرع وسط البلد',
      'location': 'شارع طلعت حرب، وسط البلد، القاهرة',
      'manager': 'أحمد محمد علي',
      'phone': '02-25123456',
      'employees': 12,
      'monthlyRevenue': 850000,
      'monthlyTarget': 900000,
      'performance': 94.4,
      'status': 'active',
      'openingHours': '9:00 ص - 10:00 م',
      'area': '250 م²',
      'established': '2020',
      'color': Colors.blue,
      'image': 'assets/images/branch1.jpg',
    },
    {
      'id': '2',
      'name': 'فرع المعادي',
      'location': 'شارع 9، المعادي، القاهرة',
      'manager': 'فاطمة أحمد',
      'phone': '02-23456789',
      'employees': 8,
      'monthlyRevenue': 620000,
      'monthlyTarget': 700000,
      'performance': 88.6,
      'status': 'active',
      'openingHours': '10:00 ص - 11:00 م',
      'area': '180 م²',
      'established': '2021',
      'color': Colors.green,
      'image': 'assets/images/branch2.jpg',
    },
    {
      'id': '3',
      'name': 'فرع الإسكندرية',
      'location': 'كورنيش الإسكندرية، الأزاريطة',
      'manager': 'محمد حسام',
      'phone': '03-12345678',
      'employees': 15,
      'monthlyRevenue': 1200000,
      'monthlyTarget': 1100000,
      'performance': 109.1,
      'status': 'active',
      'openingHours': '8:00 ص - 11:00 م',
      'area': '320 م²',
      'established': '2019',
      'color': Colors.purple,
      'image': 'assets/images/branch3.jpg',
    },
    {
      'id': '4',
      'name': 'فرع النزهة',
      'location': 'شارع عباس العقاد، مدينة نصر',
      'manager': 'سارة يوسف',
      'phone': '02-26789012',
      'employees': 10,
      'monthlyRevenue': 750000,
      'monthlyTarget': 800000,
      'performance': 93.8,
      'status': 'active',
      'openingHours': '9:00 ص - 10:00 م',
      'area': '200 م²',
      'established': '2022',
      'color': Colors.orange,
      'image': 'assets/images/branch4.jpg',
    },
    {
      'id': '5',
      'name': 'فرع الجيزة',
      'location': 'شارع الهرم، الجيزة',
      'manager': 'خالد عبد الرحمن',
      'phone': '02-35123456',
      'employees': 6,
      'monthlyRevenue': 0,
      'monthlyTarget': 500000,
      'performance': 0,
      'status': 'under_construction',
      'openingHours': 'قريباً',
      'area': '150 م²',
      'established': '2024',
      'color': Colors.grey,
      'image': 'assets/images/branch5.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _dataGenerator = SmartDataGenerator();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _isLoading = false;
    });
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('🏢 إدارة الفروع'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_selectedView == 'grid' ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _selectedView = _selectedView == 'grid' ? 'list' : 'grid';
              });
            },
            tooltip: _selectedView == 'grid' ? 'عرض قائمة' : 'عرض شبكة',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddBranchDialog,
            tooltip: 'إضافة فرع جديد',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'جاري تحميل بيانات الفروع...',
                    style: TextStyle(
                      color: AppTheme.textLightColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverviewStats(),
                      const SizedBox(height: 20),
                      _buildFilterChips(),
                      const SizedBox(height: 20),
                      _selectedView == 'grid' 
                          ? _buildBranchesGrid()
                          : _buildBranchesList(),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showBranchAnalytics,
        icon: const Icon(Icons.analytics),
        label: const Text('تحليل الفروع'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildOverviewStats() {
    final activeBranches = _branches.where((b) => b['status'] == 'active').length;
    final totalRevenue = _branches
        .where((b) => b['status'] == 'active')
        .fold(0.0, (sum, b) => sum + b['monthlyRevenue']);
    final totalEmployees = _branches.fold(0, (sum, b) => sum + (b['employees'] as int));
    final avgPerformance = activeBranches > 0 
        ? _branches
            .where((b) => b['status'] == 'active')
            .fold(0.0, (sum, b) => sum + b['performance']) / activeBranches
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.indigo.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.business, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'نظرة عامة على الفروع',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildOverviewItem(
                'الفروع النشطة',
                '$activeBranches',
                Icons.store,
                Colors.green,
              ),
              const SizedBox(width: 16),
              _buildOverviewItem(
                'إجمالي الإيرادات',
                '${(totalRevenue / 1000000).toStringAsFixed(1)}M ج.م',
                Icons.monetization_on,
                Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildOverviewItem(
                'إجمالي الموظفين',
                '$totalEmployees',
                Icons.people,
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildOverviewItem(
                'متوسط الأداء',
                '${avgPerformance.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        Text(
          'فلترة الفروع:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('الكل', true),
                const SizedBox(width: 8),
                _buildFilterChip('نشط', false),
                const SizedBox(width: 8),
                _buildFilterChip('قيد الإنشاء', false),
                const SizedBox(width: 8),
                _buildFilterChip('أداء عالي', false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // تطبيق الفلتر
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildBranchesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _branches.length,
      itemBuilder: (context, index) {
        final branch = _branches[index];
        return _buildBranchCard(branch);
      },
    );
  }

  Widget _buildBranchesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _branches.length,
      itemBuilder: (context, index) {
        final branch = _branches[index];
        return _buildBranchListItem(branch);
      },
    );
  }

  Widget _buildBranchCard(Map<String, dynamic> branch) {
    final isActive = branch['status'] == 'active';
    final performance = branch['performance'] as double;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showBranchDetails(branch),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                branch['color'].withOpacity(0.1),
                branch['color'].withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: branch['color'].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.store,
                        color: branch['color'],
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'نشط' : 'قيد الإنشاء',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  branch['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  branch['manager'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                if (isActive) ...[
                  Row(
                    children: [
                      const Icon(Icons.people, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${branch['employees']} موظف',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${performance.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: performance >= 100 ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: performance / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      performance >= 100 ? Colors.green : Colors.orange,
                    ),
                  ),
                ] else ...[
                  const Text(
                    'قيد الإنشاء...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranchListItem(Map<String, dynamic> branch) {
    final isActive = branch['status'] == 'active';
    final performance = branch['performance'] as double;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: branch['color'].withOpacity(0.2),
          child: Icon(
            Icons.store,
            color: branch['color'],
          ),
        ),
        title: Text(
          branch['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(branch['manager']),
            if (isActive)
              Text(
                'الأداء: ${performance.toStringAsFixed(1)}% • ${branch['employees']} موظف',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: isActive
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: performance >= 100 ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  performance >= 100 ? 'ممتاز' : 'جيد',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : const Icon(Icons.construction, color: Colors.grey),
        onTap: () => _showBranchDetails(branch),
      ),
    );
  }

  void _showBranchDetails(Map<String, dynamic> branch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: branch['color'].withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.store,
                            color: branch['color'],
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch['name'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'مدير الفرع: ${branch['manager']}',
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
                    
                    _buildDetailSection('المعلومات الأساسية', [
                      _buildDetailItem('📍 العنوان', branch['location']),
                      _buildDetailItem('📞 الهاتف', branch['phone']),
                      _buildDetailItem('🕒 ساعات العمل', branch['openingHours']),
                      _buildDetailItem('📐 المساحة', branch['area']),
                      _buildDetailItem('📅 تأسس في', branch['established']),
                    ]),
                    
                    if (branch['status'] == 'active') ...[
                      const SizedBox(height: 20),
                      _buildDetailSection('الأداء والإحصائيات', [
                        _buildDetailItem('👥 عدد الموظفين', '${branch['employees']} موظف'),
                        _buildDetailItem('💰 الإيرادات الشهرية', '${(branch['monthlyRevenue'] / 1000).toStringAsFixed(0)}K ج.م'),
                        _buildDetailItem('🎯 الهدف الشهري', '${(branch['monthlyTarget'] / 1000).toStringAsFixed(0)}K ج.م'),
                        _buildDetailItem('📊 نسبة الأداء', '${branch['performance'].toStringAsFixed(1)}%'),
                      ]),
                    ],
                    
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _editBranch(branch),
                            icon: const Icon(Icons.edit),
                            label: const Text('تعديل'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _callBranch(branch['phone']),
                            icon: const Icon(Icons.phone),
                            label: const Text('اتصال'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBranchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة فرع جديد'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'اسم الفرع',
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'مدير الفرع',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إضافة الفرع بنجاح!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _editBranch(Map<String, dynamic> branch) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تعديل ${branch['name']}...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _callBranch(String phone) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('الاتصال بـ $phone'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showBranchAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.analytics, color: Colors.blue),
            SizedBox(width: 8),
            Text('تحليل أداء الفروع'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 أفضل الفروع أداءً:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('1. فرع الإسكندرية - 109.1%'),
              const Text('2. فرع وسط البلد - 94.4%'),
              const Text('3. فرع النزهة - 93.8%'),
              const SizedBox(height: 16),
              
              const Text(
                '💰 توزيع الإيرادات:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• الإسكندرية: 37.5%'),
              const Text('• وسط البلد: 26.6%'),
              const Text('• النزهة: 23.4%'),
              const Text('• المعادي: 19.4%'),
              const SizedBox(height: 16),
              
              const Text(
                '🎯 التوصيات:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• زيادة فريق فرع المعادي'),
              const Text('• حوافز لفرع الإسكندرية'),
              const Text('• تدريب إضافي لفرع النزهة'),
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
} 