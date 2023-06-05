import 'package:final_project_2023/Pages/video_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../consts.dart';

class YouTubeVideoListPage extends StatefulWidget {
  final String searchQuery;

  YouTubeVideoListPage({required this.searchQuery});

  @override
  _YouTubeVideoListPageState createState() => _YouTubeVideoListPageState();
}

class _YouTubeVideoListPageState extends State<YouTubeVideoListPage> {
  List<dynamic> videos = [];

  @override
  void initState() {
    super.initState();
    fetchYouTubeVideos(widget.searchQuery);
  }

  Future<void> fetchYouTubeVideos(String searchQuery) async {
    String apiKey = GOOGLE_API_KEY;
    String apiUrl = YOUTUBE_SERVER;
    String nextPageToken = '';

    do {
      // Perform a GET request to fetch YouTube videos using the API key, search query, and nextPageToken
      var response = await http.get(Uri.parse(
          '$apiUrl?key=$apiKey&part=snippet&q=$searchQuery&type=video&pageToken=$nextPageToken'
      ));

      if (response.statusCode == 200) {
        // If the response is successful (status code 200), parse the response body as JSON
        var data = jsonDecode(response.body);
        setState(() {
          // Update the state by adding the fetched videos to the videos list
          videos.addAll(data['items']);
          nextPageToken = data['nextPageToken'] ?? '';
        });
      } else {
        throw Exception('Failed to fetch YouTube videos');
      }
    } while (nextPageToken.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Videos'),
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          var video = videos[index];
          var title = video['snippet']['title'];
          var thumbnailUrl = video['snippet']['thumbnails']['default']['url'];
          var videoId = video['id']['videoId'];

          return ListTile(
            leading: Image.network(thumbnailUrl),
            title: Text(title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => YouTubeVideoPlayerPage(videoId: videoId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
