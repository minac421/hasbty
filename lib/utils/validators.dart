class Validators {
  // التحقق من البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    
    return null;
  }

  // التحقق من كلمة المرور
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    
    return null;
  }

  // التحقق من رقم الهاتف
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    
    // التحقق من رقم الهاتف المصري (01XXXXXXXXX)
    final phoneRegex = RegExp(r'^01[0-2,5]\d{8}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'رقم الهاتف غير صحيح';
    }
    
    return null;
  }

  // التحقق من الاسم
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم مطلوب';
    }
    
    if (value.length < 3) {
      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    }
    
    if (value.length > 50) {
      return 'الاسم طويل جداً';
    }
    
    return null;
  }

  // التحقق من المبلغ المالي
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'المبلغ مطلوب';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'المبلغ غير صحيح';
    }
    
    if (amount <= 0) {
      return 'المبلغ يجب أن يكون أكبر من صفر';
    }
    
    if (amount > 999999999) {
      return 'المبلغ كبير جداً';
    }
    
    return null;
  }

  // التحقق من الكمية
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'الكمية مطلوبة';
    }
    
    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'الكمية غير صحيحة';
    }
    
    if (quantity <= 0) {
      return 'الكمية يجب أن تكون أكبر من صفر';
    }
    
    return null;
  }

  // التحقق من النسبة المئوية
  static String? validatePercentage(String? value) {
    if (value == null || value.isEmpty) {
      return null; // اختياري
    }
    
    final percentage = double.tryParse(value);
    if (percentage == null) {
      return 'النسبة غير صحيحة';
    }
    
    if (percentage < 0 || percentage > 100) {
      return 'النسبة يجب أن تكون بين 0 و 100';
    }
    
    return null;
  }

  // التحقق من التاريخ
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'التاريخ مطلوب';
    }
    
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'التاريخ غير صحيح';
    }
  }

  // التحقق من الوصف أو الملاحظات
  static String? validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'الوصف طويل جداً (الحد الأقصى 500 حرف)';
    }
    
    return null;
  }

  // التحقق من الباركود
  static String? validateBarcode(String? value) {
    if (value == null || value.isEmpty) {
      return null; // اختياري
    }
    
    // التحقق من الطول (عادة 8-13 رقم)
    if (value.length < 8 || value.length > 13) {
      return 'الباركود يجب أن يكون بين 8 و 13 رقم';
    }
    
    // التحقق من أن جميع الأحرف أرقام
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'الباركود يجب أن يحتوي على أرقام فقط';
    }
    
    return null;
  }

  // التحقق من حقل مطلوب عام
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  // التحقق من تطابق كلمتي المرور
  static String? validatePasswordMatch(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    
    if (value != password) {
      return 'كلمتا المرور غير متطابقتين';
    }
    
    return null;
  }

  // التحقق من العنوان
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return null; // اختياري
    }
    
    if (value.length < 10) {
      return 'العنوان قصير جداً';
    }
    
    if (value.length > 200) {
      return 'العنوان طويل جداً';
    }
    
    return null;
  }

  // التحقق من البريد الإلكتروني أو رقم الهاتف (للتسجيل)
  static String? validateEmailOrPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني أو رقم الهاتف مطلوب';
    }
    
    // محاولة التحقق كبريد إلكتروني أولاً
    if (value.contains('@')) {
      return validateEmail(value);
    }
    
    // إذا لم يكن بريد إلكتروني، التحقق كرقم هاتف
    return validatePhone(value);
  }
} 