import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../theme/app_theme.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

// Widget للأرقام المتحركة
class AnimatedCounter extends StatelessWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    Key? key,
    required this.value,
    this.duration = const Duration(milliseconds: 1000),
    this.style,
    this.prefix,
    this.suffix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '${prefix ?? ''}${value.toInt()}${suffix ?? ''}',
          style: style ?? Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}

// Widget للبطاقات المتحركة عند الظهور
class FadeScaleCard extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeScaleCard({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  State<FadeScaleCard> createState() => _FadeScaleCardState();
}

class _FadeScaleCardState extends State<FadeScaleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// Widget للـ Progress مع animation
class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final Duration duration;

  const AnimatedProgressBar({
    Key? key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: color ?? AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget للأيقونات المتحركة
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const AnimatedIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 24,
  }) : super(key: key);

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation.drive(
          Tween(begin: 1.0, end: 0.8),
        ),
        child: Icon(
          widget.icon,
          color: widget.color ?? AppTheme.primaryColor,
          size: widget.size,
        ),
      ),
    );
  }
}

// Widget للنجاح/الخطأ المتحرك
class AnimatedStatusWidget extends StatefulWidget {
  final bool isSuccess;
  final String message;
  final VoidCallback? onComplete;

  const AnimatedStatusWidget({
    Key? key,
    required this.isSuccess,
    required this.message,
    this.onComplete,
  }) : super(key: key);

  @override
  State<AnimatedStatusWidget> createState() => _AnimatedStatusWidgetState();
}

class _AnimatedStatusWidgetState extends State<AnimatedStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && widget.onComplete != null) {
          widget.onComplete!();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: widget.isSuccess
                            ? AppTheme.successColor.withOpacity(0.1)
                            : AppTheme.errorColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isSuccess
                            ? Icons.check_circle_rounded
                            : Icons.error_rounded,
                        color: widget.isSuccess
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.message,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget للـ PageTransition
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

// Widget للـ Shared Axis Transition
class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SharedAxisTransitionType transitionType;

  SharedAxisPageRoute({
    required this.page,
    this.transitionType = SharedAxisTransitionType.horizontal,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: transitionType,
              child: child,
            );
          },
        );
}

// Widget للـ Loading Button
class LoadingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final bool isLoading;

  const LoadingButton({
    Key? key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(LoadingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon),
                        const SizedBox(width: 8),
                      ],
                      Text(widget.label),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class AnimatedWidgets {
  // العدادات المتحركة للأرقام
  static Widget animatedCounter({
    required double value,
    required String suffix,
    Color? color,
    double? fontSize,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: value),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, animatedValue, child) {
        return Text(
          '${animatedValue.toStringAsFixed(0)}$suffix',
          style: TextStyle(
            color: color ?? Colors.black87,
            fontSize: fontSize ?? 24,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  // عداد الأموال المتحرك
  static Widget animatedMoneyCounter({
    required double amount,
    String currency = 'جنيه',
    Color? color,
    double? fontSize,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: amount),
          duration: duration,
          curve: Curves.bounceOut,
          builder: (context, animatedValue, child) {
            return Text(
              animatedValue.toStringAsFixed(0),
              style: TextStyle(
                color: color ?? Colors.green,
                fontSize: fontSize ?? 20,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        const SizedBox(width: 4),
        Text(
          currency,
          style: TextStyle(
            color: color ?? Colors.green,
            fontSize: (fontSize ?? 20) * 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // نص متحرك للترحيب
  static Widget animatedWelcomeText(String text, {Color? color}) {
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          text,
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black87,
          ),
          speed: const Duration(milliseconds: 100),
        ),
      ],
      totalRepeatCount: 1,
      pause: const Duration(milliseconds: 1000),
    );
  }

  // نص متحرك للحالات الفارغة
  static Widget animatedEmptyStateText(String text) {
    return AnimatedTextKit(
      animatedTexts: [
        FadeAnimatedText(
          text,
          textStyle: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          duration: const Duration(milliseconds: 2000),
        ),
      ],
      totalRepeatCount: 1,
      pause: const Duration(milliseconds: 500),
    );
  }

  // أيقونة متحركة للنجاح
  static Widget animatedSuccessIcon({double size = 60}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.bounceOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(size / 2),
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: size * 0.6,
            ),
          ),
        );
      },
    );
  }

  // شريط تحميل متحرك
  static Widget animatedLoadingBar({
    required double progress,
    Color? color,
    double height = 8,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color ?? Colors.blue,
              (color ?? Colors.blue).withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(),
        ),
      ),
    );
  }

  // بطاقة متحركة للإحصائيات
  static Widget animatedStatCard({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
    String suffix = '',
    int animationDelay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + animationDelay),
      curve: Curves.elasticOut,
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 1000 + animationDelay),
                    curve: Curves.bounceOut,
                    builder: (context, iconScale, child) {
                      return Transform.scale(
                        scale: iconScale,
                        child: Icon(icon, color: color, size: 32),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  animatedCounter(
                    value: value,
                    suffix: suffix,
                    color: color,
                    fontSize: 18,
                    duration: Duration(milliseconds: 1500 + animationDelay),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // زر متحرك للإجراءات
  static Widget animatedActionButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    Color? color,
    bool isLoading = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Icon(icon),
                  );
                },
              ),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // شاشة تحميل متحركة
  static Widget animatedLoadingScreen({String message = 'جاري التحميل...'}) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أنيميشن Lottie للتحميل (محاكاة)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 6.28, // دورة كاملة
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                        stops: [0.0, value],
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            animatedWelcomeText(message, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  // قائمة متحركة للعناصر
  static Widget animatedListItem({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * delay.inMilliseconds)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(100 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }

  // مؤشر التقدم الدائري المتحرك
  static Widget animatedCircularProgress({
    required double progress,
    Color? color,
    double size = 100,
    String? centerText,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(color ?? Colors.blue),
              ),
              if (centerText != null)
                Text(
                  centerText,
                  style: TextStyle(
                    fontSize: size * 0.15,
                    fontWeight: FontWeight.bold,
                    color: color ?? Colors.blue,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // تأثير النبضة للأزرار المهمة
  static Widget pulsingButton({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.1),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, scale, _) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      onEnd: () {
        // يمكن إضافة لوجيك لتكرار النبضة
      },
    );
  }
} 