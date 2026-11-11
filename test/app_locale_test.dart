import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:madad/features/auth/auth_screen.dart';
import 'package:madad/features/home/home_screen.dart';
import 'package:madad/features/services/services_screen.dart';

import 'test_app_factory.dart';

void main() {
  testWidgets('Arabic is the default RTL locale and can switch to English LTR',
      (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(Directionality.of(tester.element(find.byType(AuthScreen))),
        TextDirection.rtl);
    expect(Theme.of(tester.element(find.byType(AuthScreen))).brightness,
        Brightness.dark);

    await tester.tap(find.byTooltip('اللغة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الإنجليزية'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(Directionality.of(tester.element(find.byType(AuthScreen))),
        TextDirection.ltr);
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), '771234567');
    await tester.enterText(find.byType(TextField).at(1), 'test-password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(Directionality.of(tester.element(find.byType(HomeScreen))),
        TextDirection.ltr);
    tester
        .widget<NavigationBar>(find.byType(NavigationBar))
        .onDestinationSelected!(2);
    await tester.pumpAndSettle();
    expect(Directionality.of(tester.element(find.byType(ServicesScreen))),
        TextDirection.ltr);

    tester
        .widget<NavigationBar>(find.byType(NavigationBar))
        .onDestinationSelected!(1);
    await tester.pumpAndSettle();
    expect(find.text('Recent transactions'), findsOneWidget);
  });

  testWidgets('auth and dashboard remain usable in a short phone viewport',
      (tester) async {
    tester.view.physicalSize = const Size(400, 405);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextField).at(0), '771234567');
    await tester.enterText(find.byType(TextField).at(1), 'test-password');
    await tester.ensureVisible(find.text('تسجيل الدخول'));
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('registration sends a new account request and opens signed-in UI',
      (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('قم بإنشاء الحساب'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'New');
    await tester.enterText(find.byType(TextField).at(1), 'User');
    await tester.enterText(find.byType(TextField).at(2), 'Test');
    await tester.enterText(find.byType(TextField).at(3), 'Person');
    await tester.enterText(find.byType(TextField).at(4), '771234571');
    await tester.enterText(find.byType(TextField).at(5), 'test-password-123');
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('إنشاء الحساب'));
    await tester.tap(find.text('إنشاء الحساب'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
