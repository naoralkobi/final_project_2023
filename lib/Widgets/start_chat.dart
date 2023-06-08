import 'dart:async';

import 'package:flutter/material.dart';
import 'package:final_project_2023/screen_size_config.dart';
import '../Widgets/choose_language.dart';

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
    return Dialog(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.blueAccent, width: 2),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SizedBox(
        height: SizeConfig.blockSizeVertical * 20,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15), backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  barrierColor: Colors.transparent,
                  context: context,
                  builder: (BuildContext context) {
                    widget.blurController.add([1.5, 1.5]);
                    return ChooseLanguage(
                      true,
                      {},
                      blurController: widget.blurController,
                    );
                  },
                ).then((value) => widget.blurController.add([0, 0]));
              },
              child: const Text("+ Start chat with random", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15), backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  barrierColor: Colors.transparent,
                  context: context,
                  builder: (BuildContext context) {
                    widget.blurController.add([1.5, 1.5]);
                    return ChooseLanguage(false, {});
                  },
                ).then((value) => widget.blurController.add([0, 0]));
              },
              child: const Text("+ Start chat with a friend", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}