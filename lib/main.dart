import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme and Utils
import 'theme/app_theme.dart';
import 'utils/constants.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/individual_dashboard.dart';
import 'screens/small_business_dashboard.dart';
import 'screens/enterprise_dashboard.dart';
import 'screens/reports_screen.dart';
import 'screens/invoices_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/user_type_selection_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/products_screen.dart';
import 'screens/suppliers_screen.dart';
import 'screens/pos_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/ocr_scanner_screen.dart';
import 'screens/voice_assistant_screen.dart';
import 'screens/subscriptions_screen.dart';
import 'screens/payment_method_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/simple_reports_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/employees_screen.dart';
import 'screens/branches_screen.dart';
import 'screens/voice_assistant_screen.dart';

// Models and Providers
import 'models/user_plan.dart';
import 'widgets/custom_bottom_nav.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'services/screen_manager.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // قفل الشاشة في الوضع العمودي فقط
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تهيئة Supabase
  try {
    await ApiService.initialize();
    print('✅ تم تهيئة Supabase بنجاح');
  } catch (e) {
    print('❌ خطأ في تهيئة Supabase: $e');
    print('📝 تأكد من تحديث URL و API Key في api_service.dart');
  }

  runApp(const ProviderScope(child: JardalyApp()));
}

class JardalyApp extends ConsumerWidget {
  const JardalyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // مراقبة حالة الثيم
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // استخدام الثيم من Provider
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [
        Locale('ar', 'EG'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: _buildRoutes(),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/onboarding': (context) => const OnboardingScreen(),
      '/dashboard': (context) => const MainScreen(),
      '/reports': (context) => const ReportsScreen(),
      '/invoices': (context) => const InvoicesScreen(),
      '/settings': (context) => const SettingsScreen(),
      '/user_type_selection': (context) => const UserTypeSelectionScreen(),
      '/customers': (context) => const CustomersScreen(),
      '/add_transaction': (context) => const AddTransactionScreen(),
      '/products': (context) => const ProductsScreen(),
      '/suppliers': (context) => const SuppliersScreen(),
      '/pos': (context) => const POSScreen(),
      '/inventory': (context) => const InventoryScreen(),
      '/ocr_scanner': (context) => const OCRScannerScreen(),
      '/subscriptions': (context) => const SubscriptionsScreen(),
      '/payment-methods': (context) => const PaymentMethodScreen(
        planType: UserType.smallBusiness,
        isAnnual: false,
      ),
      '/rewards': (context) => const RewardsScreen(),
      '/simple_reports': (context) => const SimpleReportsScreen(),
      '/signup': (context) => const SignUpScreen(),
      '/login': (context) => const LoginScreen(),
      '/voice_assistant': (context) => const VoiceAssistantScreen(),
      '/notifications': (context) => const NotificationsScreen(),
      '/employees': (context) => const EmployeesScreen(),
      '/branches': (context) => const BranchesScreen(),
      
      // مسارات مباشرة للشاشات (للاختبار والتطوير)
      '/individual_dashboard': (context) => const IndividualDashboard(),
      '/small_business_dashboard': (context) => const SmallBusinessDashboard(),
      '/enterprise_dashboard': (context) => const EnterpriseDashboard(),
    };
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userPlan = ref.watch(userPlanProvider);
    final userType = userPlan?.userType ?? UserType.individual;
    final screens = _getScreensForUserType(userType);

    // المستخدم الفردي لا يحتاج bottom navigation
    if (userType == UserType.individual) {
      return const IndividualDashboard();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: _buildFloatingActionButton(userType),
    );
  }

  List<Widget> _getScreensForUserType(UserType userType) {
    switch (userType) {
      case UserType.individual:
        return [
          const IndividualDashboard(),    // الرئيسية المبسطة
          const AddTransactionScreen(),   // المصاريف
          const OCRScannerScreen(),       // مسح الفواتير
          const SimpleReportsScreen(),    // تقارير مبسطة
          const SettingsScreen(),         // الإعدادات
        ];
      case UserType.smallBusiness:
        return [
          const SmallBusinessDashboard(), // لوحة التحكم
          const ProductsScreen(),         // المنتجات
          const POSScreen(),              // نقطة البيع
          const CustomersScreen(),        // العملاء
          const ReportsScreen(),          // التقارير
        ];
      case UserType.enterprise:
        return [
          const EnterpriseDashboard(),    // لوحة التحكم المتقدمة
          const InventoryScreen(),        // المخزون
          const ReportsScreen(),          // التحليلات (مؤقتاً)
          const CustomersScreen(),        // الإدارة (مؤقتاً)
          const SettingsScreen(),         // الإعدادات المتقدمة
        ];
    }
  }

  Widget? _buildFloatingActionButton(UserType userType) {
    if (userType == UserType.individual) return null;

    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/add_transaction'),
      backgroundColor: AppTheme.primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}


