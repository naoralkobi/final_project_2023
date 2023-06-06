import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A widget to show an image either from a network URL or a local file path.
class ShowImage extends StatefulWidget {
  final dynamic imageUrl; // The image URL or file path
  final dynamic tag; // A unique tag to identify the image for Hero animation
  String title; // The title of the image (optional)
  bool isURL; // Indicates whether the image is from a URL or a local file path

  /// Constructs a [ShowImage] widget.
  ///
  /// The [imageUrl] parameter is the image URL or file path.
  /// The [tag] parameter is a unique tag to identify the image for Hero animation.
  /// The [title] parameter is the title of the image (optional).
  /// The [isURL] parameter indicates whether the image is from a URL or a local file path.
  ShowImage({
    required this.imageUrl,
    required this.tag,
    this.title = "image",
    this.isURL = true,
  });

  @override
  State<StatefulWidget> createState() => ShowImageState();
}

/// The state for the [ShowImage] widget.
class ShowImageState extends State<ShowImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.transparent,
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: widget.tag,
          child: widget.isURL
              ? CachedNetworkImage(
            imageUrl: widget.imageUrl,
          )
              : Image.file(widget.imageUrl),
        ),
      ),
    );
  }
}
