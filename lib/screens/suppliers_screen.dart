import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/supplier.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/empty_states.dart';
import '../providers/suppliers_provider.dart';
import '../providers/user_provider.dart';
import '../services/feature_manager_service.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Supplier> get _filteredSuppliers {
    final suppliersNotifier = ref.read(suppliersProvider.notifier);
    return suppliersNotifier.searchSuppliers(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(suppliersProvider);
    final suppliersStats = ref.watch(suppliersStatsProvider);
    final filteredSuppliers = _filteredSuppliers;
    
    final totalSuppliers = suppliersStats['totalSuppliers'] ?? 0;
    final netBalance = suppliersStats['netBalance'] ?? 0.0;
    final debtorSuppliers = suppliersStats['debtorSuppliers'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            AppTheme.iconContainer(
              icon: Icons.business_rounded,
              color: Colors.white,
              size: 24,
              containerSize: 40,
            ),
            const SizedBox(width: 12),
            const Text('إدارة الموردين'),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: ElevatedButton.icon(
              onPressed: () => _handleAddSupplier(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('إضافة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث والإحصائيات
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // شريط البحث
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                hintText: 'البحث بالاسم أو الهاتف أو البريد الإلكتروني...',
                    prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 16),
                
                // إحصائيات سريعة
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'إجمالي الموردين',
                        totalSuppliers.toString(),
                        Icons.business_rounded,
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'صافي الرصيد',
                        '${netBalance.toStringAsFixed(2)} جنيه',
                        Icons.account_balance_wallet_rounded,
                        netBalance >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'موردين مدينين',
                        debtorSuppliers.toString(),
                        Icons.warning_rounded,
                        AppTheme.warningColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // بطاقة الموردين المتبقين
                _buildLimitStatCard(suppliers.length),
              ],
            ),
          ),
          
          // قائمة الموردين
          Expanded(
            child: filteredSuppliers.isEmpty
                    ? (_searchQuery.isNotEmpty 
                        ? EmptyStates.search(context, _searchQuery)
                        : EmptyStates.suppliers(context, onAddPressed: () => _showSupplierDialog())
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                    itemCount: filteredSuppliers.length,
                        itemBuilder: (context, index) {
                      final supplier = filteredSuppliers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildSupplierCard(supplier),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.cardDecoration(color: Colors.white),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(Supplier supplier) {
    return Container(
      decoration: AppTheme.cardDecoration(color: Colors.white),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showSupplierDetails(supplier),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الصف الأول: الاسم والأزرار
                Row(
                  children: [
                    // أيقونة المورد
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.business_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // معلومات المورد
                    Expanded(
                      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                          Text(
                            supplier.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
            if (supplier.contactPerson != null)
                            Text(
                              'جهة الاتصال: ${supplier.contactPerson}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
                    ),
                    
                    // أزرار الإجراءات
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade600),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                              Icon(Icons.edit_rounded, color: AppTheme.primaryColor),
                  SizedBox(width: 8),
                  Text('تعديل'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                              Icon(Icons.delete_rounded, color: AppTheme.errorColor),
                  SizedBox(width: 8),
                              Text('حذف', style: TextStyle(color: AppTheme.errorColor)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showSupplierDialog(supplier: supplier);
            } else if (value == 'delete') {
              _deleteSupplier(supplier);
            }
          },
        ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // معلومات الاتصال
                Row(
                  children: [
                    if (supplier.phone != null) ...[
                      Icon(Icons.phone_rounded, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        supplier.phone!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (supplier.email != null) ...[
                      Icon(Icons.email_rounded, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          supplier.email!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // الرصيد والائتمان
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: supplier.currentBalance >= 0 
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'الرصيد الحالي',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: supplier.currentBalance >= 0 
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${supplier.currentBalance.toStringAsFixed(2)} جنيه',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: supplier.currentBalance >= 0 
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (supplier.creditLimit != null)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'حد الائتمان',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${supplier.creditLimit!.toStringAsFixed(2)} جنيه',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),
                  ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSupplierDialog({Supplier? supplier}) {
    showDialog(
      context: context,
      builder: (context) => SupplierDialog(
        supplier: supplier,
        onSave: (savedSupplier) {
          _saveSupplier(savedSupplier);
        },
      ),
    );
  }

  void _showSupplierDetails(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(supplier.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (supplier.contactPerson != null) ...[
                const Text('جهة الاتصال:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(supplier.contactPerson!),
                const SizedBox(height: 8),
              ],
              if (supplier.phone != null) ...[
                const Text('الهاتف:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(supplier.phone!),
                const SizedBox(height: 8),
              ],
              if (supplier.email != null) ...[
                const Text('البريد الإلكتروني:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(supplier.email!),
                const SizedBox(height: 8),
              ],
              if (supplier.address != null) ...[
                const Text('العنوان:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(supplier.address!),
                const SizedBox(height: 8),
              ],
              const Text('الرصيد الحالي:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${supplier.currentBalance.toStringAsFixed(2)} جنيه'),
              const SizedBox(height: 8),
              if (supplier.creditLimit != null) ...[
                const Text('حد الائتمان:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${supplier.creditLimit!.toStringAsFixed(2)} جنيه'),
                const SizedBox(height: 8),
              ],
              if (supplier.paymentTerms != null) ...[
                const Text('شروط الدفع:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(supplier.paymentTerms!),
                const SizedBox(height: 8),
              ],
              if (supplier.notes != null) ...[
                const Text('ملاحظات:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(supplier.notes!),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _saveSupplier(Supplier supplier) {
    try {
      if (supplier.id == null) {
        // إضافة مورد جديد
        ref.read(suppliersProvider.notifier).addSupplier(supplier);
      } else {
        // تحديث مورد موجود
        ref.read(suppliersProvider.notifier).updateSupplier(supplier);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ المورد بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ المورد: $e')),
        );
      }
    }
  }

  Future<void> _deleteSupplier(Supplier supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المورد "${supplier.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        ref.read(suppliersProvider.notifier).deleteSupplier(supplier.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف المورد بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في حذف المورد: $e')),
          );
        }
      }
    }
  }

  Widget _buildLimitStatCard(int currentCount) {
    final userPlan = ref.watch(userPlanProvider);
    final featureManager = ref.read(featureManagerProvider);
    final remaining = FeatureManagerService.getRemainingCount('suppliers', userPlan, currentCount);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(color: Colors.white),
      child: Row(
        children: [
          Icon(
            Icons.business_center_rounded, 
            color: remaining > 0 ? AppTheme.accentColor : AppTheme.errorColor, 
            size: 32
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'موردين متبقيين',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  remaining > 1000 ? 'لا محدود' : '$remaining مورد',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: remaining > 0 ? AppTheme.accentColor : AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (remaining <= 5 && remaining > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'قريب من الحد',
                style: TextStyle(
                  color: AppTheme.warningColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleAddSupplier() {
    final userPlan = ref.read(userPlanProvider);
    final suppliers = ref.read(suppliersProvider);
    final featureManager = ref.read(featureManagerProvider);
    
    // التحقق من الحدود قبل السماح بإضافة مورد
    final canAdd = FeatureManagerService.limitGate(
      context,
      userPlan,
      'suppliers',
      suppliers.length,
    );
    
    if (canAdd) {
      _showSupplierDialog();
    }
  }
}

class SupplierDialog extends StatefulWidget {
  final Supplier? supplier;
  final Function(Supplier) onSave;

  const SupplierDialog({
    super.key,
    this.supplier,
    required this.onSave,
  });

  @override
  State<SupplierDialog> createState() => _SupplierDialogState();
}

class _SupplierDialogState extends State<SupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactPersonController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  late TextEditingController _paymentTermsController;
  late TextEditingController _creditLimitController;
  late TextEditingController _currentBalanceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _contactPersonController = TextEditingController(text: widget.supplier?.contactPerson ?? '');
    _phoneController = TextEditingController(text: widget.supplier?.phone ?? '');
    _emailController = TextEditingController(text: widget.supplier?.email ?? '');
    _addressController = TextEditingController(text: widget.supplier?.address ?? '');
    _notesController = TextEditingController(text: widget.supplier?.notes ?? '');
    _paymentTermsController = TextEditingController(text: widget.supplier?.paymentTerms ?? '');
    _creditLimitController = TextEditingController(
      text: widget.supplier?.creditLimit?.toString() ?? '',
    );
    _currentBalanceController = TextEditingController(
      text: widget.supplier?.currentBalance.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _paymentTermsController.dispose();
    _creditLimitController.dispose();
    _currentBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.supplier == null ? 'إضافة مورد جديد' : 'تعديل المورد'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المورد *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم المورد';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _contactPersonController,
                  decoration: const InputDecoration(
                    labelText: 'جهة الاتصال',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'العنوان',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _creditLimitController,
                        decoration: const InputDecoration(
                          labelText: 'حد الائتمان',
                          border: OutlineInputBorder(),
                          suffixText: 'جنيه',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'رقم غير صحيح';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _currentBalanceController,
                        decoration: const InputDecoration(
                          labelText: 'الرصيد الحالي *',
                          border: OutlineInputBorder(),
                          suffixText: 'جنيه',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'مطلوب';
                          }
                          if (double.tryParse(value) == null) {
                            return 'رقم غير صحيح';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _paymentTermsController,
                  decoration: const InputDecoration(
                    labelText: 'شروط الدفع',
                    border: OutlineInputBorder(),
                    hintText: 'مثال: 30 يوم',
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveSupplier,
          child: const Text('حفظ'),
        ),
      ],
    );
  }

  void _saveSupplier() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final supplier = Supplier(
        id: widget.supplier?.id,
        name: _nameController.text,
        contactPerson: _contactPersonController.text.isEmpty ? null : _contactPersonController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        paymentTerms: _paymentTermsController.text.isEmpty ? null : _paymentTermsController.text,
        creditLimit: _creditLimitController.text.isEmpty ? null : double.parse(_creditLimitController.text),
        currentBalance: double.parse(_currentBalanceController.text),
        createdAt: widget.supplier?.createdAt ?? now,
        updatedAt: now,
        userId: 'dummy-user', // مؤقتاً حتى ننشئ auth system
      );
      
      widget.onSave(supplier);
      Navigator.of(context).pop();
    }
  }
}

