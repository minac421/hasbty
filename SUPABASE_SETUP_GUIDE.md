# 🚀 دليل إعداد Supabase للتطبيق (30 دقيقة)

## 📋 الخطوات المطلوبة

### **الخطوة 1: إنشاء مشروع Supabase (10 دقائق)**

1. اذهب إلى [supabase.com](https://supabase.com)
2. اضغط **"Start your project"**
3. سجل دخول بـ GitHub أو Google
4. اضغط **"New project"**
5. املأ البيانات:
   - **Name:** `jardaly-app`
   - **Database Password:** كلمة مرور قوية
   - **Region:** اختر الأقرب لك
6. اضغط **"Create new project"**

---

### **الخطوة 2: الحصول على المفاتيح (5 دقائق)**

1. بعد إنشاء المشروع، اذهب لـ **Settings**
2. اضغط **API** من القائمة الجانبية
3. انسخ:
   - **URL** (Project URL)
   - **anon/public** (API Key)

---

### **الخطوة 3: إنشاء الجداول (10 دقائق)**

1. اذهب لـ **SQL Editor** في لوحة التحكم
2. انسخ والصق هذا الكود:

```sql
-- جدول المستخدمين
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE,
    name TEXT,
    user_type TEXT DEFAULT 'individual',
    plan_type TEXT DEFAULT 'free',
    trial_end_date TIMESTAMP WITH TIME ZONE,
    subscription_status TEXT DEFAULT 'inactive',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول المنتجات
CREATE TABLE public.products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) DEFAULT 0,
    cost_price DECIMAL(10,2) DEFAULT 0,
    quantity INTEGER DEFAULT 0,
    min_quantity INTEGER DEFAULT 0,
    sku TEXT,
    barcode TEXT,
    category TEXT,
    unit TEXT DEFAULT 'قطعة',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول العملاء
CREATE TABLE public.customers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    address TEXT,
    notes TEXT,
    total_purchases DECIMAL(10,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول الموردين
CREATE TABLE public.suppliers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    address TEXT,
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول المبيعات
CREATE TABLE public.sales (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES public.customers(id),
    customer_name TEXT,
    total_amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    payment_method TEXT DEFAULT 'cash',
    payment_status TEXT DEFAULT 'paid',
    notes TEXT,
    items JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول المشتريات
CREATE TABLE public.purchases (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    supplier_id UUID REFERENCES public.suppliers(id),
    supplier_name TEXT,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method TEXT DEFAULT 'cash',
    payment_status TEXT DEFAULT 'paid',
    notes TEXT,
    items JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول نتائج OCR
CREATE TABLE public.ocr_results (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    raw_text TEXT,
    merchant_name TEXT,
    total_amount DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    items JSONB,
    confidence DECIMAL(3,2),
    image_url TEXT,
    processed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول المعاملات العامة
CREATE TABLE public.transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL, -- 'income', 'expense', 'sale', 'purchase'
    category TEXT,
    description TEXT,
    amount DECIMAL(10,2) NOT NULL,
    payment_method TEXT DEFAULT 'cash',
    reference_id UUID, -- للربط مع مبيعة أو مشترى
    notes TEXT,
    date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إعداد Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ocr_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان - كل مستخدم يرى بياناته فقط
CREATE POLICY "Users can view own data" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own data" ON public.users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can manage own products" ON public.products FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own customers" ON public.customers FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own suppliers" ON public.suppliers FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own sales" ON public.sales FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own purchases" ON public.purchases FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own ocr results" ON public.ocr_results FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own transactions" ON public.transactions FOR ALL USING (auth.uid() = user_id);

-- دالة لإنشاء مستخدم جديد تلقائياً
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, name)
    VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'name', 'مستخدم جديد'));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ربط الدالة بحدث إنشاء مستخدم جديد
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```

3. اضغط **"Run"** لتنفيذ الكود

---

### **الخطوة 4: تحديث التطبيق (5 دقائق)**

1. افتح ملف `lib/services/api_service.dart`
2. استبدل:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseKey = 'YOUR_SUPABASE_ANON_KEY';
```

3. بالقيم الحقيقية من Supabase:
```dart
static const String supabaseUrl = 'https://xxxxxxxxxxxxxxxx.supabase.co';
static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

---

### **الخطوة 5: اختبار الاتصال**

1. شغل التطبيق: `flutter run`
2. تأكد من رؤية هذه الرسالة في الـ console:
   ```
   ✅ تم تهيئة Supabase بنجاح
   ```

3. إذا رأيت خطأ:
   ```
   ❌ خطأ في تهيئة Supabase
   ```
   تأكد من:
   - URL صحيح
   - API Key صحيح
   - الإنترنت متصل

---

## 🎯 بعد الانتهاء

- ✅ قاعدة بيانات Supabase جاهزة
- ✅ API Service متصل
- ✅ جاهز لحفظ البيانات الحقيقية
- ✅ نظام المستخدمين يعمل

---

## 🔧 الخطوة التالية

**المهمة التالية:** ربط الشاشات بالبيانات الحقيقية

**الهدف:** إزالة البيانات الوهمية من `individual_dashboard.dart`

**الوقت المتوقع:** ساعتين

---

## 📞 في حالة المشاكل

1. **خطأ في الاتصال:** تأكد من URL و API Key
2. **خطأ في الجداول:** تأكد من تنفيذ كود SQL بالكامل
3. **خطأ في الصلاحيات:** تأكد من تفعيل RLS

---

**✅ بمجرد الانتهاء، ستكون قد أكملت 40% من الخطة!** 