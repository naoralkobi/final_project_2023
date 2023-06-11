import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/Pages/send_image.dart'; // Replace this with the actual path to your file

void main() {
  testWidgets('SendImage Widget Test', (WidgetTester tester) async {
    // Create a placeholder image file
    final imageFile = File('assets/images/app_logo.png'); // Add a placeholder image in your test assets

    // Build the SendImage widget
    await tester.pumpWidget(
      MaterialApp(
        home: SendImage(imageFile: imageFile),
      ),
    );

    // Verify if SendImage is rendered without any errors
    expect(find.byType(SendImage), findsOneWidget);

    // Verify if AppBar is present
    expect(find.byType(AppBar), findsOneWidget);

    // Verify if AppBar title is correct
    expect(find.widgetWithText(AppBar, 'Send Image'), findsOneWidget);

    // Verify if FloatingActionButton is present
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Simulate a tap on the FloatingActionButton
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Expect that after the tap, the widget is removed from the tree, indicating that it has been popped off the stack
    expect(find.byType(SendImage), findsNothing);
  });
}
