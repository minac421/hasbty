import 'package:flutter/material.dart';

class ResponsiveHelper {
  // تحديد نقاط الانكسار للشاشات المختلفة
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // التحقق من نوع الجهاز
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // الحصول على عدد الأعمدة المناسب
  static int getGridColumns(BuildContext context, {int mobile = 2, int tablet = 3, int desktop = 4}) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // الحصول على عدد الأعمدة للإحصائيات
  static int getStatsColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 1; // موبايل صغير
    if (width < 600) return 2; // موبايل عادي
    if (width < 900) return 3; // تابلت صغير
    return 4; // تابلت كبير وديسكتوب
  }

  // الحصول على حجم الخط المناسب
  static double getFontSize(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // الحصول على المسافات المناسبة
  static double getSpacing(BuildContext context, {
    double mobile = 16,
    double tablet = 20,
    double desktop = 24,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // الحصول على أقصى عرض للمحتوى
  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 1200;
    return width;
  }

  // تحديد نسبة العرض إلى الارتفاع للبطاقات
  static double getCardAspectRatio(BuildContext context) {
    if (isMobile(context)) return 1.2;
    if (isTablet(context)) return 1.3;
    return 1.4;
  }

  // الحصول على padding مناسب للشاشة
  static EdgeInsets getScreenPadding(BuildContext context) {
    final spacing = getSpacing(context);
    return EdgeInsets.all(spacing);
  }

  // تحديد حجم الأيقونات
  static double getIconSize(BuildContext context, {
    double mobile = 24,
    double tablet = 28,
    double desktop = 32,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // تحديد ارتفاع الأزرار
  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) return 48;
    if (isTablet(context)) return 52;
    return 56;
  }

  // تحديد حجم الـ App Bar
  static double getAppBarHeight(BuildContext context) {
    if (isMobile(context)) return kToolbarHeight;
    return kToolbarHeight + 8;
  }

  // widget مخصص للتخطيط المتجاوب
  static Widget responsiveBuilder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  // تحديد عرض العنصر بناءً على الشاشة
  static double getItemWidth(BuildContext context, int totalItems) {
    final width = MediaQuery.of(context).size.width;
    final padding = getSpacing(context) * 2;
    final availableWidth = width - padding;
    
    if (isMobile(context)) {
      return availableWidth / 2 - 8; // عنصرين في الصف
    } else if (isTablet(context)) {
      return availableWidth / 3 - 12; // ثلاثة عناصر في الصف
    } else {
      return availableWidth / 4 - 16; // أربعة عناصر في الصف
    }
  }

  // تحديد الاتجاه المناسب للـ layout
  static Axis getScrollDirection(BuildContext context) {
    return isMobile(context) ? Axis.vertical : Axis.horizontal;
  }

  // تحديد إعدادات Grid للبطاقات
  static SliverGridDelegate getGridDelegate(BuildContext context) {
    final columns = getGridColumns(context);
    final spacing = getSpacing(context, mobile: 12, tablet: 16, desktop: 20);
    
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: getCardAspectRatio(context),
    );
  }

  // إنشاء grid responsive للإحصائيات
  static Widget buildResponsiveStatsGrid({
    required BuildContext context,
    required List<Widget> children,
  }) {
    final columns = getStatsColumns(context);
    final spacing = getSpacing(context, mobile: 12, tablet: 16, desktop: 20);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: getCardAspectRatio(context),
      children: children,
    );
  }

  // إنشاء layout للأزرار
  static Widget buildResponsiveButtonLayout({
    required BuildContext context,
    required List<Widget> buttons,
  }) {
    if (isMobile(context)) {
      // في الموبايل: أزرار عمودية
      return Column(
        children: buttons.map((button) => 
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: button,
          )
        ).toList(),
      );
    } else {
      // في التابلت والديسكتوب: أزرار أفقية
      return Row(
        children: buttons.map((button) => 
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: button,
            )
          )
        ).toList(),
      );
    }
  }

  // تحديد حجم النافذة المنبثقة
  static Size getDialogSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    if (isMobile(context)) {
      return Size(screenSize.width * 0.9, screenSize.height * 0.8);
    } else if (isTablet(context)) {
      return Size(screenSize.width * 0.7, screenSize.height * 0.7);
    } else {
      return Size(600, screenSize.height * 0.6);
    }
  }
} 