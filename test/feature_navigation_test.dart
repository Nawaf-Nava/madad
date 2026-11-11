import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app_factory.dart';

void main() {
  const serviceTitles = <String>[
    'طلب سحب نقدي',
    'تحويل إلى مشترك',
    'دفع المشتريات',
    'إرسال حوالة شبكة تحويل',
    'بنوك ومحافظ',
    'استلام حوالة عبر شبكات محلية',
    'حالة حوالة',
    'إرسال حوالة عبر شبكات محلية',
    'إلغاء حوالة',
    'الشحن والسداد',
    'تحويل بين حساباتي (مصارف)',
    'طلب استلام حوالة محلية',
    'تحويل إلى محافظ أخرى',
    'طلب استلام حوالة دولية',
    'سحب من الصراف الآلي YKB',
    'كود شراء',
    'سحب من الصراف الآلي كاك بنك',
    'بطاقات نت',
    'ألعاب',
    'تطبيقات',
    'تسديد الوطنية للتحويل الأصغر',
    'تبرعات',
    'البطاقات الافتراضية',
    'جيب العائلة',
    'فِرقك',
    'هدية',
    'حصالة',
  ];

  testWidgets('service catalogue routes open and return for every listed area',
      (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '771234567');
    await tester.enterText(find.byType(TextField).at(1), 'test-password');
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();

    tester
        .widget<NavigationBar>(find.byType(NavigationBar))
        .onDestinationSelected!(2);
    await tester.pumpAndSettle();

    for (final title in serviceTitles) {
      final tileTitle = find.text(title).last;
      await tester.ensureVisible(tileTitle);
      await tester.pumpAndSettle();
      await tester.tap(tileTitle);
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsNothing,
          reason:
              'Expected $title to open a detail or unavailable-state page.');
      tester.state<NavigatorState>(find.byType(Navigator).last).pop();
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
    }
  });

  testWidgets(
      'transfer review remains preview-only and creates no success state',
      (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '771234567');
    await tester.enterText(find.byType(TextField).at(1), 'test-password');
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    tester
        .widget<NavigationBar>(find.byType(NavigationBar))
        .onDestinationSelected!(2);
    await tester.pumpAndSettle();
    final transferTile = find.text('تحويل إلى مشترك').last;
    await tester.ensureVisible(transferTile);
    await tester.pumpAndSettle();
    await tester.tap(transferTile);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '771234567');
    await tester.enterText(find.byType(TextFormField).at(1), '125');
    await tester.tap(find.text('مراجعة البيانات'));
    await tester.pumpAndSettle();

    expect(find.text('لم يتم تنفيذ أي عملية؛ هذه معاينة فقط.'), findsOneWidget);
    expect(find.textContaining('تم التحويل بنجاح'), findsNothing);
  });

  testWidgets('QR option opens a no-camera scanner preview, not a scan result',
      (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '771234567');
    await tester.enterText(find.byType(TextField).at(1), 'test-password');
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    tester
        .widget<NavigationBar>(find.byType(NavigationBar))
        .onDestinationSelected!(2);
    await tester.pumpAndSettle();
    await tester.tap(find.text('دفع المشتريات').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('فتح معاينة ماسح QR'));
    await tester.pumpAndSettle();

    expect(find.text('معاينة الكاميرا غير متاحة'), findsOneWidget);
    expect(find.textContaining('لا يتم طلب إذن الكاميرا'), findsOneWidget);
    expect(find.textContaining('تم الدفع بنجاح'), findsNothing);
  });

  testWidgets('reports menu opens recent activity and account statement',
      (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '771234567');
    await tester.enterText(find.byType(TextField).at(1), 'test-password');
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();

    tester
        .widget<NavigationBar>(find.byType(NavigationBar))
        .onDestinationSelected!(1);
    await tester.pumpAndSettle();
    expect(find.text('آخر العمليات'), findsOneWidget);
    expect(find.text('كشف حساب'), findsOneWidget);

    await tester.tap(find.text('كشف حساب'));
    await tester.pumpAndSettle();
    expect(find.text('لا يوجد عمليات'), findsOneWidget);
    expect(find.text('كافة العمليات'), findsOneWidget);
  });

  testWidgets('reference report validates input without claiming a lookup',
      (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '771234567');
    await tester.enterText(find.byType(TextField).at(1), 'test-password');
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();

    tester
        .widget<NavigationBar>(find.byType(NavigationBar))
        .onDestinationSelected!(1);
    await tester.pumpAndSettle();
    final referenceReport = find.text('بحث بالرقم المرجعي');
    await tester.ensureVisible(referenceReport);
    await tester.pumpAndSettle();
    await tester.tap(referenceReport);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).last, '1234567890');
    await tester.tap(find.text('بحث').last);
    await tester.pumpAndSettle();
    expect(find.text('لا يوجد عمليات'), findsOneWidget);
    expect(find.text('الرقم المرجعي: 1234567890'), findsOneWidget);
  });
}
