import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:final_project_2023/screen_size_config.dart';

import '../consts.dart';

class FullGameSummaryPage extends StatefulWidget {
  Map gameData;
  Map user1Info;
  Map user2Info;

  FullGameSummaryPage(this.gameData, this.user1Info, this.user2Info);

  @override
  _FullGameSummaryPageState createState() => _FullGameSummaryPageState();
}

class _FullGameSummaryPageState extends State<FullGameSummaryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(18.0),
            ),
          ),
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Container(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 2,
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                      iconSize: SizeConfig.blockSizeHorizontal * 8,
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Full Summary",
                          style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal * 6,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return questionSummaryWidget(widget.gameData["questions"][index]);
          }),
    );
  }

  Widget questionSummaryWidget(Map questionData) {
    int correctIndex = -1;
    for (int i = 0; i < 4; i++) {
      if (questionData["answers"][i] == questionData["correctAnswer"]) {
        correctIndex = i;
      }
    }
    return Container(
      height: SizeConfig.screenHeight * 0.89,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: SizeConfig.blockSizeVertical * 1,
          ),
          Text("Q" + questionData["questionNumber"].toString() ,
              style: TextStyle(
                  fontSize: SizeConfig.blockSizeVertical * 4.5,
                  color: Color(0xFF6D94BE))),
          SizedBox(
            height: SizeConfig.blockSizeVertical * 3.5,
          ),
          Container(
            width: SizeConfig.screenWidth * 0.7,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                child: Text(
                  questionData["type"] + ":",
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeVertical * 4,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(
            height: SizeConfig.blockSizeVertical * 2,
          ),
          getBodyWidget(questionData["type"], questionData["questionBody"]),
          // SizedBox(
          //   height: SizeConfig.blockSizeVertical * 1,
          // ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: questionData["answers"]!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                    SizeConfig.screenWidth * 0.1,
                    SizeConfig.blockSizeVertical * 3,
                    SizeConfig.screenWidth * 0.1,
                    0),
                child: Container(
                    height: SizeConfig.blockSizeVertical * 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.0),
                      color: chooseColor(index, correctIndex),
                      border: Border.all(
                          color: Colors.grey,
                          style: BorderStyle.solid,
                          width: 0.80),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 0.5,
                          blurRadius: 2,
                          offset: Offset(0, 4), // changes position of shadow
                        ),
                      ],
                    ),
                    child: RadioListTile(
                        value: index,
                        title: Text(
                          questionData["answers"]![index],
                          style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical * 2.5),
                        ),
                        activeColor: Colors.black,
                        groupValue: correctIndex,
                        onChanged: (var val) {})),
              );
            },
          ),
          SizedBox(
            height: SizeConfig.blockSizeVertical * 3.5,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                getUserAnswer(widget.user1Info, questionData["user1Answer"],
                    questionData["correctAnswer"]),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                getUserAnswer(widget.user2Info, questionData["user2Answer"],
                    questionData["correctAnswer"]),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getBodyWidget(String type, String body) {
    if (type == "What's in the picture") {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
          border: Border.all(
              color: Colors.grey, style: BorderStyle.solid, width: 0.80),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            body,
            fit: BoxFit.fitHeight,
            height: SizeConfig.blockSizeVertical * 15,
            width: SizeConfig.blockSizeVertical * 15,
          ),
        ),
      );
    } else {
      return Container(
        width: SizeConfig.screenWidth * 0.7,
        height: SizeConfig.blockSizeVertical * 15,
        child: Center(
          child: AutoSizeText(
            body,
            style: TextStyle(
              fontSize: SizeConfig.blockSizeVertical * 7,
            ),
            maxLines: 3, // you can change it accordingly
            // overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
  }

  Color? chooseColor(int currIndex, int correctIndex) {
    if (currIndex == correctIndex) {
      return Colors.green[300];
    }
    return Colors.white;
  }

  Widget getUserAnswer(Map userInfo, String userAnswer, String correctAnswer) {
    return Column(
      children: [
        Row(
          children: [
            Column(children: [
              CircleAvatar(
                radius: SizeConfig.blockSizeHorizontal * 5,
                backgroundImage: NetworkImage(userInfo["URL"]),
              ),
              // SizedBox(
              //   height: SizeConfig.screenHeight * 0.02,
              // ),
              Container(
                width: SizeConfig.screenWidth * 0.15,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    child: Text(
                      userInfo[USERNAME],
                      style: TextStyle(
                          fontSize: SizeConfig.screenWidth * 0.04,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 1.2,
        ),
        RichText(
          text: TextSpan(
            // Note: Styles for TextSpans must be explicitly defined.
            // Child text spans will inherit styles from parent
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal * 4,
              color: Colors.black,
            ),
            children: <TextSpan>[
              TextSpan(text: 'Answered: '),
              TextSpan(
                  text: '"' + userAnswer + '"',
                  style: new TextStyle(
                      color: userAnswer == correctAnswer
                          ? Colors.green[300]
                          : Colors.red[300])),
            ],
          ),
        )
      ],
    );
  }
}
