import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/screen_size_config.dart';


class GameSummaryRow extends StatelessWidget {
  Map question;
  Icon correctIcon =  Icon(
    Icons.check,
    color: Colors.green,
    size: SizeConfig.blockSizeHorizontal * 7,
  );
  Icon wrongIcon = Icon(
    Icons.close,
    color: Colors.red,
    size: SizeConfig.blockSizeHorizontal * 7,
  );
  GameSummaryRow(this.question);

  @override
  Widget build(BuildContext context) {
    Icon user1Icon;
    Icon user2Icon;
    if (question["user1Answer"] == question["correctAnswer"]) {
      user1Icon = correctIcon;
    } else {
      user1Icon = wrongIcon;
    }
    if (question["user2Answer"] == question["correctAnswer"]) {
      user2Icon = correctIcon;
    } else {
      user2Icon = wrongIcon;
    }
    return ListTile(
      title: Row(
        children: [
          SizedBox(width: SizeConfig.blockSizeHorizontal*3,),
          Text(
            "Q${question["questionNumber"]}",
            style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 6),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal*19,),
          user1Icon,
          SizedBox(width: SizeConfig.blockSizeHorizontal*33,),
          user2Icon,
        ],
      ),
    );
  }
}
