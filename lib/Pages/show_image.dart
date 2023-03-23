import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class ShowImage extends StatefulWidget{
  final dynamic imageUrl;
  final dynamic tag;
  String title;
  bool isURL;
  ShowImage({required this.imageUrl, required this.tag, this.title = "image", this.isURL = true});
  @override
  State<StatefulWidget> createState() =>ShowImageState();

}
class ShowImageState extends State<ShowImage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.transparent,
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
            tag: widget.tag,
            child: widget.isURL ? CachedNetworkImage(
                imageUrl: widget.imageUrl) :
            Image.file(widget.imageUrl)
        ),
      ),
    );
  }

}