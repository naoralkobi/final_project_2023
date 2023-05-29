import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_2023/Pages/winner_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:final_project_2023/Pages/WinnerPage.dart';
import 'package:final_project_2023/Pages/createProfilePage.dart';
import 'package:final_project_2023/Pages/register_page.dart';
import 'package:final_project_2023/screen_size_config.dart';
import 'package:final_project_2023/firebase/auth_repository.dart';
import '../consts.dart';
// import 'GameSummaryPage.dart';
import 'package:final_project_2023/Pages/home_page.dart';
import 'dart:async';
import 'package:page_transition/page_transition.dart';

class QuestionsPage extends StatefulWidget {
  String chatId;
  String gameId;
  Map userInfo;
  Map opponentInfo;
  int questionNumber;
  int userNumber;
  String inviteID;

  QuestionsPage(this.chatId, this.gameId, this.userInfo, this.opponentInfo,
      this.questionNumber, this.userNumber, this.inviteID);

  @override
  _QuestionsPageState createState() => _QuestionsPageState(this.opponentInfo);
}

class _QuestionsPageState extends State<QuestionsPage>
    with SingleTickerProviderStateMixin {
  int groupValue = -1;
  String? opponentAnswer;
  List? answers;
  String? correctAnswer;
  String? questionType;
  String? questionBody;
  Map opponentInfo;
  Timer? _timer;
  int _start = 10;
  bool? firstShuffle;

  _QuestionsPageState(this.opponentInfo);

  @override
  void initState() {
    super.initState();
    if (widget.userNumber == 1) {
      opponentAnswer = "user2Answer";
    } else {
      opponentAnswer = "user1Answer";
    }
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    firstShuffle = true;
    startTimer();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("games")
            .doc(widget.gameId)
            .snapshots(),
        builder: (BuildContext buildContext, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return Text("There has been an error");

          if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null)
            return Center(child: CircularProgressIndicator());

          Map? questionData = getQuestionByNum(snapshot.data!.data()! as Map<dynamic, dynamic>, widget.questionNumber);

          if (answers == null) {
            answers = questionData!["answers"];
          }

          if (firstShuffle!) {
            answers = shuffle(answers!);
            firstShuffle = false;
          }
          correctAnswer = questionData!["correctAnswer"];

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
                    padding: EdgeInsets.only(right: SizeConfig.blockSizeVertical * 4),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: SizeConfig.blockSizeVertical * 0.1),
                        SizedBox(width: SizeConfig.blockSizeVertical * 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Question " + widget.questionNumber.toString(),
                                style: TextStyle(
                                    fontSize: SizeConfig.blockSizeVertical * 4.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                              SizedBox(height: 3),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                SizedBox(height: SizeConfig.blockSizeVertical * 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeVertical * 2),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "${_start} sec",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.blockSizeVertical * 3),
                          ),
                        ],
                      ),
                      SizedBox(height: SizeConfig.blockSizeVertical * 1),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: (_start) / 10,
                          backgroundColor: Colors.grey,
                          valueColor: AlwaysStoppedAnimation<Color>(_start > 5 ? Colors.yellow : Colors.red),
                          minHeight: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical * 2),
                Container(
                  child: questionData[opponentAnswer] == ""
                      ? Center(
                    child: Text(
                      "Your enemy is still Thinking...",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  )
                      : Center(
                    child: Text("Your enemy Answered!", style: TextStyle(color: Colors.grey[700])),
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical * 4),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: Colors.grey[400]!,
                        style: BorderStyle.solid,
                        width: 1.0
                    ),
                  ),
                  child: Column(
                    children: [
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
                      SizedBox(height: SizeConfig.blockSizeVertical * 2),
                      getBodyWidget(questionData["type"], questionData["questionBody"]),
                      SizedBox(height: SizeConfig.blockSizeVertical * 1),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: answers!.length,
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
                                  color: chooseColor(index),
                                  border: Border.all(
                                      color: Colors.grey,
                                      style: BorderStyle.solid,
                                      width: 0.80),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 0.5,
                                      blurRadius: 2,
                                      offset:
                                      Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: RadioListTile(
                                    value: index,
                                    title: Text(
                                      answers![index],
                                      style: TextStyle(
                                          fontSize:
                                          SizeConfig.blockSizeVertical * 2.5),
                                    ),
                                    activeColor: Colors.black,
                                    groupValue: groupValue,
                                    onChanged: (int? val) {
                                      if (mounted)
                                        setState(() {
                                          groupValue = val!;
                                          updateFirebase(
                                              snapshot.data!.data()! as Map<dynamic, dynamic>, answers![val]);

                                        });
                                    })),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  /// original build!
  // @override
  // Widget build(BuildContext context) {
  //   SizeConfig().init(context);
  //   return StreamBuilder(
  //       stream: FirebaseFirestore.instance
  //           .collection("games")
  //           .doc(widget.gameId)
  //           .snapshots(),
  //       builder: (BuildContext buildContext,
  //           AsyncSnapshot<DocumentSnapshot> snapshot) {
  //         if (snapshot.hasError) return Text("There has been an error");
  //         //if connecting show progressIndicator
  //         if (snapshot.connectionState == ConnectionState.waiting &&
  //             snapshot.data == null) return Center(child: SizedBox());
  //         Map? questionData =
  //         getQuestionByNum(snapshot.data!.data()! as Map<dynamic, dynamic>, widget.questionNumber);
  //         if (answers == null) {
  //           answers = questionData!["answers"];
  //         }
  //         if (firstShuffle!) {
  //           answers = shuffle(answers!);
  //           firstShuffle = false;
  //         }
  //         correctAnswer = questionData!["correctAnswer"];
  //
  //         return Scaffold(
  //           appBar: PreferredSize(
  //             preferredSize: Size.fromHeight(70),
  //             child: AppBar(
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.vertical(
  //                   bottom: Radius.circular(18.0),
  //                 ),
  //               ),
  //               automaticallyImplyLeading: false,
  //               flexibleSpace: SafeArea(
  //                 child: Container(
  //                   padding: EdgeInsets.only(
  //                       right: SizeConfig.blockSizeVertical * 4),
  //                   child: Row(
  //                     children: <Widget>[
  //                       SizedBox(
  //                         width: SizeConfig.blockSizeVertical * 0.1,
  //                       ),
  //                       SizedBox(
  //                         width: SizeConfig.blockSizeVertical * 2,
  //                       ),
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.center,
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: <Widget>[
  //                             Text(
  //                               "Question " + widget.questionNumber.toString(),
  //                               style: TextStyle(
  //                                   fontSize:
  //                                   SizeConfig.blockSizeVertical * 4.5,
  //                                   fontWeight: FontWeight.w600,
  //                                   color: Colors.white),
  //                             ),
  //                             SizedBox(
  //                               height: 3,
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           body: Column(
  //             children: [
  //               SizedBox(
  //                 height: SizeConfig.blockSizeVertical * 4,
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                 children: [
  //                   Stack(
  //                     children: [
  //                       Opacity(
  //                           opacity: 0.2,
  //                           child: Icon(
  //                             Icons.timer_rounded,
  //                             size: SizeConfig.blockSizeVertical * 11,
  //                           )),
  //                       Positioned(
  //                         bottom: SizeConfig.blockSizeVertical * 2.5,
  //                         right: _start > 9
  //                             ? SizeConfig.blockSizeHorizontal * 5.5
  //                             : SizeConfig.blockSizeHorizontal * 8.3,
  //                         child: Text(
  //                           _start.toString(),
  //                           style: TextStyle(
  //                               fontSize: SizeConfig.blockSizeVertical * 4.7,
  //                               fontWeight: FontWeight.bold,
  //                               color: _start > 5
  //                                   ? Colors.black
  //                                   : Colors.red[500]),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Padding(
  //                     padding: EdgeInsets.only(
  //                         top: SizeConfig.blockSizeVertical * 2),
  //                     child: Container(
  //                         height: SizeConfig.blockSizeVertical * 6.5,
  //                         width: SizeConfig.blockSizeVertical * 18.5,
  //                         // padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(14.0),
  //                           color: Colors.white,
  //                           border: Border.all(
  //                               color: Colors.grey,
  //                               style: BorderStyle.solid,
  //                               width: 0.80),
  //                         ),
  //                         child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                             children: [
  //                               CircleAvatar(
  //                                   backgroundColor: Colors.grey,
  //                                   radius: SizeConfig.blockSizeVertical * 2.1,
  //                                   child: CircleAvatar(
  //                                     backgroundColor: Colors.white,
  //                                     radius: SizeConfig.blockSizeVertical * 2,
  //                                     backgroundImage: NetworkImage(
  //                                         widget.opponentInfo["URL"]),
  //                                   )),
  //                               Center(
  //                                 child: questionData[opponentAnswer] == ""
  //                                     ? Text(
  //                                   "Thinking...",
  //                                   style: TextStyle(
  //                                       color: Colors.grey[700]),
  //                                 )
  //                                     : Text("Answered!",
  //                                     style: TextStyle(
  //                                         color: Colors.grey[700])),
  //                               )
  //                             ])),
  //                   )
  //                 ],
  //               ),
  //               SizedBox(
  //                 height: SizeConfig.blockSizeVertical * 4,
  //               ),
  //               Container(
  //                 width: SizeConfig.screenWidth * 0.7,
  //                 child: FittedBox(
  //                   fit: BoxFit.scaleDown,
  //                   child: SizedBox(
  //                     child: Text(
  //                       questionData["type"] + ":",
  //                       style: TextStyle(
  //                           fontSize: SizeConfig.blockSizeVertical * 4,
  //                           fontWeight: FontWeight.bold),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: SizeConfig.blockSizeVertical * 2,
  //               ),
  //               getBodyWidget(
  //                   questionData["type"], questionData["questionBody"]),
  //               SizedBox(
  //                 height: SizeConfig.blockSizeVertical * 1,
  //               ),
  //               ListView.builder(
  //                 shrinkWrap: true,
  //                 itemCount: answers!.length,
  //                 itemBuilder: (context, index) {
  //                   return Padding(
  //                     padding: EdgeInsets.fromLTRB(
  //                         SizeConfig.screenWidth * 0.1,
  //                         SizeConfig.blockSizeVertical * 3,
  //                         SizeConfig.screenWidth * 0.1,
  //                         0),
  //                     child: Container(
  //                         height: SizeConfig.blockSizeVertical * 7,
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(14.0),
  //                           color: chooseColor(index),
  //                           border: Border.all(
  //                               color: Colors.grey,
  //                               style: BorderStyle.solid,
  //                               width: 0.80),
  //                           boxShadow: [
  //                             BoxShadow(
  //                               color: Colors.grey.withOpacity(0.3),
  //                               spreadRadius: 0.5,
  //                               blurRadius: 2,
  //                               offset:
  //                               Offset(0, 4), // changes position of shadow
  //                             ),
  //                           ],
  //                         ),
  //                         child: RadioListTile(
  //                             value: index,
  //                             title: Text(
  //                               answers![index],
  //                               style: TextStyle(
  //                                   fontSize:
  //                                   SizeConfig.blockSizeVertical * 2.5),
  //                             ),
  //                             activeColor: Colors.black,
  //                             groupValue: groupValue,
  //                             onChanged: (int? val) {
  //                               if (mounted)
  //                                 setState(() {
  //                                   groupValue = val!;
  //                                   updateFirebase(
  //                                       snapshot.data!.data()! as Map<dynamic, dynamic>, answers![val]);
  //
  //                                 });
  //                             })),
  //                   );
  //                 },
  //               )
  //             ],
  //           ),
  //         );
  //       });
  // }

  Color? chooseColor(int index) {
    if (groupValue == index) {
      return Color(0xFFB9D9EB);
    }
    return Colors.white;
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    _timer = new Timer.periodic(
      oneSec,
          (Timer? timer) {
        if (!mounted) return;
        if (_start == 0) {
          if (widget.questionNumber == 5) {
            finishedGame();
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeftWithFade,
                    child: WinnerPage(
                        widget.gameId, widget.userInfo, opponentInfo)));
          } else {
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeftWithFade,
                    child: QuestionsPage(
                        widget.chatId,
                        widget.gameId,
                        widget.userInfo,
                        opponentInfo,
                        widget.questionNumber + 1,
                        widget.userNumber,
                        widget.inviteID)));
          }
          setState(() {
            timer!.cancel();
            timer = null;
            _timer!.cancel();
            _timer = null;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  List shuffle(List items) {
    var random = new Random();
    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {
      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }
    return items;
  }

  Map? getQuestionByNum(Map game, int num) {
    for (var q in game["questions"]) {
      if (q["questionNumber"] == num) {
        return q;
      }
    }
  }

  void updateFirebase(Map oldData, String answer) {
/*
    List newData = [];
    String userAnswer = "";
    if (widget.userNumber == 1) {
      userAnswer = "user1Answer";
    } else {
      userAnswer = "user2Answer";
    }
    for (Map q in oldData["questions"]) {
      if (q["questionNumber"] == widget.questionNumber) {
        Map temp = q;
        temp[userAnswer] = answer;
        newData.add(temp);
      } else {
        newData.add(q);
      }
    }
    FirebaseFirestore.instance
        .collection("games")
        .doc(widget.gameId)
        .update({"questions": newData});
*/
    String userAnswer = "user" + widget.userNumber.toString() +"Answer";
    List newData = [];
    DocumentReference documentReference = FirebaseFirestore.instance.collection("games").doc(widget.gameId);
    FirebaseFirestore.instance.
    runTransaction((transaction) async{
      await transaction.get(documentReference).then((value) {
/*        for (Map q in value["questions"]) {
          if (q["questionNumber"] == widget.questionNumber) {
            Map temp = q;
            temp[userAnswer] = answer;
            newData.add(temp);
          } else {
            newData.add(q);
          }
        }*/
        List questions = value["questions"];
        Map oldAnswer = questions[widget.questionNumber-1];
        oldAnswer[userAnswer] = answer;
        questions[widget.questionNumber-1] = oldAnswer;
        transaction.update(documentReference, {
          "questions" : questions
        });
      });
    });
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
            fit: BoxFit.cover,
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

  finishedGame() {
    FirebaseFirestore.instance
        .collection(CHATS)
        .doc(widget.chatId)
        .update({"acceptedInviteUID": "", "currentGame": "", INVITE_ID: ""});
    FirebaseFirestore.instance
        .collection(CHATS)
        .doc(widget.chatId)
        .collection(MESSAGES_COLLECTION)
        .doc(widget.inviteID)
        .update({
      MESSAGE_TYPE: MESSAGE_TYPE_GAME_SUMMARY,
      MESSAGE_CONTENT: widget.gameId
    });
  }
}