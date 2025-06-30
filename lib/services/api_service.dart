import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  // إعدادات Supabase (سيتم تحديثها لاحقاً)
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // مؤقتاً - للعمل مع بيانات وهمية
  static bool _isDemoMode = true;
  
  // Supabase client
  static SupabaseClient? _supabaseClient;
  static SupabaseClient get supabase {
    if (_supabaseClient == null) {
      throw Exception('Supabase not initialized');
    }
    return _supabaseClient!;
  }
  
  // Dio instance للطلبات الخارجية
  static final Dio _dio = Dio();
  
  // تهيئة Supabase
  static Future<void> initialize() async {
    try {
      if (supabaseUrl == 'YOUR_SUPABASE_URL' || supabaseKey == 'YOUR_SUPABASE_ANON_KEY') {
        print('🔄 تشغيل في وضع التجربة بدون Supabase');
        _isDemoMode = true;
        return;
      }
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );
      _supabaseClient = Supabase.instance.client;
      _isDemoMode = false;
      print('✅ تم تهيئة Supabase بنجاح');
    } catch (e) {
      print('⚠️ فشل في تهيئة Supabase، سيتم التشغيل في وضع التجربة: $e');
      _isDemoMode = true;
    }
  }
  
  // تسجيل الدخول
  static Future<Map<String, dynamic>> signIn(String email, String password) async {
    if (_isDemoMode) {
      // محاكاة تسجيل دخول ناجح
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'user': {
          'id': 'demo-user-123',
          'email': email,
          'name': 'مستخدم تجريبي',
        },
        'session': {'access_token': 'demo-token'},
      };
    }
    
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return {
          'success': true,
          'user': response.user!.toJson(),
          'session': response.session?.toJson(),
        };
      } else {
        return {
          'success': false,
          'error': 'فشل في تسجيل الدخول',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في تسجيل الدخول: $e',
      };
    }
  }
  
  // تسجيل مستخدم جديد
  static Future<Map<String, dynamic>> signUp(String email, String password, String name) async {
    if (_isDemoMode) {
      // محاكاة تسجيل ناجح
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'user': {
          'id': 'demo-user-${DateTime.now().millisecondsSinceEpoch}',
          'email': email,
          'name': name,
        },
        'message': 'تم إنشاء الحساب بنجاح',
      };
    }
    
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      
      if (response.user != null) {
        return {
          'success': true,
          'user': response.user!.toJson(),
          'message': 'تم إنشاء الحساب بنجاح',
        };
      } else {
        return {
          'success': false,
          'error': 'فشل في إنشاء الحساب',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في إنشاء الحساب: $e',
      };
    }
  }
  
  // تسجيل الخروج
  static Future<void> signOut() async {
    if (!_isDemoMode) {
      await supabase.auth.signOut();
    }
  }
  
  // الحصول على المستخدم الحالي
  static User? getCurrentUser() {
    if (_isDemoMode) {
      return null; // في وضع التجربة لا يوجد مستخدم حقيقي
    }
    return supabase.auth.currentUser;
  }
  
  // حفظ منتج
  static Future<Map<String, dynamic>> saveProduct(Map<String, dynamic> productData) async {
    try {
      final response = await supabase
          .from('products')
          .insert(productData)
          .select()
          .single();
      
      return {
        'success': true,
        'data': response,
        'message': 'تم حفظ المنتج بنجاح',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في حفظ المنتج: $e',
      };
    }
  }
  
  // الحصول على المنتجات
  static Future<Map<String, dynamic>> getProducts({String? userId}) async {
    try {
      var query = supabase.from('products').select();
      
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في استرجاع المنتجات: $e',
        'data': [],
      };
    }
  }
  
  // تحديث منتج
  static Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> productData) async {
    try {
      final response = await supabase
          .from('products')
          .update(productData)
          .eq('id', id)
          .select()
          .single();
      
      return {
        'success': true,
        'data': response,
        'message': 'تم تحديث المنتج بنجاح',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في تحديث المنتج: $e',
      };
    }
  }
  
  // حذف منتج
  static Future<Map<String, dynamic>> deleteProduct(String id) async {
    try {
      await supabase
          .from('products')
          .delete()
          .eq('id', id);
      
      return {
        'success': true,
        'message': 'تم حذف المنتج بنجاح',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في حذف المنتج: $e',
      };
    }
  }
  
  // حفظ عميل
  static Future<Map<String, dynamic>> saveCustomer(Map<String, dynamic> customerData) async {
    try {
      final response = await supabase
          .from('customers')
          .insert(customerData)
          .select()
          .single();
      
      return {
        'success': true,
        'data': response,
        'message': 'تم حفظ العميل بنجاح',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في حفظ العميل: $e',
      };
    }
  }
  
  // الحصول على العملاء
  static Future<Map<String, dynamic>> getCustomers({String? userId}) async {
    try {
      var query = supabase.from('customers').select();
      
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في استرجاع العملاء: $e',
        'data': [],
      };
    }
  }
  
  // حفظ مبيعة
  static Future<Map<String, dynamic>> saveSale(Map<String, dynamic> saleData) async {
    try {
      final response = await supabase
          .from('sales')
          .insert(saleData)
          .select()
          .single();
      
      return {
        'success': true,
        'data': response,
        'message': 'تم حفظ المبيعة بنجاح',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في حفظ المبيعة: $e',
      };
    }
  }
  
  // الحصول على المبيعات
  static Future<Map<String, dynamic>> getSales({String? userId, DateTime? startDate, DateTime? endDate}) async {
    try {
      var query = supabase.from('sales').select();
      
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }
      
      final response = await query.order('created_at', ascending: false);
      
      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في استرجاع المبيعات: $e',
        'data': [],
      };
    }
  }
  
  // حفظ نتيجة OCR
  static Future<Map<String, dynamic>> saveOCRResult(Map<String, dynamic> ocrData) async {
    try {
      final response = await supabase
          .from('ocr_results')
          .insert(ocrData)
          .select()
          .single();
      
      return {
        'success': true,
        'data': response,
        'message': 'تم حفظ نتيجة OCR بنجاح',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في حفظ نتيجة OCR: $e',
      };
    }
  }
  
  // الحصول على تقرير المبيعات
  static Future<Map<String, dynamic>> getSalesReport({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // استعلام معقد للحصول على تقرير مفصل
      final response = await supabase.rpc('get_sales_report', params: {
        'user_id_param': userId,
        'start_date_param': startDate?.toIso8601String(),
        'end_date_param': endDate?.toIso8601String(),
      });
      
      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      // في حالة عدم وجود function، نسترجع البيانات بسيطة
      return await getSales(userId: userId, startDate: startDate, endDate: endDate);
    }
  }
  
  // حفظ معاملة عامة
  static Future<Map<String, dynamic>> saveTransaction(Map<String, dynamic> transactionData) async {
    try {
      final response = await supabase
          .from('transactions')
          .insert(transactionData)
          .select()
          .single();
      
      return {
        'success': true,
        'data': response,
        'message': 'تم حفظ المعاملة بنجاح',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في حفظ المعاملة: $e',
      };
    }
  }
  
  // اختبار الاتصال
  static Future<bool> testConnection() async {
    try {
      final response = await supabase.from('users').select('id').limit(1);
    return true;
    } catch (e) {
      print('خطأ في اختبار الاتصال: $e');
      return false;
    }
  }
  
  // معالجة الأخطاء العامة
  static String handleError(dynamic error) {
    if (error is PostgrestException) {
      return 'خطأ في قاعدة البيانات: ${error.message}';
    } else if (error is AuthException) {
      return 'خطأ في المصادقة: ${error.message}';
    } else {
      return 'خطأ غير متوقع: $error';
    }
  }
}

