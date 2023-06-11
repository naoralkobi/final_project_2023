import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project_2023/Pages/video_learning_page.dart'; // Replace with your package

void main() {
  testWidgets('YouTubeVideoListPage Widget Test', (WidgetTester tester) async {
    const searchQuery = 'Test'; // Replace with your query

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: YouTubeVideoListPage(searchQuery: searchQuery),
      ),
    );

    // Assert
    expect(find.byType(YouTubeVideoListPage), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('YouTube Videos'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });
}
