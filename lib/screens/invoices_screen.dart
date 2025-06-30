import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/invoice.dart';
import '../providers/invoices_provider.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> salesInvoices = [
    {
      'id': 'INV-001',
      'customerName': 'أحمد محمد علي',
      'date': '2024-01-15',
      'total': 1500.0,
      'status': 'مدفوعة',
      'items': [
        {'name': 'لابتوب Dell', 'quantity': 1, 'price': 1200.0},
        {'name': 'ماوس لاسلكي', 'quantity': 1, 'price': 300.0},
      ],
    },
    {
      'id': 'INV-002',
      'customerName': 'سارة أحمد حسن',
      'date': '2024-01-14',
      'total': 850.0,
      'status': 'معلقة',
      'items': [
        {'name': 'تيشيرت قطني', 'quantity': 3, 'price': 150.0},
        {'name': 'بنطلون جينز', 'quantity': 2, 'price': 200.0},
      ],
    },
    {
      'id': 'INV-003',
      'customerName': 'محمد عبد الرحمن',
      'date': '2024-01-13',
      'total': 2200.0,
      'status': 'مدفوعة',
      'items': [
        {'name': 'رز بسمتي 5 كيلو', 'quantity': 10, 'price': 80.0},
        {'name': 'زيت طبخ', 'quantity': 6, 'price': 50.0},
      ],
    },
  ];

  final List<Map<String, dynamic>> purchaseInvoices = [
    {
      'id': 'PUR-001',
      'supplierName': 'شركة الأهرام للإلكترونيات',
      'date': '2024-01-12',
      'total': 25000.0,
      'status': 'مدفوعة',
      'items': [
        {'name': 'لابتوب Dell XPS', 'quantity': 20, 'price': 1000.0},
        {'name': 'ماوس لاسلكي', 'quantity': 50, 'price': 100.0},
      ],
    },
    {
      'id': 'PUR-002',
      'supplierName': 'مصنع النسيج الحديث',
      'date': '2024-01-11',
      'total': 8500.0,
      'status': 'معلقة',
      'items': [
        {'name': 'تيشيرت قطني', 'quantity': 100, 'price': 50.0},
        {'name': 'بنطلون جينز', 'quantity': 50, 'price': 70.0},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'الفواتير',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showCreateInvoiceDialog(),
            icon: const Icon(
              Icons.add,
              color: Colors.green,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          tabs: const [
            Tab(
              icon: Icon(Icons.sell),
              text: 'فواتير المبيعات',
            ),
            Tab(
              icon: Icon(Icons.shopping_cart),
              text: 'فواتير المشتريات',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSalesTab(),
          _buildPurchasesTab(),
        ],
      ),
    );
  }

  Widget _buildSalesTab() {
    return Column(
              children: [
        // إحصائيات المبيعات
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                  'إجمالي المبيعات',
                  '${salesInvoices.fold(0.0, (sum, invoice) => sum + invoice['total']).toStringAsFixed(0)} جنيه',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                  'عدد الفواتير',
                  salesInvoices.length.toString(),
                  Icons.receipt,
                  Colors.blue,
                      ),
                    ),
                  ],
                ),
        ),
        
        // قائمة فواتير المبيعات
        Expanded(
          child: salesInvoices.isEmpty
              ? _buildEmptyState('لا توجد فواتير مبيعات', 'ابدأ بإنشاء فاتورة مبيعات جديدة')
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: salesInvoices.length,
                  itemBuilder: (context, index) {
                    final invoice = salesInvoices[index];
                    return _buildInvoiceCard(invoice, true);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPurchasesTab() {
    return Column(
      children: [
        // إحصائيات المشتريات
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Row(
                children: [
                    Expanded(
                child: _buildStatCard(
                  'إجمالي المشتريات',
                  '${purchaseInvoices.fold(0.0, (sum, invoice) => sum + invoice['total']).toStringAsFixed(0)} جنيه',
                  Icons.trending_down,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'عدد الفواتير',
                  purchaseInvoices.length.toString(),
                  Icons.receipt,
                  Colors.blue,
                ),
                ),
              ],
            ),
          ),
          
        // قائمة فواتير المشتريات
          Expanded(
          child: purchaseInvoices.isEmpty
              ? _buildEmptyState('لا توجد فواتير مشتريات', 'ابدأ بإنشاء فاتورة مشتريات جديدة')
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: purchaseInvoices.length,
                  itemBuilder: (context, index) {
                    final invoice = purchaseInvoices[index];
                    return _buildInvoiceCard(invoice, false);
                  },
                  ),
          ),
        ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice, bool isSales) {
    final isPaid = invoice['status'] == 'مدفوعة';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
          // رأس الفاتورة
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                  color: (isSales ? Colors.green : Colors.orange).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                child: Icon(
                  isSales ? Icons.sell : Icons.shopping_cart,
                  color: isSales ? Colors.green : Colors.orange,
                  size: 20,
                ),
                    ),
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                          Text(
                      invoice['id'],
                      style: const TextStyle(
                        fontSize: 16,
                              fontWeight: FontWeight.bold,
                        color: Colors.black87,
                            ),
                          ),
                    const SizedBox(height: 2),
                          Text(
                      isSales ? invoice['customerName'] : invoice['supplierName'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                            ),
                              ),
                          ],
                        ),
                    ),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                  color: isPaid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  invoice['status'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isPaid ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // تفاصيل الفاتورة
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التاريخ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                          Text(
                      invoice['date'],
                      style: const TextStyle(
                        fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                    Text(
                      'عدد الأصناف',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${invoice['items'].length} صنف',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                    Text(
                      'المجموع',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                      Text(
                      '${invoice['total'].toStringAsFixed(0)} جنيه',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSales ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
                
          // أزرار الإجراءات
                    Row(
                  children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showInvoiceDetails(invoice, isSales),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('عرض'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportToPDF(invoice),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
                      children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
                        Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
                        Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateInvoiceDialog(),
            icon: const Icon(Icons.add),
            label: const Text('إنشاء فاتورة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
    );
  }

  void _showCreateInvoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنشاء فاتورة جديدة'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختر نوع الفاتورة:'),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.sell, color: Colors.green),
              title: Text('فاتورة مبيعات'),
              subtitle: Text('بيع للعملاء'),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart, color: Colors.orange),
              title: Text('فاتورة مشتريات'),
              subtitle: Text('شراء من الموردين'),
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
              _showInvoiceFormDialog(true); // مبيعات
            },
            child: const Text('مبيعات'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showInvoiceFormDialog(false); // مشتريات
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('مشتريات'),
          ),
        ],
      ),
    );
  }

  void _showInvoiceFormDialog(bool isSales) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس النموذج
              Row(
                      children: [
                  Icon(
                    isSales ? Icons.sell : Icons.shopping_cart,
                    color: isSales ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                        Text(
                    isSales ? 'فاتورة مبيعات جديدة' : 'فاتورة مشتريات جديدة',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // اختيار العميل/المورد
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: isSales ? 'العميل' : 'المورد',
                          border: const OutlineInputBorder(),
                        ),
                        items: (isSales ? ['أحمد محمد علي', 'سارة أحمد حسن'] : ['شركة الأهرام', 'مصنع النسيج'])
                            .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                            .toList(),
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 16),
                      
                      // تاريخ الفاتورة
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'تاريخ الفاتورة',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        initialValue: DateTime.now().toIso8601String().split('T')[0],
                      ),
                      const SizedBox(height: 20),
                      
                      // أصناف الفاتورة
                      const Text(
                        'أصناف الفاتورة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Expanded(child: Text('الصنف')),
                                const SizedBox(width: 60, child: Text('الكمية')),
                                const SizedBox(width: 80, child: Text('السعر')),
                                const SizedBox(width: 80, child: Text('المجموع')),
                              ],
                            ),
                            const Divider(),
                            
                            // صف واحد كمثال
                            Row(
                              children: [
                                const Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'اختر صنف',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const SizedBox(
                                  width: 60,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: '1',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const SizedBox(
                                  width: 80,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: '0.00',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                        Container(
                                  width: 80,
                                  padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('0.00', textAlign: TextAlign.center),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add),
                              label: const Text('إضافة صنف'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // الخصومات والضريبة
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'خصم (%)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'ضريبة (%)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // إجمالي الفاتورة
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (isSales ? Colors.green : Colors.orange).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'الإجمالي النهائي:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '0.00 جنيه',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSales ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // أزرار الحفظ والإلغاء
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم حفظ الفاتورة بنجاح'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSales ? Colors.green : Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('حفظ الفاتورة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInvoiceDetails(Map<String, dynamic> invoice, bool isSales) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الفاتورة ${invoice['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${isSales ? 'العميل' : 'المورد'}: ${isSales ? invoice['customerName'] : invoice['supplierName']}'),
              const SizedBox(height: 8),
              Text('التاريخ: ${invoice['date']}'),
              const SizedBox(height: 8),
              Text('الحالة: ${invoice['status']}'),
              const SizedBox(height: 16),
              
              const Text('الأصناف:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              ...invoice['items'].map<Widget>((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• ${item['name']} - ${item['quantity']} × ${item['price']} جنيه'),
              )).toList(),
              
              const SizedBox(height: 16),
              Text(
                'المجموع: ${invoice['total']} جنيه',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
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

  void _exportToPDF(Map<String, dynamic> invoice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري تصدير الفاتورة ${invoice['id']} إلى PDF...'),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'تم',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
