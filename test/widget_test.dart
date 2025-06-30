// اختبار أساسي لتطبيق جردلي
//
// للتفاعل مع الـ widgets في الاختبار، استخدم WidgetTester
// يمكنك محاكاة النقر والتمرير وقراءة النصوص والتحقق من خصائص الـ widgets

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jardaly/main.dart';

void main() {
  testWidgets('جردلي - اختبار تحميل التطبيق الأساسي', (WidgetTester tester) async {
    // بناء التطبيق وتشغيل إطار
    await tester.pumpWidget(const ProviderScope(child: JardalyApp()));

    // التحقق من أن شاشة تسجيل الدخول تظهر
    expect(find.text('جردلي'), findsOneWidget);
    
    // التحقق من وجود العنوان الفرعي
    expect(find.text('مساعدك الذكي للمصاريف والمحاسبة'), findsOneWidget);
    
    // التحقق من وجود أزرار تجربة الباقات
    expect(find.text('مستخدم فردي'), findsOneWidget);
    expect(find.text('شركة صغيرة'), findsOneWidget);
    expect(find.text('شركة كبيرة'), findsOneWidget);
  });

  testWidgets('جردلي - اختبار الانتقال للواجهة الفردية', (WidgetTester tester) async {
    // بناء التطبيق
    await tester.pumpWidget(const ProviderScope(child: JardalyApp()));

    // البحث عن زر المستخدم الفردي والنقر عليه
    final individualButton = find.text('مستخدم فردي');
    expect(individualButton, findsOneWidget);
    
    await tester.tap(individualButton);
    await tester.pumpAndSettle(); // انتظار انتهاء الانتقال

    // التحقق من الوصول للواجهة الفردية
    expect(find.text('قل أو صور مصروفك'), findsOneWidget);
    expect(find.text('صوت'), findsOneWidget);
    expect(find.text('تصوير'), findsOneWidget);
  });

  testWidgets('جردلي - اختبار وجود الأزرار الأساسية في الواجهة الفردية', (WidgetTester tester) async {
    // بناء التطبيق والانتقال للواجهة الفردية
    await tester.pumpWidget(const ProviderScope(child: JardalyApp()));
    
    await tester.tap(find.text('مستخدم فردي'));
    await tester.pumpAndSettle();

    // التحقق من وجود أزرار الصوت والكاميرا
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    
    // التحقق من وجود الملخص المالي
    expect(find.text('اليوم'), findsOneWidget);
    expect(find.text('الشهر'), findsOneWidget);
  });
}
