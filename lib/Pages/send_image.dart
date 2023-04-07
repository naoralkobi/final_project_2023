import 'dart:io';
import 'package:flutter/material.dart';

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
          title: Text('Send Image'),
        ),
      ),
      body: Center(
        child:Image.file(widget.imageFile),
      ),
      floatingActionButton:FloatingActionButton(
          child: Icon(Icons.send_outlined,color: Colors.white,size: 22,),
          backgroundColor: Color(0xFFA66CB7),
          elevation: 0,
          onPressed: () => Navigator.pop(context,[true])
      ),
    );
  }
}