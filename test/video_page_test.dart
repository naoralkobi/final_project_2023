import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:final_project_2023/Pages/video_page.dart'; // Replace with your package

void main() {
  testWidgets('YouTubeVideoPlayerPage Widget Test', (WidgetTester tester) async {
    const videoId = 'xyz'; // Replace with your video id

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: YouTubeVideoPlayerPage(videoId: videoId),
      ),
    );

    // Assert
    expect(find.byType(YouTubeVideoPlayerPage), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('YouTube Video Player'), findsOneWidget);
    expect(find.byType(YoutubePlayer), findsOneWidget);
  });
}
