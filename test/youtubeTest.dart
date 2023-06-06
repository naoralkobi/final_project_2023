import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:final_project_2023/Pages/videoLearningPage.dart'; // Import your page

void main() {
  testWidgets('YouTubeVideoListPage has a ListView', (WidgetTester tester) async {
    // Build the YouTubeVideoListPage widget.
    await tester.pumpWidget(MaterialApp(home: YouTubeVideoListPage(searchQuery: 'flutter tutorial')));

    // Let the responses come.
    await tester.pumpAndSettle();

    // YouTubeVideoListPage should have a ListView.
    expect(find.byType(ListView), findsOneWidget);
  });
  // test('fetchYouTubeVideos returns a list of videos for a valid query', () async {
  //   // Set up
  //   var page = YouTubeVideoListPage(searchQuery: 'flutter tutorial');
  //
  //   // Act
  //   await page.fetchYouTubeVideos('flutter tutorial');
  //
  //   // Assert
  //   expect(page.videos, isNotEmpty);
  // });
  //
  // test('fetchYouTubeVideos throws an exception for an invalid query', () async {
  //   // Set up
  //   var page = YouTubeVideoListPage(searchQuery: 'invalid query');
  //
  //   // Assert that the function throws an Exception
  //   expect(page.fetchYouTubeVideos('invalid query'), throwsA(isA<Exception>()));
  // });
}
