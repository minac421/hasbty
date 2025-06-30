import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> 
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  
  // قائمة شاشات الترحيب المحسنة والتفاعلية
  List<OnboardingItem> get _onboardingItems => [
    OnboardingItem(
      title: '🎉 مرحباً بك في جردلي',
      subtitle: 'مساعدك الذكي للمحاسبة والمصاريف',
      description: 'اكتشف طريقة جديدة ومبتكرة لإدارة أموالك وأعمالك بذكاء وبساطة',
      icon: Icons.celebration,
      gradient: LinearGradient(
        colors: [Colors.purple.shade400, Colors.blue.shade500],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      animation: 'welcome',
    ),
    OnboardingItem(
      title: '💰 تتبع مصروفاتك بذكاء',
      subtitle: 'كل جنيه في مكانه المناسب',
      description: 'سجل مصروفاتك بسهولة، وتابع ميزانيتك، واحصل على تقارير ذكية تساعدك في توفير المال',
      icon: Icons.account_balance_wallet,
      gradient: LinearGradient(
        colors: [Colors.green.shade400, Colors.teal.shade500],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      animation: 'expense',
    ),
    OnboardingItem(
      title: '🤖 ذكاء اصطناعي متطور',
      subtitle: 'OCR + Voice Assistant',
      description: 'التقط صورة فاتورة أو تكلم بصوتك، وسيقوم الذكاء الاصطناعي بإضافة المعاملة تلقائياً',
      icon: Icons.auto_awesome,
      gradient: LinearGradient(
        colors: [Colors.orange.shade400, Colors.red.shade500],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      animation: 'ai',
    ),
    OnboardingItem(
      title: '📊 تحليلات وتقارير احترافية',
      subtitle: 'بيانات تساعدك في اتخاذ القرارات',
      description: 'احصل على رسوم بيانية متقدمة وتنبيهات ذكية وتحليلات تساعدك في فهم أموالك أكثر',
      icon: Icons.analytics,
      gradient: LinearGradient(
        colors: [Colors.indigo.shade400, Colors.purple.shade500],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      animation: 'analytics',
    ),
    OnboardingItem(
      title: '🚀 جاهز للانطلاق؟',
      subtitle: 'ابدأ رحلتك المالية الذكية',
      description: 'اختر نوع حسابك وابدأ في استخدام جردلي لتحويل طريقة إدارتك لأموالك إلى الأفضل',
      icon: Icons.rocket_launch,
      gradient: LinearGradient(
        colors: [Colors.pink.shade400, Colors.orange.shade500],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      animation: 'launch',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // تهيئة Animation Controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // بدء الرسوم المتحركة
    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    _rotateController.repeat(); // تكرار مستمر للدوران
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/user_type_selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final currentItem = _onboardingItems[_currentPage];
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
                ? [AppTheme.darkBackgroundColor, AppTheme.darkSurfaceColor]
                : [Colors.white, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
        child: Column(
          children: [
              // شريط علوي مع زر التخطي ومؤشر التقدم
              _buildTopBar(isDark),
              
              // محتوى الصفحات مع تأثيرات
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                    // إعادة تشغيل الرسوم المتحركة
                    _resetAnimations();
                    // تأثير اهتزاز للملاحظات
                    HapticFeedback.lightImpact();
                },
                itemCount: _onboardingItems.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingItems[index]);
                },
              ),
            ),
            
              // مؤشرات الصفحات والأزرار المحسنة
              _buildBottomSection(isDark, currentItem),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // شعار جردلي
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'جردلي',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          
          // زر التخطي المحسن
          TextButton.icon(
            onPressed: _skipOnboarding,
            icon: Icon(
              Icons.skip_next,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              size: 18,
            ),
            label: Text(
              'تخطي',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(bool isDark, OnboardingItem currentItem) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: BoxDecoration(
        color: isDark 
            ? AppTheme.darkSurfaceColor.withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // مؤشرات الصفحات المحسنة
          _buildEnhancedPageIndicators(currentItem),
          const SizedBox(height: 16),
          
          // الأزرار التفاعلية
          _buildActionButtons(isDark, currentItem),
        ],
      ),
    );
  }

  Widget _buildEnhancedPageIndicators(OnboardingItem currentItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingItems.length,
        (index) => _buildEnhancedPageIndicator(index, currentItem),
      ),
    );
  }

  Widget _buildEnhancedPageIndicator(int index, OnboardingItem currentItem) {
    final isActive = index == _currentPage;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 12,
      height: 12,
      decoration: BoxDecoration(
        gradient: isActive 
            ? currentItem.gradient
            : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade300]),
        borderRadius: BorderRadius.circular(6),
        boxShadow: isActive ? [
          BoxShadow(
            color: currentItem.gradient.colors.first.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
    );
  }

  Widget _buildActionButtons(bool isDark, OnboardingItem currentItem) {
    final isLastPage = _currentPage == _onboardingItems.length - 1;
    
    return Row(
      children: [
        // زر السابق (إذا لم تكن الصفحة الأولى)
        if (_currentPage > 0) ...[
          Expanded(
            flex: 1,
            child: TextButton.icon(
              onPressed: _previousPage,
              icon: const Icon(Icons.arrow_back),
              label: const Text('السابق'),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        
        // زر التالي/البدء
        Expanded(
          flex: _currentPage > 0 ? 2 : 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: currentItem.gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: currentItem.gradient.colors.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(isLastPage ? Icons.rocket_launch : Icons.arrow_forward),
              label: Text(
                isLastPage ? '🚀 ابدأ رحلتك!' : 'التالي',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _resetAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _scaleController.reset();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
    });
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    final isDark = ref.watch(isDarkModeProvider);
    
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutCubic,
            )),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الأيقونة المتحركة المحسنة
                  _buildAnimatedIcon(item),
                  const SizedBox(height: 24),
                  
                  // العنوان مع تأثير بصري
                  _buildAnimatedTitle(item, isDark),
                  const SizedBox(height: 12),
                  
                  // العنوان الفرعي مع تدرج
                  _buildAnimatedSubtitle(item, isDark),
                  const SizedBox(height: 16),
                  
                  // الوصف مع تأثير تدرجي
                  _buildAnimatedDescription(item, isDark),
                  
                  const SizedBox(height: 24),
                  
                  // مؤشرات تفاعلية إضافية
                  _buildInteractiveElements(item, isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedIcon(OnboardingItem item) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      )),
      child: RotationTransition(
        turns: Tween<double>(begin: 0, end: 0.1).animate(CurvedAnimation(
          parent: _rotateController,
          curve: Curves.easeInOut,
        )),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: item.gradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: item.gradient.colors.first.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            item.icon,
            size: 60,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle(OnboardingItem item, bool isDark) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
        height: 1.2,
      ),
      child: Text(
        item.title,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAnimatedSubtitle(OnboardingItem item, bool isDark) {
    return ShaderMask(
      shaderCallback: (bounds) => item.gradient.createShader(bounds),
      child: Text(
        item.subtitle,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAnimatedDescription(OnboardingItem item, bool isDark) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.grey[300] : Colors.grey[600],
        height: 1.6,
      ),
      child: Text(
        item.description,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildInteractiveElements(OnboardingItem item, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // نقاط صغيرة متحركة للزينة
        ...List.generate(3, (index) => 
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: item.gradient,
                  shape: BoxShape.circle,
                ),
                transform: Matrix4.identity()
                  ..scale(0.5 + (0.5 * (_rotateController.value + index * 0.2) % 1)),
              );
            },
          ),
        ),
      ],
    );
  }


}

class OnboardingItem {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final String animation;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.animation,
  });
} 