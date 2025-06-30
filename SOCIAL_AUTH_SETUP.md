# إعداد تسجيل الدخول الاجتماعي

تم إضافة تسجيل الدخول بـ Google و Facebook و Apple ID إلى التطبيق. لتفعيل هذه الميزات، يجب إكمال الإعدادات التالية:

## 1. إعداد Google Sign-In

### للويب:
1. اذهب إلى [Google Cloud Console](https://console.cloud.google.com/)
2. أنشئ مشروع جديد أو اختر مشروع موجود
3. فعّل Google+ API
4. أنشئ OAuth 2.0 credentials
5. أضف `http://localhost:8080` إلى Authorized redirect URIs للتطوير
6. احصل على Client ID واستبدل `YOUR_GOOGLE_WEB_CLIENT_ID` في الكود

### لـ iOS:
1. أنشئ iOS OAuth client ID
2. احصل على iOS Client ID واستبدل `YOUR_GOOGLE_IOS_CLIENT_ID` في الكود
3. أضف GoogleService-Info.plist إلى مجلد ios/Runner

### لـ Android:
1. أنشئ Android OAuth client ID
2. أضف google-services.json إلى مجلد android/app

## 2. إعداد Facebook Login

### للويب:
1. اذهب إلى [Facebook Developers](https://developers.facebook.com/)
2. أنشئ تطبيق جديد
3. أضف Facebook Login product
4. أضف `http://localhost:8080` إلى Valid OAuth Redirect URIs
5. احصل على App ID و App Secret

### لـ iOS:
1. أضف Facebook SDK إلى Info.plist
2. أضف URL scheme للتطبيق

### لـ Android:
1. أضف Facebook App ID إلى strings.xml
2. أضف Facebook SDK إلى AndroidManifest.xml

## 3. إعداد Apple Sign In

### متطلبات:
- يعمل فقط على iOS 13+ و macOS 10.15+
- يتطلب Apple Developer Account

### الإعداد:
1. اذهب إلى Apple Developer Console
2. أنشئ App ID مع Sign In with Apple capability
3. أنشئ Service ID للويب
4. أضف domain و return URL

## 4. إعداد Supabase

1. اذهب إلى Supabase Dashboard
2. في Authentication > Settings > Auth Providers:
   - فعّل Google وأضف Client ID و Client Secret
   - فعّل Facebook وأضف App ID و App Secret
   - فعّل Apple وأضف Service ID و Team ID و Key ID و Private Key

## 5. تحديث الكود

استبدل المتغيرات التالية في `login_screen.dart`:
```dart
const webClientId = 'YOUR_ACTUAL_GOOGLE_WEB_CLIENT_ID';
const iosClientId = 'YOUR_ACTUAL_GOOGLE_IOS_CLIENT_ID';
```

## ملاحظات مهمة:

- تأكد من إضافة جميع domains المطلوبة في إعدادات OAuth
- للإنتاج، استبدل localhost بـ domain الفعلي
- تأكد من تطابق Bundle ID/Package Name في جميع المنصات
- احتفظ بـ Client Secrets آمنة ولا تضعها في الكود المصدري

## اختبار الميزات:

1. تشغيل التطبيق: `flutter run -d chrome`
2. اختبار كل طريقة تسجيل دخول
3. التحقق من إنشاء المستخدمين في Supabase Dashboard

## استكشاف الأخطاء:

- تحقق من console logs للأخطاء
- تأكد من صحة جميع IDs و URLs
- تحقق من إعدادات CORS في Supabase
- تأكد من تفعيل Auth providers في Supabase