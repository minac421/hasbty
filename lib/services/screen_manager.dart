import 'package:flutter/material.dart';
import '../models/user_plan.dart';

/// نظام إدارة الشاشات حسب نوع المستخدم
class ScreenManager {
  /// التحقق من الوصول لشاشة معينة
  static bool canAccessScreen(String screenName, UserType userType) {
    return getAvailableScreens(userType).contains(screenName);
  }

  /// الحصول على قائمة الشاشات المتاحة لنوع مستخدم
  static List<String> getAvailableScreens(UserType userType) {
    switch (userType) {
      case UserType.individual:
        return [
          'home',           // الرئيسية المبسطة
          'ocr_scanner',    // تصوير الفواتير
          'voice_input',    // الإدخال الصوتي
          'simple_reports', // تقارير مبسطة
          'rewards',        // نقاط المكافآت
          'settings',       // الإعدادات الأساسية
        ];
      case UserType.smallBusiness:
        return [
          'dashboard',      // لوحة التحكم
          'pos',           // نقطة البيع
          'products',      // إدارة المنتجات
          'customers',     // إدارة العملاء
          'suppliers',     // إدارة الموردين
          'invoices',      // الفواتير
          'inventory',     // المخزون
          'reports',       // التقارير المتقدمة
          'settings',      // الإعدادات
        ];
      case UserType.enterprise:
        return [
          'dashboard',             // لوحة التحكم المتقدمة
          'pos',                  // نقطة البيع
          'products',             // إدارة المنتجات
          'customers',            // إدارة العملاء
          'suppliers',            // إدارة الموردين
          'invoices',             // الفواتير
          'inventory',            // المخزون المتقدم
          'reports',              // التقارير
          'ai_reports',           // تقارير الذكاء الاصطناعي
          'branch_management',    // إدارة الفروع
          'user_management',      // إدارة المستخدمين
          'advanced_settings',    // الإعدادات المتقدمة
          'api_integration',      // تكامل API
        ];
    }
  }

  /// الحصول على عناصر الشريط السفلي للتنقل
  static List<Map<String, dynamic>> getBottomNavItems(UserType userType) {
    switch (userType) {
      case UserType.individual:
        return [
          {'index': 0, 'icon': Icons.home_rounded, 'label': 'الرئيسية', 'screen': 'home'},
          {'index': 1, 'icon': Icons.receipt_long_rounded, 'label': 'المصاريف', 'screen': 'add_transaction'},
          {'index': 2, 'icon': Icons.document_scanner_rounded, 'label': 'مسح', 'screen': 'ocr_scanner'},
          {'index': 3, 'icon': Icons.insights_rounded, 'label': 'التقارير', 'screen': 'simple_reports'},
          {'index': 4, 'icon': Icons.settings_rounded, 'label': 'الإعدادات', 'screen': 'settings'},
        ];
      case UserType.smallBusiness:
        return [
          {'index': 0, 'icon': Icons.home_rounded, 'label': 'الرئيسية', 'screen': 'dashboard'},
          {'index': 1, 'icon': Icons.inventory_2_rounded, 'label': 'المنتجات', 'screen': 'products'},
          {'index': 2, 'icon': Icons.point_of_sale_rounded, 'label': 'نقطة البيع', 'screen': 'pos'},
          {'index': 3, 'icon': Icons.people_rounded, 'label': 'العملاء', 'screen': 'customers'},
          {'index': 4, 'icon': Icons.insights_rounded, 'label': 'التقارير', 'screen': 'reports'},
        ];
      case UserType.enterprise:
        return [
          {'index': 0, 'icon': Icons.dashboard_rounded, 'label': 'لوحة التحكم', 'screen': 'dashboard'},
          {'index': 1, 'icon': Icons.inventory_rounded, 'label': 'المخزون', 'screen': 'inventory'},
          {'index': 2, 'icon': Icons.analytics_rounded, 'label': 'التحليلات', 'screen': 'ai_reports'},
          {'index': 3, 'icon': Icons.business_center_rounded, 'label': 'الإدارة', 'screen': 'branch_management'},
          {'index': 4, 'icon': Icons.settings_applications_rounded, 'label': 'الإعدادات', 'screen': 'advanced_settings'},
        ];
    }
  }

  /// الحصول على الشاشات الموصى بها للمستخدم الجديد
  static List<String> getOnboardingScreens(UserType userType) {
    switch (userType) {
      case UserType.individual:
        return ['home', 'ocr_scanner', 'simple_reports'];
      case UserType.smallBusiness:
        return ['dashboard', 'pos', 'products', 'customers'];
      case UserType.enterprise:
        return ['dashboard', 'pos', 'inventory', 'ai_reports', 'branch_management'];
    }
  }

  /// الحصول على وصف مختصر للشاشة
  static String getScreenDescription(String screenName, UserType userType) {
    final descriptions = {
      'home': 'واجهة بسيطة لتتبع المصاريف اليومية',
      'dashboard': userType == UserType.smallBusiness 
          ? 'لوحة تحكم إدارة الأعمال الصغيرة'
          : 'لوحة تحكم متقدمة للشركات الكبيرة',
      'pos': 'نقطة بيع سهلة وسريعة',
      'products': 'إدارة المنتجات والأسعار',
      'customers': 'إدارة العملاء والمتابعة',
      'suppliers': 'إدارة الموردين والمشتريات',
      'invoices': 'إنشاء وإدارة الفواتير',
      'inventory': 'متابعة المخزون والكميات',
      'reports': 'تقارير مالية شاملة',
      'ai_reports': 'تحليلات ذكية بالذكاء الاصطناعي',
      'ocr_scanner': 'تصوير الفواتير واستخراج البيانات',
      'simple_reports': 'تقارير مبسطة للمصاريف',
      'rewards': 'نقاط وجوائز للاستخدام النشط',
      'settings': 'إعدادات التطبيق والحساب',
      'branch_management': 'إدارة الفروع والمواقع',
      'user_management': 'إدارة المستخدمين والصلاحيات',
      'advanced_settings': 'إعدادات متقدمة وتخصيص',
      'api_integration': 'ربط التطبيق مع أنظمة أخرى',
    };
    
    return descriptions[screenName] ?? 'شاشة $screenName';
  }

  /// التحقق من الحاجة لترقية الباقة للوصول لشاشة معينة
  static bool needsUpgradeForScreen(String screenName, UserPlan? userPlan) {
    if (userPlan == null) return true;
    
    // الشاشات التي تحتاج ترقية في النسخة المجانية
    final premiumScreens = {
      UserType.individual: ['advanced_reports', 'unlimited_ocr'],
      UserType.smallBusiness: ['advanced_analytics', 'multi_warehouse'],
      UserType.enterprise: ['full_ai_reports', 'unlimited_branches'],
    };
    
    if (userPlan.status != SubscriptionStatus.active && 
        userPlan.status != SubscriptionStatus.trial) {
      return premiumScreens[userPlan.userType]?.contains(screenName) ?? false;
    }
    
    return false;
  }
} 