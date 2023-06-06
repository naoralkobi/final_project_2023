import 'dart:io';
import 'package:flutter/material.dart';

import '../consts.dart';

class SendImage extends StatefulWidget{
  final File imageFile;
  SendImage({required this.imageFile});
  @override
  State<StatefulWidget> createState() => SendImageState();
}

class SendImageState extends State<SendImage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          title: const Text('Send Image'),
        ),
      ),
      body: Center(
        child:Image.file(widget.imageFile),
      ),
      floatingActionButton:FloatingActionButton(
          backgroundColor: PURPLE_COLOR,
          elevation: 0,
          onPressed: () => Navigator.pop(context,[true]),
          child: const Icon(Icons.send_outlined,color: Colors.white,size: 22,)
      ),
    );
  }
}