import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  int _currentPoints = 245;
  int _dailyStreak = 7;
  
  // قائمة الإعلانات المتاحة
  final List<Map<String, dynamic>> availableAds = [
    {
      'title': 'شاهد إعلان عن تطبيق التوصيل',
      'reward': '+10 OCR',
      'duration': '30 ثانية',
      'icon': '🚗',
      'color': Colors.blue,
    },
    {
      'title': 'إعلان متجر الملابس الجديد',
      'reward': '+5 Voice',
      'duration': '15 ثانية',
      'icon': '👕',
      'color': Colors.purple,
    },
    {
      'title': 'عرض خاص على الطعام',
      'reward': '+15 OCR',
      'duration': '45 ثانية',
      'icon': '🍕',
      'color': Colors.orange,
    },
    {
      'title': 'إعلان بنك ABC للقروض',
      'reward': '+8 Voice',
      'duration': '30 ثانية',
      'icon': '🏦',
      'color': Colors.green,
    },
  ];

  // سجل المكافآت المكتسبة
  final List<Map<String, dynamic>> earnedRewards = [
    {
      'type': 'OCR',
      'amount': 10,
      'source': 'مشاهدة إعلان',
      'time': '14:30',
      'date': 'اليوم',
    },
    {
      'type': 'Voice',
      'amount': 5,
      'source': 'مشاهدة إعلان',
      'time': '12:15',
      'date': 'اليوم',
    },
    {
      'type': 'OCR',
      'amount': 15,
      'source': 'مشاهدة إعلان',
      'time': '10:45',
      'date': 'أمس',
    },
    {
      'type': 'Voice',
      'amount': 8,
      'source': 'مشاهدة إعلان',
      'time': '16:20',
      'date': 'أمس',
    },
  ];

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
          'الإعلانات والمكافآت',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // شريط التبويبات
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'إعلانات متاحة'),
                  Tab(text: 'المكافآت المكتسبة'),
                ],
              ),
            ),
            
            // محتوى التبويبات
            Expanded(
              child: TabBarView(
                children: [
                  _buildAvailableAdsTab(),
                  _buildEarnedRewardsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableAdsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: availableAds.length,
      itemBuilder: (context, index) {
        final ad = availableAds[index];
        return _buildAdCard(ad);
      },
    );
  }

  Widget _buildAdCard(Map<String, dynamic> ad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              // أيقونة الإعلان
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: ad['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    ad['icon'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // تفاصيل الإعلان
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ad['reward'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ad['duration'],
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
            ],
          ),
          const SizedBox(height: 16),
          
          // زر المشاهدة
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _watchAd(ad),
              style: ElevatedButton.styleFrom(
                backgroundColor: ad['color'],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'شاهد',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnedRewardsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: earnedRewards.length,
      itemBuilder: (context, index) {
        final reward = earnedRewards[index];
        return _buildRewardCard(reward);
      },
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> reward) {
    final isOCR = reward['type'] == 'OCR';
    final color = isOCR ? const Color(0xFFf8961e) : const Color(0xFFe63946);
    final icon = isOCR ? '📷' : '🎤';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // أيقونة النوع
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // التفاصيل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '+${reward['amount']} ${reward['type']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${reward['date']} - ${reward['time']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reward['source'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _watchAd(Map<String, dynamic> ad) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(ad['icon']),
            const SizedBox(width: 8),
            const Text('مشاهدة الإعلان'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ad['color']),
            ),
            const SizedBox(height: 16),
            Text('جاري تشغيل الإعلان...'),
            const SizedBox(height: 8),
            Text(
              'المدة: ${ad['duration']}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
    
    // محاكاة مشاهدة الإعلان
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      _showRewardEarned(ad);
    });
  }

  void _showRewardEarned(Map<String, dynamic> ad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
            SizedBox(width: 8),
            Text('تم كسب المكافأة!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🎉',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'لقد حصلت على:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ad['reward'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // إضافة المكافأة لسجل المكافآت
              setState(() {
                earnedRewards.insert(0, {
                  'type': ad['reward'].contains('OCR') ? 'OCR' : 'Voice',
                  'amount': int.parse(ad['reward'].replaceAll(RegExp(r'[^0-9]'), '')),
                  'source': 'مشاهدة إعلان',
                  'time': TimeOfDay.now().format(context),
                  'date': 'الآن',
                });
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('رائع!'),
          ),
        ],
      ),
    );
  }
} 