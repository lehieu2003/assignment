import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-To-End App Flow Integration Test', () {
    testWidgets('App launches and displays Auth/Login or Home view', (WidgetTester tester) async {
      // 1. Launch the application
      app.main();
      await tester.pumpAndSettle();

      // 2. Verify that base MaterialApp is present
      expect(find.byType(MaterialApp), findsOneWidget);

      // 3. Verify either Login elements or Splash / Home elements are rendered
      final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Đăng nhập');
      final appTitleFinder = find.text('Todo List');

      // The app will display either the login screen or home screen depending on stored tokens
      expect(
        loginButtonFinder.evaluate().isNotEmpty || appTitleFinder.evaluate().isNotEmpty,
        isTrue,
      );
    });
  });
}
