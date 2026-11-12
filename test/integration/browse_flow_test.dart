import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:souq_taiz/app/app.dart';
import 'package:souq_taiz/app/router/app_router.dart';

/// Browse workflows against the in-memory DEMO repositories (Firebase not
/// configured). These run under `flutter test`; emulator-backed end-to-end
/// tests are described in docs/setup/local-development.md.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: SouqTaizApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('home shows demo banner, categories and listings', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.textContaining('وضع العرض التجريبي'), findsOneWidget);
    expect(find.text('عقارات'), findsWidgets);
    expect(find.text('تويوتا كورولا 2015 نظيفة'), findsWidgets);
  });

  testWidgets('category -> search -> listing details', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('جوالات').first);
    await tester.pumpAndSettle();
    expect(find.text('آيفون 13 بحالة ممتازة'), findsWidgets);
    expect(find.text('تويوتا كورولا 2015 نظيفة'), findsNothing);

    await tester.tap(find.text('آيفون 13 بحالة ممتازة').first);
    await tester.pumpAndSettle();
    expect(find.text('تواصل عبر واتساب'), findsOneWidget);
    expect(find.text('مراسلة البائع'), findsOneWidget);
  });

  testWidgets('keyword search from the header filters results', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.byType(TextField).first, 'لابتوب');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('لابتوب ديل i5 جيل عاشر'), findsWidgets);
    expect(find.text('غرفة نوم كاملة'), findsNothing);
  });

  testWidgets('guests are redirected from protected routes to login', (
    tester,
  ) async {
    await pumpApp(tester);
    final context = tester.element(find.byType(Scaffold).first);
    ProviderScope.containerOf(context).read(appRouterProvider).go('/favorites');
    await tester.pumpAndSettle();
    expect(find.text('تسجيل الدخول'), findsWidgets);
    expect(find.text('لم تضف أي إعلان إلى المفضلة.'), findsNothing);
  });

  testWidgets('language switch flips direction', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(
      Directionality.of(tester.element(find.byType(Scaffold).first)),
      TextDirection.ltr,
    );
    expect(find.text('Latest listings'), findsOneWidget);
  });
}
