import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_plan.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';

class UserTypeSelectionScreen extends ConsumerStatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  ConsumerState<UserTypeSelectionScreen> createState() => _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends ConsumerState<UserTypeSelectionScreen> {
  UserType? _selectedUserType;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                           MediaQuery.of(context).padding.top - 
                           MediaQuery.of(context).padding.bottom - 48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // شعار التطبيق
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: AppTheme.gradientDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // العنوان الرئيسي
                  Text(
                    'جردلي',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // السؤال
                  Text(
                    'كيف تريد استخدام جردلي؟',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'اختر الفئة المناسبة لك',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // 3 بطاقات الاختيار
                  _buildUserTypeCard(
                    userType: UserType.individual,
                    title: 'فرد عادي',
                    subtitle: 'لتتبع المصروفات الشخصية',
                    icon: Icons.person_rounded,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildUserTypeCard(
                    userType: UserType.smallBusiness,
                    title: 'شركة صغيرة/متوسطة',
                    subtitle: 'للمحلات والمشاريع الصغيرة',
                    icon: Icons.storefront_rounded,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildUserTypeCard(
                    userType: UserType.enterprise,
                    title: 'شركة كبيرة',
                    subtitle: 'للمؤسسات والشركات الكبيرة',
                    icon: Icons.business_rounded,
                    color: Colors.purple,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // زر المتابعة
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _selectedUserType != null && !_isLoading 
                          ? _continueWithSelectedType 
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedUserType != null 
                            ? colorScheme.primary 
                            : colorScheme.outline,
                        foregroundColor: Colors.white,
                        elevation: _selectedUserType != null ? 3 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'متابعة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard({
    required UserType userType,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedUserType == userType;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectUserType(userType),
        borderRadius: BorderRadius.circular(16),
        child:         AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              // الأيقونة
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(isSelected ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              
              // النصوص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // علامة الاختيار
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? color : colorScheme.outline,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectUserType(UserType userType) {
    setState(() {
      _selectedUserType = userType;
    });
  }

  Future<void> _continueWithSelectedType() async {
    if (_selectedUserType == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // حفظ نوع المستخدم
      await ref.read(userProvider.notifier).selectUserType(_selectedUserType!);
      
      if (mounted) {
        // الانتقال لوحة التحكم المناسبة
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}


