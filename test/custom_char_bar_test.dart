import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/Widgets/custom_chat_bar.dart';  // Assuming your shapes are in this file

void main() {
  group('Custom Shape Widgets', () {
    testWidgets('CustomChatBar renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Container(
            decoration: ShapeDecoration(
              shape: CustomChatBar(),
              color: Colors.white,
            ),
          ),
        ),
      ));
      final customChatBarFinder = find.byType(Container);
      expect(customChatBarFinder, findsOneWidget);
    });

    testWidgets('CustomShapeBorder renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Container(
            decoration: ShapeDecoration(
              shape: CustomShapeBorder(),
              color: Colors.white,
            ),
          ),
        ),
      ));
      final customShapeBorderFinder = find.byType(Container);
      expect(customShapeBorderFinder, findsOneWidget);
    });

    testWidgets('AppBarBorder renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            shape: AppBarBorder(),
          ),
        ),
      ));
      final appBarBorderFinder = find.byType(AppBar);
      expect(appBarBorderFinder, findsOneWidget);
    });

    testWidgets('ChatAppBar renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            shape: ChatAppBar(),
          ),
        ),
      ));
      final chatAppBarFinder = find.byType(AppBar);
      expect(chatAppBarFinder, findsOneWidget);
    });
  });
}
