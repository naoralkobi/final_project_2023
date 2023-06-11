import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_2023/Pages/winner_page.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/screen_size_config.dart';
import '../consts.dart';
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

//  SingleTickerProviderStateMixin - to provide an animation ticker for animations within the state.
class _QuestionsPageState extends State<QuestionsPage>
    with SingleTickerProviderStateMixin {
  int groupValue = GROUP_VALUE_DEFAULT;
  String? opponentAnswer;
  List? answers;
  String? correctAnswer;
  String? questionType;
  String? questionBody;
  Map opponentInfo;
  Timer? _timer;
  int _start = TIMER_START;
  bool? firstShuffle;

  _QuestionsPageState(this.opponentInfo);

  @override
  void initState() {
    super.initState();
    if (widget.userNumber == USER_1_NUMBER) {
      opponentAnswer = USER_2_ANSWER;
    } else {
      opponentAnswer = USER_1_ANSWER;
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
            .collection(GAMES)
            .doc(widget.gameId)
            .snapshots(),
        builder: (BuildContext buildContext, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return const Text(ERROR_MESSAGE);

          if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          // get the question by question number.
          Map? questionData = getQuestionByNum(snapshot.data!.data()! as Map<dynamic, dynamic>, widget.questionNumber);
          // set answer to questionData![ANSWERS] if and only if answer is null.
          answers ??= questionData![ANSWERS];

          if (firstShuffle!) {
            answers = shuffle(answers!);
            firstShuffle = false;
          }
          correctAnswer = questionData![CORRECT_ANSWER];

          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: AppBar(
                shape: const RoundedRectangleBorder(
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
                                "Question ${widget.questionNumber}",
                                style: TextStyle(
                                    fontSize: SizeConfig.blockSizeVertical * 4.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 3),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            /// TIMER:
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
                            "$_start sec",
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
                        // timer indicator.
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
                // Check if the opponent already answered his question!
                Container(
                  child: questionData[opponentAnswer] == ""
                      ? Center(
                    child: Text(
                      "Your opponent is still Thinking...",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  )
                      : Center(
                    child: Text("Your opponent Answered!", style: TextStyle(color: Colors.grey[700])),
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical * 4),
                Container(
                  padding: const EdgeInsets.all(10),
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
                      SizedBox(
                        width: SizeConfig.screenWidth * 0.7,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            // Print the question type:
                            child: Text(
                              questionData[TYPE] + ":",
                              style: TextStyle(
                                  fontSize: SizeConfig.blockSizeVertical * 4,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConfig.blockSizeVertical * 2),
                      // Get the question body, text or image.
                      getBodyWidget(questionData[TYPE], questionData[QUESTION_BODY]),
                      SizedBox(height: SizeConfig.blockSizeVertical * 1),
                      // show the answers
                      ListView.builder(
                        shrinkWrap: true, // used to control the size of the scrollable widget
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
                                      const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                // create a list of options with a radio button for each option and handle the selection of a single option.
                                child: RadioListTile(
                                    value: index,
                                    // answer text
                                    title: Text(
                                      answers![index],
                                      style: TextStyle(
                                          fontSize:
                                          SizeConfig.blockSizeVertical * 2.5),
                                    ),
                                    activeColor: Colors.black,
                                    groupValue: groupValue,
                                    onChanged: (int? val) {
                                      //The mounted property is a boolean value
                                      // that indicates whether the current
                                      // widget is currently in the tree
                                      // and attached to the widget hierarchy.
                                      if (mounted) {
                                        setState(() {
                                          groupValue = val!;
                                          updateFirebase(
                                              snapshot.data!.data()! as Map<dynamic, dynamic>, answers![val]);

                                        });
                                      }
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

  Color? chooseColor(int index) {
    if (groupValue == index) {
      return const Color(0xFFB9D9EB);
    }
    return Colors.white;
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    _timer = Timer.periodic(
      oneSec,
          (Timer? timer) {
        if (!mounted) return;
        if (_start == 0) {
          if (widget.questionNumber == QUESTIONS_AMOUNT) {
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
    var random = Random();
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
    for (var q in game[QUESTIONS]) {
      if (q[QUESTION_NUM] == num) {
        return q;
      }
    }
    debugPrint("Error not found the question");
    return null;
  }

  void updateFirebase(Map oldData, String answer) {
    String userAnswer = "user${widget.userNumber}Answer";
    DocumentReference documentReference = FirebaseFirestore.instance.collection(GAMES).doc(widget.gameId);
    FirebaseFirestore.instance.
    runTransaction((transaction) async{
      await transaction.get(documentReference).then((value) {
        List questions = value[QUESTIONS];
        Map oldAnswer = questions[widget.questionNumber-1];
        oldAnswer[userAnswer] = answer;
        questions[widget.questionNumber-1] = oldAnswer;
        transaction.update(documentReference, {
          QUESTIONS : questions
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
      return SizedBox(
        width: SizeConfig.screenWidth * 0.7,
        height: SizeConfig.blockSizeVertical * 15,
        child: Center(
          child: AutoSizeText(
            body,
            style: TextStyle(
              fontSize: SizeConfig.blockSizeVertical * 7,
            ),
            maxLines: 3,
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