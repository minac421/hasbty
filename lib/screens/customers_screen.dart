import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/empty_states.dart';
import '../utils/constants.dart';
import '../models/customer.dart';
import '../providers/customers_provider.dart';
import '../providers/user_provider.dart';
import '../services/feature_manager_service.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  // final SupabaseClient supabase = Supabase.instance.client; // معلق مؤقتاً
  String _searchQuery = '';
  bool _isLoading = false;

  List<Customer> _getFilteredCustomers(List<Customer> customers) {
    if (_searchQuery.isEmpty) return customers;
    return ref.read(customersProvider.notifier).searchCustomers(_searchQuery);
  }

  void _addCustomer(String name, String? phone, String? email, String? address) {
    try {
      final customer = Customer(
        userId: 'dummy-user',
        name: name,
        phone: phone,
        email: email,
        address: address,
        balance: 0.0,
        creditLimit: 1000.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      ref.read(customersProvider.notifier).addCustomer(customer);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ العميل بنجاح'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (error) {
      debugPrint('Error adding customer: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إضافة العميل: $error'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _editCustomer(String id, String name, String? phone, String? email, String? address) {
    try {
      final existingCustomer = ref.read(customersProvider.notifier).getCustomerById(id);
      if (existingCustomer != null) {
        final updatedCustomer = existingCustomer.copyWith(
          name: name,
          phone: phone,
          email: email,
          address: address,
          updatedAt: DateTime.now(),
        );
        
        ref.read(customersProvider.notifier).updateCustomer(updatedCustomer);
        
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث العميل بنجاح'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        }
      }
    } catch (error) {
      debugPrint('Error updating customer: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث العميل: $error'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteCustomer(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف العميل "$name"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
    try {
        ref.read(customersProvider.notifier).deleteCustomer(id);
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف العميل بنجاح'),
              backgroundColor: AppTheme.successColor,
            ),
        );
      }
    } catch (error) {
      debugPrint('Error deleting customer: $error');
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في حذف العميل: $error'),
              backgroundColor: AppTheme.errorColor,
            ),
        );
        }
      }
    }
  }

  void _showAddEditCustomerDialog({Customer? customer}) {
    // إذا كان إضافة عميل جديد، نتحقق من الحدود أولاً
    if (customer == null) {
      final userPlan = ref.read(userPlanProvider);
      final customers = ref.read(customersProvider);
      final featureManager = ref.read(featureManagerProvider);
      
      // التحقق من الحدود
      final canAdd = FeatureManagerService.limitGate(
        context,
        userPlan,
        'customers',
        customers.length,
      );
      
      if (!canAdd) return;
    }
    
    final nameController = TextEditingController(text: customer?.name);
    final phoneController = TextEditingController(text: customer?.phone);
    final emailController = TextEditingController(text: customer?.email);
    final addressController = TextEditingController(text: customer?.address);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.cardDecoration(),
            child: Form(
              key: formKey,
              child: Column(
            mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
            children: [
                      AppTheme.iconContainer(
                        icon: customer == null ? Icons.person_add_rounded : Icons.edit_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                        containerSize: 48,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        customer == null ? 'إضافة عميل جديد' : 'تعديل العميل',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
              ),
            ],
          ),
                  const SizedBox(height: 24),
                  
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم العميل *',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال اسم العميل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: Icon(Icons.phone_rounded),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email_rounded),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'بريد إلكتروني غير صحيح';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان',
                      prefixIcon: Icon(Icons.location_on_rounded),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
              onPressed: () {
                            if (formKey.currentState!.validate()) {
                  if (customer == null) {
                    _addCustomer(
                                  nameController.text.trim(),
                                  phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                                  emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                                  addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                    );
                  } else {
                    _editCustomer(
                                  customer.id!,
                                  nameController.text.trim(),
                                  phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                                  emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                                  addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                    );
                  }
                  Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(customer == null ? 'إضافة' : 'تحديث'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider);
    final filteredCustomers = _getFilteredCustomers(customers);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('العملاء'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              // تحديث البيانات
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث البيانات')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // إحصائيات العملاء
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'إجمالي العملاء',
                        customers.length.toString(),
                        Icons.people_rounded,
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLimitStatCard(customers.length),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CommonWidgets.searchBar(
              context: context,
              hintText: 'البحث بالاسم أو الهاتف أو البريد الإلكتروني...',
              onChanged: (query) => setState(() => _searchQuery = query),
                ),
              ],
            ),
          ),
          
          // قائمة العملاء
          Expanded(
            child: filteredCustomers.isEmpty
                    ? (_searchQuery.isNotEmpty 
                        ? EmptyStates.search(context, _searchQuery)
                        : EmptyStates.customers(context, onAddPressed: () => _showAddEditCustomerDialog())
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                    itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: CommonWidgets.customerCard(
                              context: context,
                          name: customer.name,
                          phone: customer.phone ?? 'لا يوجد',
                          balance: customer.balance,
                              onTap: () {
                                // يمكن فتح تفاصيل العميل
                              },
                              actions: [
                            IconButton(
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    color: AppTheme.primaryColor,
                                  ),
                              onPressed: () => _showAddEditCustomerDialog(customer: customer),
                            ),
                            IconButton(
                                  icon: const Icon(
                                    Icons.delete_rounded,
                                    color: AppTheme.errorColor,
                                  ),
                                  onPressed: () => _deleteCustomer(
                                customer.id!,
                                customer.name,
                                  ),
                                ),
                              ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: CommonWidgets.customFAB(
        onPressed: () => _showAddEditCustomerDialog(),
        icon: Icons.person_add_rounded,
        label: 'إضافة عميل',
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(color: Colors.white),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLimitStatCard(int currentCount) {
    final userPlan = ref.watch(userPlanProvider);
    final featureManager = ref.read(featureManagerProvider);
    final remaining = FeatureManagerService.getRemainingCount('customers', userPlan, currentCount);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(color: Colors.white),
      child: Column(
        children: [
          Icon(
            Icons.person_add_rounded, 
            color: remaining > 0 ? AppTheme.accentColor : AppTheme.errorColor, 
            size: 24
          ),
          const SizedBox(height: 8),
          Text(
            remaining > 1000 ? '∞' : remaining.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: remaining > 0 ? AppTheme.accentColor : AppTheme.errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'عملاء متبقيين',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


