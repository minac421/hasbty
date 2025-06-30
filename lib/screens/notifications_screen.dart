import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../services/notification_service.dart';
import '../services/smart_notifications_service.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _dailyReminders = true;
  bool _limitAlerts = true;
  bool _billReminders = true;
  bool _smartSuggestions = true;
  
  // محاكاة بيانات الإشعارات
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'reminder',
      'title': '⏰ تذكير يومي',
      'message': 'لم تسجل أي معاملة اليوم. سجل مصروفاتك لتتبع أفضل!',
      'time': 'منذ ساعة',
      'isRead': false,
      'color': Colors.blue,
      'icon': Icons.event_note,
    },
    {
      'id': '2',
      'type': 'limit',
      'title': '⚠️ تنبيه حد الاستخدام',
      'message': 'باقي 3 عمليات OCR فقط هذا الشهر. احصل على باقة لا محدودة!',
      'time': 'منذ ساعتين',
      'isRead': false,
      'color': Colors.orange,
      'icon': Icons.warning_rounded,
    },
    {
      'id': '3',
      'type': 'bill',
      'title': '💡 فاتورة مستحقة',
      'message': 'فاتورة الكهرباء تستحق الدفع خلال 3 أيام - 450 جنيه',
      'time': 'منذ 4 ساعات',
      'isRead': true,
      'color': Colors.red,
      'icon': Icons.receipt_long,
    },
    {
      'id': '4',
      'type': 'smart',
      'title': '🤖 اقتراح ذكي',
      'message': 'مصروفات الطعام عالية هذا الشهر. يمكنك توفير 300 جنيه بطبخ المنزل!',
      'time': 'أمس',
      'isRead': true,
      'color': Colors.green,
      'icon': Icons.lightbulb_outline,
    },
    {
      'id': '5',
      'type': 'achievement',
      'title': '🏆 إنجاز جديد',
      'message': 'مبروك! حققت هدف التوفير لهذا الشهر (500 جنيه)',
      'time': 'منذ يومين',
      'isRead': true,
      'color': Colors.purple,
      'icon': Icons.emoji_events,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
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
        title: const Text('🔔 الإشعارات والتنبيهات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAllNotifications,
            tooltip: 'مسح الكل',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickStats(),
              const SizedBox(height: 20),
              _buildRecentNotifications(),
              const SizedBox(height: 20),
              _buildNotificationTypes(),
              const SizedBox(height: 20),
              _buildScheduleSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _testNotifications,
        icon: const Icon(Icons.notifications_active),
        label: const Text('تجربة الإشعارات'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildQuickStats() {
    final unreadCount = _notifications.where((n) => !n['isRead']).length;
    final todayCount = _notifications.where((n) => 
        n['time'].contains('ساعة') || n['time'].contains('ساعتين')).length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withOpacity(0.1), AppTheme.primaryColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.notifications_active,
            label: 'غير مقروءة',
            value: '$unreadCount',
            color: Colors.red,
          ),
          const SizedBox(width: 20),
          _buildStatItem(
            icon: Icons.today,
            label: 'اليوم',
            value: '$todayCount',
            color: Colors.blue,
          ),
          const SizedBox(width: 20),
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'مقروءة',
            value: '${_notifications.length - unreadCount}',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentNotifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الإشعارات الحديثة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _markAllAsRead(),
              child: const Text('تحديد الكل كمقروء'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            return _buildNotificationCard(notification, index);
          },
        ),
      ],
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isRead = notification['isRead'] as bool;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _markAsRead(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isRead ? Theme.of(context).cardColor : notification['color'].withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isRead ? AppTheme.borderColor : notification['color'].withOpacity(0.3),
              ),
              boxShadow: isRead ? [] : [
                BoxShadow(
                  color: notification['color'].withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: notification['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    notification['icon'],
                    color: notification['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isRead ? Colors.grey[600] : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['message'],
                        style: TextStyle(
                          fontSize: 14,
                          color: isRead ? Colors.grey[500] : Colors.grey[700],
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (!isRead)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: notification['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أنواع التنبيهات',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildNotificationTypeCard(
          icon: Icons.event_note,
          title: 'التذكيرات اليومية',
          subtitle: 'تذكير بتسجيل المعاملات اليومية (8:00 صباحاً)',
          isEnabled: _dailyReminders,
          onChanged: (value) => setState(() => _dailyReminders = value),
          color: Colors.blue,
        ),
        
        _buildNotificationTypeCard(
          icon: Icons.warning_rounded,
          title: 'تنبيهات الحدود',
          subtitle: 'تنبيه عند قرب انتهاء حد العمليات المجانية (90%)',
          isEnabled: _limitAlerts,
          onChanged: (value) => setState(() => _limitAlerts = value),
          color: Colors.orange,
        ),
        
        _buildNotificationTypeCard(
          icon: Icons.receipt_long,
          title: 'تذكيرات الفواتير',
          subtitle: 'تنبيه عند استحقاق الفواتير (قبل 3 أيام)',
          isEnabled: _billReminders,
          onChanged: (value) => setState(() => _billReminders = value),
          color: Colors.red,
        ),
        
        _buildNotificationTypeCard(
          icon: Icons.lightbulb_outline,
          title: 'الاقتراحات الذكية',
          subtitle: 'نصائح توفير وتحسين العادات المالية',
          isEnabled: _smartSuggestions,
          onChanged: (value) => setState(() => _smartSuggestions = value),
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildNotificationTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'جدولة التذكيرات',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.withOpacity(0.1), Colors.purple.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              _buildScheduleItem(
                icon: Icons.access_time,
                title: 'التذكير اليومي',
                subtitle: 'كل يوم في 8:00 صباحاً',
                color: Colors.blue,
              ),
              const Divider(height: 24),
              _buildScheduleItem(
                icon: Icons.calendar_month,
                title: 'تذكير أسبوعي',
                subtitle: 'كل يوم أحد في 6:00 مساءً',
                color: Colors.green,
              ),
              const Divider(height: 24),
              _buildScheduleItem(
                icon: Icons.event_available,
                title: 'تذكير شهري',
                subtitle: 'أول كل شهر في 9:00 صباحاً',
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
        Icon(Icons.chevron_right, color: Colors.grey[400]),
      ],
    );
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح جميع الإشعارات'),
        content: const Text('هل أنت متأكد من حذف جميع الإشعارات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _testNotifications() async {
    await SmartNotificationsService.simulateSmartNotifications();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 تم إرسال إشعارات تجريبية! تحقق من شريط الإشعارات'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
} 