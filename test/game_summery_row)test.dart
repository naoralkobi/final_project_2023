import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/Widgets/game_summary_row.dart';
import 'package:final_project_2023/screen_size_config.dart';

void main() {

  testWidgets('GameSummaryRow shows correct icons', (WidgetTester tester) async {
    // Build the GameSummaryRow widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameSummaryRow({
            "questionNumber": 1,
            "correctAnswer": "a",
            "user1Answer": "a",
            "user2Answer": "b",
          }),
        ),
      ),
    );

    // Check that user1 answer icon is correctIcon
    expect(find.byIcon(Icons.check), findsOneWidget);

    // Check that user2 answer icon is wrongIcon
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
