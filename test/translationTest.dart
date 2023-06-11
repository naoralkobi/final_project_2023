import 'package:flutter_test/flutter_test.dart';
import 'package:final_project_2023/Pages/google_translate.dart';
import 'package:flutter/material.dart';

void main() {
  Widget makeTestableWidget({required Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('Translation Screen UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(child: TranslationScreen()));

    // Verify the existence of certain widgets
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Translation'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Enter word'), findsOneWidget);
    expect(find.text('Source Language'), findsOneWidget);
    expect(find.text('Target Language'), findsOneWidget);
    expect(find.text('Translate'), findsOneWidget);

    // Enter text in TextField
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();

    // Verify TextField content
    expect(find.text('Hello'), findsOneWidget);

    // Test the button by verifying a callback when pressed
    var button = find.text('Translate');
    expect(button, findsOneWidget);
    //await tester.tap(button);
    await tester.pumpAndSettle();
    // Note: We cannot test the translated text as it's returned from an async operation which requires mocking
  });
}
