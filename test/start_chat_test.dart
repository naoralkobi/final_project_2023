import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project_2023/Widgets/start_chat.dart';

void main() {
  StreamController<List<double>>? blurController;

  setUp(() {
    blurController = StreamController<List<double>>();
  });

  tearDown(() {
    blurController?.close();
    blurController = null;
  });

  Future<void> _buildStartChatWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StartChat(blurController!),
      ),
    );
  }

  group('StartChat', () {
    testWidgets('should display dialog with buttons', (WidgetTester tester) async {
      await _buildStartChatWidget(tester);

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(2));
      expect(find.text('+ Start chat with random'), findsOneWidget);
      expect(find.text('+ Start chat with a friend'), findsOneWidget);
    });

    testWidgets('should have clickable "+ Start chat with random" button', (WidgetTester tester) async {
      await _buildStartChatWidget(tester);

      // Check the "+ Start chat with random" button is clickable.
      expect(tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, '+ Start chat with random')).onPressed, isNotNull);
    });

    testWidgets('should have clickable "+ Start chat with a friend" button', (WidgetTester tester) async {
      await _buildStartChatWidget(tester);

      // Check the "+ Start chat with a friend" button is clickable.
      expect(tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, '+ Start chat with a friend')).onPressed, isNotNull);
    });
  });
}
