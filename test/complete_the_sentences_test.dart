import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project_2023/Pages/complete_the_sentence.dart';

void main() {
  group('CompleteTheSentence', () {
    testWidgets('Widget builds correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CompleteTheSentence(null, null, null),
        ),
      );

      expect(find.text('Complete the Sentence'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(6));
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('Fields are filled and submit button works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CompleteTheSentence(null, null, null),
        ),
      );

      // Fill in the text fields
      await tester.enterText(find.byType(TextFormField).at(0), 'Beginning');
      await tester.enterText(find.byType(TextFormField).at(1), 'End');
      await tester.enterText(find.byType(TextFormField).at(2), 'Answer 1');
      await tester.enterText(find.byType(TextFormField).at(3), 'Answer 2');
      await tester.enterText(find.byType(TextFormField).at(4), 'Answer 3');
      await tester.enterText(find.byType(TextFormField).at(5), 'Answer 4');

      // Tap the submit button
      await tester.tap(find.byType(TextButton));

      // Wait for the dialog to appear
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you would like to submit the question?'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);

      // Tap the Yes button
      await tester.tap(find.text('Yes'));

      // Wait for the dialog to disappear
      await tester.pumpAndSettle();

      // Assert that the fields are cleared
      expect(find.text('Beginning'), findsNothing);
      expect(find.text('End'), findsNothing);
      expect(find.text('Answer 1'), findsNothing);
      expect(find.text('Answer 2'), findsNothing);
      expect(find.text('Answer 3'), findsNothing);
      expect(find.text('Answer 4'), findsNothing);
    });

    testWidgets('Fields are empty and error message is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CompleteTheSentence(null, null, null),
        ),
      );

      // Tap the submit button
      await tester.tap(find.byType(TextButton));

      // Wait for the dialog to appear
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you would like to submit the question?'), findsNothing);
      expect(find.text('No'), findsNothing);
      expect(find.text('Yes'), findsNothing);
      expect(find.text('Fill in all fields'), findsOneWidget);
    });
  });
}
