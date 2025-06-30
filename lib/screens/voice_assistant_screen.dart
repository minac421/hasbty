import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with TickerProviderStateMixin {
  
  // عدادات الاستخدام
  int voiceUsed = 1;
  int voiceLimit = 50;
  
  // حالة التسجيل
  bool isListening = false;
  
  // الأنيميشن
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // سجل الأوامر السابقة
  final List<Map<String, dynamic>> previousCommands = [
    {
      'command': 'أضف مصروف 150 جنيه طعام',
      'response': 'تم إضافة مصروف طعام بقيمة 150 جنيه',
      'time': '14:30',
      'success': true,
    },
    {
      'command': 'كم أنفقت على المواصلات هذا الشهر؟',
      'response': 'أنفقت 280 جنيه على المواصلات هذا الشهر',
      'time': '12:15',
      'success': true,
    },
    {
      'command': 'أظهر مصروفات الأسبوع الماضي',
      'response': 'مصروفات الأسبوع الماضي: 1,420 جنيه',
      'time': 'أمس',
      'success': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startListening() {
    if (voiceUsed >= voiceLimit) {
      _showLimitReachedDialog();
      return;
    }
    
    setState(() {
      isListening = true;
      voiceUsed++;
    });
    
    _pulseController.repeat(reverse: true);
    
    // محاكاة التسجيل لمدة 3 ثوان
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _stopListening();
        _showResponseDialog();
      }
    });
  }

  void _stopListening() {
    setState(() {
      isListening = false;
    });
    _pulseController.stop();
    _pulseController.reset();
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
          'المساعد الصوتي',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // عداد الاستخدام
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFe63946).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "🎤 ",
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  "$voiceUsed/$voiceLimit",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFe63946),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // الجزء العلوي - زر الميكروفون
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // النص التوضيحي
                    Text(
                      isListening ? 'أستمع إليك...' : 'اضغط للتحدث',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isListening ? 'تحدث الآن' : 'قل ما تريد',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // زر الميكروفون الكبير
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isListening ? _pulseAnimation.value : 1.0,
                          child: GestureDetector(
                            onTap: isListening ? _stopListening : _startListening,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isListening 
                                    ? const Color(0xFFe63946) 
                                    : const Color(0xFFf8961e),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isListening 
                                        ? const Color(0xFFe63946) 
                                        : const Color(0xFFf8961e)).withOpacity(0.4),
                                    blurRadius: isListening ? 30 : 20,
                                    spreadRadius: isListening ? 5 : 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isListening ? Icons.stop : Icons.mic,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // أمثلة على الأوامر
                    if (!isListening) ...[
                      Text(
                        'أمثلة على ما يمكنك قوله:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildExampleCard('أضف مصروف 100 جنيه طعام'),
                      _buildExampleCard('كم أنفقت على الوقود هذا الشهر؟'),
                      _buildExampleCard('أظهر مصروفات الأسبوع الماضي'),
                    ],
                  ],
                ),
              ),
            ),
            
            // الجزء السفلي - سجل الأوامر السابقة
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'الأوامر السابقة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: previousCommands.length,
                        itemBuilder: (context, index) {
                          final command = previousCommands[index];
                          return _buildCommandItem(command);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(String example) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        example,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCommandItem(Map<String, dynamic> command) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                command['success'] ? Icons.check_circle : Icons.error,
                size: 16,
                color: command['success'] ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  command['command'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                command['time'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            command['response'],
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 24,
            ),
            SizedBox(width: 8),
            Text("وصلت للحد الأقصى"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("لقد وصلت للحد الأقصى لاستخدام المساعد الصوتي هذا الشهر."),
            SizedBox(height: 16),
            Text(
              "يمكنك:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("• ترقية باقتك"),
            Text("• مشاهدة إعلان للحصول على استخدامات إضافية"),
            Text("• انتظار الشهر القادم"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscriptions');
            },
            child: const Text("ترقية الباقة"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/rewards');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("مشاهدة إعلان"),
          ),
        ],
      ),
    );
  }

  void _showResponseDialog() {
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
            Text("تم تنفيذ الأمر"),
          ],
        ),
        content: const Text(
          "تم إضافة مصروف جديد: 50 جنيه - قهوة\nتاريخ: اليوم"
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("موافق"),
          ),
        ],
      ),
    );
  }
} 