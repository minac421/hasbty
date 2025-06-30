import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// مزود حالة الثيم
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadThemeFromPrefs();
  }

  static const String _themeKey = 'theme_mode';

  // تحميل الثيم المحفوظ من الذاكرة
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            state = ThemeMode.light;
            break;
          case 'dark':
            state = ThemeMode.dark;
            break;
          case 'system':
            state = ThemeMode.system;
            break;
        }
      }
    } catch (e) {
      // في حالة الخطأ، استخدم الوضع الفاتح كافتراضي
      state = ThemeMode.light;
    }
  }

  // حفظ الثيم في الذاكرة
  Future<void> _saveThemeToPrefs(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeString;
      
      switch (themeMode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }
      
      await prefs.setString(_themeKey, themeString);
    } catch (e) {
      // تجاهل الأخطاء في الحفظ
      debugPrint('خطأ في حفظ إعدادات الثيم: $e');
    }
  }

  // تبديل إلى الوضع الفاتح
  Future<void> setLightMode() async {
    state = ThemeMode.light;
    await _saveThemeToPrefs(ThemeMode.light);
  }

  // تبديل إلى الوضع المظلم
  Future<void> setDarkMode() async {
    state = ThemeMode.dark;
    await _saveThemeToPrefs(ThemeMode.dark);
  }

  // تبديل إلى وضع النظام
  Future<void> setSystemMode() async {
    state = ThemeMode.system;
    await _saveThemeToPrefs(ThemeMode.system);
  }

  // تبديل سريع بين الفاتح والمظلم
  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setLightMode();
    } else {
      await setDarkMode();
    }
  }

  // التحقق من الوضع الحالي
  bool get isLightMode => state == ThemeMode.light;
  bool get isDarkMode => state == ThemeMode.dark;
  bool get isSystemMode => state == ThemeMode.system;

  // الحصول على أيقونة الثيم الحالي
  IconData get currentThemeIcon {
    switch (state) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  // الحصول على اسم الثيم الحالي
  String get currentThemeName {
    switch (state) {
      case ThemeMode.light:
        return 'الوضع الفاتح';
      case ThemeMode.dark:
        return 'الوضع المظلم';
      case ThemeMode.system:
        return 'وضع النظام';
    }
  }
}

// مزود الثيم العام
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

// مزود مساعد لمعرفة إذا كان الوضع مظلم أم لا
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  
  if (themeMode == ThemeMode.system) {
    // في وضع النظام، نتحقق من إعدادات النظام
    final window = WidgetsBinding.instance.window;
    return window.platformBrightness == Brightness.dark;
  }
  
  return themeMode == ThemeMode.dark;
});

// مزود مساعد للحصول على معلومات الثيم
final themeInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final themeNotifier = ref.read(themeProvider.notifier);
  final isDark = ref.watch(isDarkModeProvider);
  
  return {
    'isDark': isDark,
    'currentMode': themeNotifier.state,
    'icon': themeNotifier.currentThemeIcon,
    'name': themeNotifier.currentThemeName,
    'isLight': themeNotifier.isLightMode,
    'isSystem': themeNotifier.isSystemMode,
  };
}); 