import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // معلق مؤقتاً
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // final SupabaseClient supabase = Supabase.instance.client; // معلق مؤقتاً
  
  String _selectedLanguage = 'العربية';
  String _selectedUserType = 'business_owner'; // افتراضياً برو عشان نجرب كل المميزات
  String _selectedBusinessType = 'محل';
  String _selectedReportStyle = 'افتراضي';
  bool _enableNotifications = true;
  bool _enableAutoBackup = true;
  bool _enableOfflineMode = true;

  final List<String> languages = ['العربية', 'English'];

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _selectedLanguage = prefs.getString('language') ?? 'العربية';
        _selectedUserType = prefs.getString('user_type') ?? 'business_owner'; // افتراضياً برو
        _selectedBusinessType = prefs.getString('business_type') ?? 'محل';
        _selectedReportStyle = prefs.getString('report_style') ?? 'افتراضي';
        _enableNotifications = prefs.getBool('enable_notifications') ?? true;
        _enableAutoBackup = prefs.getBool('enable_auto_backup') ?? true;
        _enableOfflineMode = prefs.getBool('enable_offline_mode') ?? true;
      });
    } catch (error) {
      debugPrint('Error loading user settings: $error');
    }
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الإعدادات بنجاح'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
      
      // إعادة تحميل التطبيق في حالة تغيير نوع المستخدم
      if (key == 'user_type') {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (error) {
      debugPrint('Error updating setting: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث الإعدادات: $error'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟\n\nملاحظة: في النسخة التجريبية ستعود للشاشة الرئيسية'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // معلق مؤقتاً: await supabase.auth.signOut();
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تسجيل الخروج - يمكنك الآن إعادة تشغيل التطبيق'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          // في النسخة التجريبية، العودة للـ dashboard بدلاً من login
          Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
        }
      } catch (error) {
        debugPrint('Error logging out: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في تسجيل الخروج: $error'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
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
          'الإعدادات',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // الحساب الشخصي
              _buildAccountSection(),
            const SizedBox(height: 24),
            
              // إعدادات التطبيق
              _buildAppSettingsSection(),
            const SizedBox(height: 24),
            
              // الدعم والمساعدة
            _buildSupportSection(),
            const SizedBox(height: 24),
            
              // تسجيل الخروج
              _buildLogoutSection(),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
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
            'الحساب الشخصي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          // صورة الملف الشخصي والاسم
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'محمد أحمد',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'mohamed@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
            ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _editProfile(),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // باقة المستخدم
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'باقة مجانية',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                      ),
                      ),
                      Text(
                        'OCR: 2/50 | Voice: 1/50',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/subscriptions'),
                  child: const Text('ترقية'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection() {
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
            'إعدادات التطبيق',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          // اللغة
          _buildSettingItem(
            icon: Icons.language,
            iconColor: Colors.blue,
            title: 'اللغة',
            subtitle: _selectedLanguage,
            onTap: () => _showLanguageDialog(),
          ),
          const SizedBox(height: 16),
          
          // مظهر التطبيق (مُزال - موجود في الدشبورد)
          // _buildThemeToggleItem(),
          // const SizedBox(height: 16),
          
          // الإشعارات
          _buildSettingItem(
            icon: Icons.notifications,
            iconColor: Colors.orange,
            title: 'الإشعارات',
            subtitle: _enableNotifications ? 'مُفعّلة' : 'غير مُفعّلة',
            trailing: Switch(
            value: _enableNotifications,
            onChanged: (value) {
                setState(() {
                  _enableNotifications = value;
                });
              _updateSetting('enable_notifications', value);
            },
              activeColor: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          
          // الخصوصية
          _buildSettingItem(
            icon: Icons.privacy_tip,
            iconColor: Colors.purple,
            title: 'الخصوصية والأمان',
            subtitle: 'إدارة خصوصية البيانات',
            onTap: () => _showPrivacyInfo(),
          ),
          const SizedBox(height: 16),
          
          // النسخ الاحتياطي
          _buildSettingItem(
            icon: Icons.backup,
            iconColor: Colors.teal,
            title: 'النسخ الاحتياطي',
            subtitle: 'حفظ واستعادة البيانات',
            onTap: () => _showBackupOptions(),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
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
            'الدعم والمساعدة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          // دعم فني (WhatsApp)
          _buildSettingItem(
            icon: Icons.chat,
            iconColor: Colors.green,
            title: 'دعم فني',
            subtitle: 'تواصل معنا عبر WhatsApp',
            onTap: () => _contactSupport(),
          ),
          const SizedBox(height: 16),
          
          // الأسئلة الشائعة
          _buildSettingItem(
            icon: Icons.help_outline,
            iconColor: Colors.blue,
            title: 'الأسئلة الشائعة',
            subtitle: 'إجابات على الأسئلة المتكررة',
            onTap: () => _showFAQ(),
          ),
          const SizedBox(height: 16),
          
          // تقييم التطبيق
          _buildSettingItem(
            icon: Icons.star_outline,
            iconColor: Colors.amber,
            title: 'تقييم التطبيق',
            subtitle: 'قيّم تجربتك معنا',
            onTap: () => _rateApp(),
          ),
          const SizedBox(height: 16),
          
          // عن التطبيق
          _buildSettingItem(
            icon: Icons.info_outline,
            iconColor: Colors.grey,
            title: 'عن جردلي',
            subtitle: 'الإصدار 2.1.0',
            onTap: () => _showAboutApp(),
          ),
        ],
      ),
    );
  }

  // Theme Toggle Widget المتطور
  Widget _buildThemeToggleItem() {
    final themeInfo = ref.watch(themeInfoProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeInfo['isDark'] 
              ? [const Color(0xFF1A1A1A), const Color(0xFF2A2A2A)]
              : [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeInfo['isDark'] 
              ? const Color(0xFF444444)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة الثيم مع تدرج جميل
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeInfo['isDark']
                    ? [const Color(0xFF4FC3F7), const Color(0xFF29B6F6)]
                    : [const Color(0xFF0087B8), const Color(0xFF4FB6E3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
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
            child: Icon(
              themeInfo['icon'],
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // معلومات الثيم
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مظهر التطبيق',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeInfo['isDark'] ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  themeInfo['name'],
                  style: TextStyle(
                    fontSize: 14,
                    color: themeInfo['isDark'] 
                        ? Colors.grey[400] 
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // أزرار التبديل الثلاثة مع تأثيرات جميلة
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeButton(
                icon: Icons.light_mode,
                isSelected: themeInfo['isLight'],
                onTap: () => themeNotifier.setLightMode(),
                tooltip: 'الوضع الفاتح',
                isDarkMode: themeInfo['isDark'],
              ),
              const SizedBox(width: 8),
              _buildThemeButton(
                icon: Icons.dark_mode,
                isSelected: themeNotifier.isDarkMode,
                onTap: () => themeNotifier.setDarkMode(),
                tooltip: 'الوضع المظلم',
                isDarkMode: themeInfo['isDark'],
              ),
              const SizedBox(width: 8),
              _buildThemeButton(
                icon: Icons.brightness_auto,
                isSelected: themeInfo['isSystem'],
                onTap: () => themeNotifier.setSystemMode(),
                tooltip: 'وضع النظام',
                isDarkMode: themeInfo['isDark'],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required String tooltip,
    required bool isDarkMode,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDarkMode ? const Color(0xFF4FC3F7) : const Color(0xFF0087B8))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? (isDarkMode ? const Color(0xFF4FC3F7) : const Color(0xFF0087B8))
                    : (isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isSelected
                  ? (isDarkMode ? Colors.black : Colors.white)
                  : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showLogoutDialog(),
        borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.red,
                size: 24,
              ),
            ),
              const SizedBox(width: 16),
            const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                    'تسجيل الخروج',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      ),
                    ),
                    Text(
                    'الخروج من الحساب الحالي',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.red,
              size: 16,
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          trailing ?? 
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 16,
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الملف الشخصي'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                hintText: 'محمد أحمد',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                hintText: 'mohamed@example.com',
              ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ التغييرات'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                _updateSetting('language', value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
            ),
    );
  }

  void _showPrivacyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الخصوصية والأمان'),
        content: const Text(
          'نحن نحترم خصوصيتك ونحمي بياناتك الشخصية. '
          'جميع المعلومات محفوظة بأمان ولا نشاركها مع أطراف ثالثة.'
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showBackupOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('النسخ الاحتياطي'),
        content: const Text(
          'هل تريد إنشاء نسخة احتياطية من بياناتك؟\n\n'
          'سيتم حفظ جميع المصروفات والإعدادات.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إنشاء النسخة الاحتياطية'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('نسخ احتياطي'),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.chat, color: Colors.green),
            SizedBox(width: 8),
            Text('دعم فني'),
          ],
        ),
        content: const Text(
          'سيتم فتح محادثة WhatsApp مع فريق الدعم الفني.\n\n'
          'يمكنك طرح أي استفسار أو مشكلة تواجهك.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // فتح WhatsApp - سيتم التطبيق لاحقاً
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('جاري فتح WhatsApp...'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('فتح WhatsApp'),
          ),
        ],
      ),
    );
  }

  void _showFAQ() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('الأسئلة الشائعة')),
          body: const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'كيف أستخدم المسح الضوئي؟',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('اضغط على أيقونة الكاميرا وصوّر الفاتورة بوضوح.'),
                SizedBox(height: 20),
                Text(
                  'ما هي حدود الاستخدام؟',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('الباقة المجانية تسمح بـ 50 مسح ضوئي و 50 أمر صوتي شهرياً.'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _rateApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تقييم التطبيق'),
        content: const Text('هل أعجبك التطبيق؟ قيّمنا في المتجر!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // فتح المتجر - سيتم التطبيق لاحقاً
            },
            child: const Text('تقييم'),
          ),
        ],
      ),
    );
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عن جردلي'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الإصدار: 2.1.0'),
            SizedBox(height: 8),
            Text('تطبيق محاسبة ذكي لإدارة مصروفاتك بسهولة'),
            SizedBox(height: 8),
            Text('© 2024 جردلي - جميع الحقوق محفوظة'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('تسجيل الخروج'),
          ],
        ),
        content: const Text('هل تريد حقاً تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // مسح بيانات تسجيل الدخول
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              
              // العودة لشاشة تسجيل الدخول
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}


