import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/Pages/show_image.dart'; // Replace this with the actual path to your file

void main() {
  testWidgets('ShowImage Widget Test', (WidgetTester tester) async {
    // Build the ShowImage widget
    await tester.pumpWidget(
      MaterialApp(
        home: ShowImage(
          imageUrl: 'https://via.placeholder.com/150',
          tag: 'testTag',
          title: 'TestTitle',
          isURL: true,
        ),
      ),
    );

    // Verify if ShowImage is rendered without any errors
    expect(find.byType(ShowImage), findsOneWidget);

    // Verify if AppBar is present
    expect(find.byType(AppBar), findsOneWidget);

    // Verify if title is correctly displayed in AppBar
    expect(find.widgetWithText(AppBar, 'TestTitle'), findsOneWidget);
  });
}
