import 'dart:async';

import 'package:flutter/material.dart';
import 'package:final_project_2023/screen_size_config.dart';
import '../Widgets/ChooseLanguage.dart';

class StartChat extends StatefulWidget {
  StreamController<List<double>> blurController;
  StartChat(this.blurController);
  @override
  StartChatState createState() {
    return new StartChatState();
  }
}
class StartChatState extends State<StartChat> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical*45),
      child: new Dialog(
        shape: RoundedRectangleBorder(
            side: BorderSide(
                color: Colors.grey,
                width: 2),
            borderRadius: BorderRadius.circular(18.0)),
        child: Container(
          height: SizeConfig.blockSizeVertical*20,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFB9D9EB)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(10.0),
                  ),
                ),
                onPressed: (){
                  Navigator.pop(context);
                  // showDialog(
                  //     barrierColor: Colors.transparent,
                  //     context: context,
                  //     builder: (BuildContext context) {
                  //       widget.blurController.add([1.5,1.5]);
                  //       return ChooseLanguage(true,{},blurController: widget.blurController,);
                  //     })
                  //     .then((value) => {
                  //   widget.blurController.add([0,0])
                  // });
                },
                child: Text("+ Start chat with random", style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 18,),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFB9D9EB)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(10.0),
                  ),
                ),
                onPressed: (){
                  Navigator.pop(context);
                  // showDialog(
                  //     barrierColor: Colors.transparent,
                  //     context: context,
                  //     builder: (BuildContext context) {
                  //       widget.blurController.add([1.5,1.5]);
                  //       return ChooseLanguage(false,{});
                  //     })
                  //     .then((value) => {
                  //   widget.blurController.add([0,0])
                  // });
                },
                child: Text("+ Start chat with a friend", style: TextStyle( fontSize: 18)),),
            ],
          ),
        ),
      ),
    );
  }
}