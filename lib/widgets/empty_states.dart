import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';

class EmptyStates {
  // Empty state عام
  static Widget general(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.inbox_rounded,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة متحركة
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 60,
                      color: AppTheme.primaryColor.withOpacity(0.7),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // العنوان
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // الرسالة
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            // زر الإجراء
            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Empty state للمنتجات
  static Widget products(BuildContext context, {VoidCallback? onAddPressed}) {
    return general(
      context,
      title: 'لا توجد منتجات',
      message: 'ابدأ بإضافة منتجاتك الأولى لإدارة مخزونك بسهولة',
      icon: Icons.inventory_2_rounded,
      onActionPressed: onAddPressed,
      actionLabel: 'إضافة منتج',
    );
  }

  // Empty state للعملاء
  static Widget customers(BuildContext context, {VoidCallback? onAddPressed}) {
    return general(
      context,
      title: 'لا يوجد عملاء',
      message: 'أضف عملاءك لتتبع معاملاتهم وأرصدتهم',
      icon: Icons.people_rounded,
      onActionPressed: onAddPressed,
      actionLabel: 'إضافة عميل',
    );
  }

  // Empty state للموردين
  static Widget suppliers(BuildContext context, {VoidCallback? onAddPressed}) {
    return general(
      context,
      title: 'لا يوجد موردين',
      message: 'سجل موردينك لإدارة المشتريات والمدفوعات',
      icon: Icons.business_rounded,
      onActionPressed: onAddPressed,
      actionLabel: 'إضافة مورد',
    );
  }

  // Empty state للفواتير
  static Widget invoices(BuildContext context, {VoidCallback? onAddPressed}) {
    return general(
      context,
      title: 'لا توجد فواتير',
      message: 'أنشئ فواتيرك الأولى وتتبع مدفوعاتك',
      icon: Icons.receipt_long_rounded,
      onActionPressed: onAddPressed,
      actionLabel: 'إنشاء فاتورة',
    );
  }

  // Empty state للمعاملات
  static Widget transactions(BuildContext context) {
    return general(
      context,
      title: 'لا توجد معاملات',
      message: 'ستظهر هنا جميع معاملاتك المالية',
      icon: Icons.account_balance_wallet_rounded,
    );
  }

  // Empty state للبحث
  static Widget search(BuildContext context, String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة البحث متحركة
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            Text(
              'لا توجد نتائج للبحث',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            
            Text(
              'لم نجد نتائج تطابق "$query"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            Text(
              'جرب البحث بكلمات مختلفة',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty state مع Lottie animation
  static Widget withAnimation(
    BuildContext context, {
    required String animationPath,
    required String title,
    required String message,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                animationPath,
                repeat: true,
                animate: true,
              ),
            ),
            const SizedBox(height: 24),
            
            // العنوان
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // الرسالة
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            // زر الإجراء
            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Empty state للأخطاء
  static Widget error(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة خطأ متحركة
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 50,
                      color: AppTheme.errorColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            Text(
              'حدث خطأ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Empty state للشبكة
  static Widget noInternet(BuildContext context, {VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة متحركة
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.bounceOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 80,
                    color: Colors.grey.shade600,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            Text(
              'لا يوجد اتصال بالإنترنت',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            
            Text(
              'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 