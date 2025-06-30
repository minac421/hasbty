import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  
  // محاكاة بيانات الموظفين
  final List<Map<String, dynamic>> _employees = [
    {
      'id': '1',
      'name': 'أحمد محمد علي',
      'position': 'مدير فرع وسط البلد',
      'branch': 'وسط البلد',
      'phone': '+201012345678',
      'email': 'ahmed@company.com',
      'salary': 15000,
      'hireDate': '2020-03-15',
      'performance': 95,
      'avatar': 'https://i.pravatar.cc/100?img=1',
      'status': 'active',
      'department': 'إدارة',
    },
    {
      'id': '2',
      'name': 'فاطمة أحمد حسن',
      'position': 'مديرة فرع المعادي',
      'branch': 'المعادي',
      'phone': '+201987654321',
      'email': 'fatima@company.com',
      'salary': 14000,
      'hireDate': '2021-01-10',
      'performance': 92,
      'avatar': 'https://i.pravatar.cc/100?img=2',
      'status': 'active',
      'department': 'إدارة',
    },
    {
      'id': '3',
      'name': 'محمد حسام إبراهيم',
      'position': 'مدير فرع الإسكندرية',
      'branch': 'الإسكندرية',
      'phone': '+201123456789',
      'email': 'mohamed@company.com',
      'salary': 16000,
      'hireDate': '2019-07-22',
      'performance': 98,
      'avatar': 'https://i.pravatar.cc/100?img=3',
      'status': 'active',
      'department': 'إدارة',
    },
    {
      'id': '4',
      'name': 'سارة يوسف محمد',
      'position': 'مديرة فرع النزهة',
      'branch': 'النزهة',
      'phone': '+201555666777',
      'email': 'sara@company.com',
      'salary': 13500,
      'hireDate': '2022-02-01',
      'performance': 88,
      'avatar': 'https://i.pravatar.cc/100?img=4',
      'status': 'active',
      'department': 'إدارة',
    },
    {
      'id': '5',
      'name': 'خالد عبد الرحمن',
      'position': 'محاسب رئيسي',
      'branch': 'المقر الرئيسي',
      'phone': '+201666777888',
      'email': 'khaled@company.com',
      'salary': 12000,
      'hireDate': '2020-09-10',
      'performance': 90,
      'avatar': 'https://i.pravatar.cc/100?img=5',
      'status': 'active',
      'department': 'محاسبة',
    },
    {
      'id': '6',
      'name': 'نور الدين أحمد',
      'position': 'مطور نظم',
      'branch': 'المقر الرئيسي',
      'phone': '+201777888999',
      'email': 'nour@company.com',
      'salary': 18000,
      'hireDate': '2021-05-15',
      'performance': 96,
      'avatar': 'https://i.pravatar.cc/100?img=6',
      'status': 'active',
      'department': 'تقنية المعلومات',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 إدارة الموظفين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddEmployeeDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildEmployeeStats(),
            const SizedBox(height: 20),
            _buildEmployeesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildStatItem('إجمالي الموظفين', '${_employees.length}', Icons.people),
          const SizedBox(width: 20),
          _buildStatItem('متوسط الأداء', '92%', Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _employees.length,
      itemBuilder: (context, index) {
        final employee = _employees[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(employee['avatar']),
            ),
            title: Text(
              employee['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee['position']),
                Text('${employee['branch']} • الأداء: ${employee['performance']}%'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Text('عرض التفاصيل'),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('تعديل'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('حذف'),
                ),
              ],
            ),
            onTap: () => _showEmployeeDetails(employee),
          ),
        );
      },
    );
  }

  void _showEmployeeDetails(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(employee['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المنصب: ${employee['position']}'),
            Text('الفرع: ${employee['branch']}'),
            Text('الهاتف: ${employee['phone']}'),
            Text('البريد: ${employee['email']}'),
            Text('الراتب: ${employee['salary']} ج.م'),
            Text('تاريخ التوظيف: ${employee['hireDate']}'),
            Text('الأداء: ${employee['performance']}%'),
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

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة موظف جديد'),
        content: const Text('سيتم إضافة نموذج إضافة موظف هنا'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
} 