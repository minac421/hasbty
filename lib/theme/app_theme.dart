import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // الألوان الأساسية - تدرجات الأزرق
  static const Color primaryColor = Color(0xFF0087B8); // أزرق رئيسي
  static const Color secondaryColor = Color(0xFF4FB6E3); // أزرق فاتح
  static const Color backgroundColor = Color(0xFFF8F9FA); // رمادي فاتح جداً للخلفية
  static const Color cardColor = Colors.white; // أبيض نقي للبطاقات
  static const Color textDarkColor = Color(0xFF2D3748); // رمادي غامق للنصوص
  static const Color textLightColor = Color(0xFF64748B); // رمادي فاتح للنصوص الثانوية
  static const Color borderColor = Color(0xFFE2E8F0); // رمادي فاتح للحدود
  static const Color activeButtonColor = Color(0xFF0087B8); // نفس اللون الرئيسي للأزرار النشطة
  
  // ألوان الحالة
  static const Color successColor = Color(0xFF10B981); // أخضر
  static const Color warningColor = Color(0xFFF59E0B); // أصفر
  static const Color errorColor = Color(0xFFEF4444); // أحمر
  static const Color inactiveColor = Color(0xFFCBD5E0); // رمادي فاتح للعناصر غير النشطة

  // ألوان الوضع المظلم
  static const Color darkBackgroundColor = Color(0xFF0F0F0F); // خلفية داكنة جداً
  static const Color darkSurfaceColor = Color(0xFF1A1A1A); // سطح داكن
  static const Color darkCardColor = Color(0xFF252525); // بطاقات داكنة
  static const Color darkBorderColor = Color(0xFF333333); // حدود داكنة
  static const Color darkTextPrimaryColor = Color(0xFFFFFFFF); // نص أبيض
  static const Color darkTextSecondaryColor = Color(0xFFB0B0B0); // نص رمادي فاتح
  static const Color darkPrimaryColor = Color(0xFF4FC3F7); // أزرق فاتح جميل
  static const Color darkSecondaryColor = Color(0xFF81D4FA); // أزرق فاتح أكثر

  // تدرجات اللون للوضع الفاتح
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, Color(0xFF006494)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF0087B8), Color(0xFF4FB6E3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // تدرجات للوضع المظلم
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBlueGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkAccentGradient = LinearGradient(
    colors: [Color(0xFF29B6F6), Color(0xFF4FC3F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // تدرجات خاصة للكارد في الوضع المظلم
  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF252525), Color(0xFF2A2A2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // الثيم الفاتح
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      
      // الألوان الأساسية
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        background: backgroundColor,
        surface: cardColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      
      // حالة شريط الحالة
      appBarTheme: const AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: textDarkColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDarkColor,
        ),
      ),
      
      // بطاقات بسيطة بحواف مستديرة
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        surfaceTintColor: Colors.transparent,
      ),
      
      // النصوص
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDarkColor,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDarkColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDarkColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDarkColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textDarkColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textDarkColor,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textLightColor,
          height: 1.4,
        ),
      ),
      
      // الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
      
      // شريط التنقل السفلي
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textLightColor,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // زر عائم للمساعد الصوتي
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }
  
  // الثيم الداكن المتطور
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      brightness: Brightness.dark,
      
      // الألوان الأساسية للوضع المظلم
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimaryColor,
        brightness: Brightness.dark,
        background: darkBackgroundColor,
        surface: darkSurfaceColor,
        primary: darkPrimaryColor,
        secondary: darkSecondaryColor,
        error: errorColor,
        onBackground: darkTextPrimaryColor,
        onSurface: darkTextPrimaryColor,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
      ),
      
      // شريط التطبيق المحسن للوضع المظلم
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurfaceColor,
        foregroundColor: darkTextPrimaryColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimaryColor,
        ),
      ),
      
      // البطاقات المحسنة للوضع المظلم
      cardTheme: CardTheme(
        color: darkCardColor,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: darkBorderColor, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        surfaceTintColor: Colors.transparent,
      ),
      
      // النصوص للوضع المظلم
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkTextPrimaryColor,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkTextPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkTextPrimaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimaryColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkTextPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: darkTextPrimaryColor,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: darkTextSecondaryColor,
          height: 1.4,
        ),
      ),
      
      // الأزرار للوضع المظلم
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // حقول الإدخال للوضع المظلم
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkPrimaryColor, width: 1.5),
        ),
        hintStyle: TextStyle(color: darkTextSecondaryColor),
        labelStyle: TextStyle(color: darkTextSecondaryColor),
      ),
      
      // شريط التنقل السفلي المحسن للوضع المظلم
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: darkPrimaryColor,
        unselectedItemColor: darkTextSecondaryColor,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // زر عائم محسن للوضع المظلم
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.black,
        elevation: 6,
        shape: const CircleBorder(),
      ),
      
      // ألوان الخلفية العامة
      scaffoldBackgroundColor: darkBackgroundColor,
      canvasColor: darkSurfaceColor,
      
      // قائمة منسدلة
      popupMenuTheme: PopupMenuThemeData(
        color: darkCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: darkBorderColor),
        ),
        textStyle: TextStyle(color: darkTextPrimaryColor),
      ),
      
      // مربع حوار
      dialogTheme: DialogTheme(
        backgroundColor: darkCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentTextStyle: TextStyle(color: darkTextPrimaryColor),
        titleTextStyle: TextStyle(color: darkTextPrimaryColor, fontWeight: FontWeight.bold),
      ),
    );
  }
  
  // أساليب واجهة المستخدم المشتركة
  
  // بطاقة أنيقة مع حواف مستديرة
  static Widget elegantCard({
    required Widget child,
    EdgeInsets? padding,
    double borderRadius = 16,
    Color? borderColor,
    Color? backgroundColor,
    double elevation = 0,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppTheme.borderColor,
          width: 1,
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
  
  // تنسيق بطاقة الإحصائيات
  static Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    Color? iconColor,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? primaryColor,
                  size: 20,
                ),
              ),
              const Spacer(),
              // هنا يمكن إضافة أيقونة إضافية إذا لزم الأمر
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textDarkColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: textLightColor,
            ),
          ),
        ],
      ),
    );
  }
  
  // تنسيق زر المساعد الصوتي
  static Widget voiceAssistantButton({
    required VoidCallback onPressed,
    double size = 56,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Ink(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic_rounded,
              color: iconColor ?? Colors.white,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
  
  // تنسيق لعناصر القائمة
  static Widget listItemContainer({
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  // للتوافق مع الكود القديم - إضافة الدوال المفقودة
  static Color get accentColor => primaryColor;
  static Color get surfaceColor => cardColor;
  
  static LinearGradient get accentGradient => primaryGradient;

  // دالة إنشاء container للأيقونات
  static Widget iconContainer({
    required IconData icon,
    Color? color,
    Color? backgroundColor,
    double size = 24,
    double containerSize = 48,
  }) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Icon(
        icon,
        color: color ?? primaryColor,
        size: size,
      ),
    );
  }

  // Card decoration
  static BoxDecoration cardDecoration({
    Color? color,
    double borderRadius = 16,
    bool hasBorder = true,
  }) {
    return BoxDecoration(
      color: color ?? cardColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: hasBorder ? Border.all(color: borderColor, width: 1) : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Gradient decoration
  static BoxDecoration gradientDecoration({
    required LinearGradient gradient,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

