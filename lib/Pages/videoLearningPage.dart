import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
    String apiKey = 'AIzaSyC_-_XeUsGfdBt4h1fx2ZYYdEC_K_aFAOY';
    String apiUrl = 'https://www.googleapis.com/youtube/v3/search';
    String nextPageToken = ''; // Add this line

    do {
      var response = await http.get(Uri.parse(
          '$apiUrl?key=$apiKey&part=snippet&q=$searchQuery&type=video&pageToken=$nextPageToken'
      ));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          videos.addAll(data['items']);
          nextPageToken = data['nextPageToken'] ?? ''; // Add this line
        });
      } else {
        throw Exception('Failed to fetch YouTube videos');
      }
    } while (nextPageToken.isNotEmpty); // Add this line
  }

  // Future<void> fetchYouTubeVideos(String searchQuery) async {
  //   String apiKey = 'AIzaSyC_-_XeUsGfdBt4h1fx2ZYYdEC_K_aFAOY';
  //   String apiUrl = 'https://www.googleapis.com/youtube/v3/search';
  //
  //   var response = await http.get(Uri.parse(
  //       '$apiUrl?key=$apiKey&part=snippet&q=$searchQuery&type=video'
  //   ));
  //
  //   if (response.statusCode == 200) {
  //     var data = jsonDecode(response.body);
  //     setState(() {
  //       videos = data['items'];
  //     });
  //   } else {
  //     throw Exception('Failed to fetch YouTube videos');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Videos'),
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

class YouTubeVideoPlayerPage extends StatelessWidget {
  final String videoId;

  YouTubeVideoPlayerPage({required this.videoId});

  @override
  Widget build(BuildContext context) {
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Video Player'),
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          progressColors: ProgressBarColors(
            playedColor: Colors.red,
            handleColor: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
