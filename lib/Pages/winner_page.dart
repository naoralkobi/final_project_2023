import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:final_project_2023/screen_size_config.dart';
import '../consts.dart';
import 'game_summary_page.dart';
import 'dart:math';

class WinnerPage extends StatefulWidget {
  String gameId;
  Map userInfo;
  Map opponentInfo;

  WinnerPage(this.gameId, this.userInfo, this.opponentInfo);

  @override
  _WinnerPageState createState() => _WinnerPageState();
}

class _WinnerPageState extends State<WinnerPage> {
  late ConfettiController _controllerCenterRight;
  Timer? _timer;
  int _start = 8;
  var user1Info;
  var user2Info;
  bool firstWin = true;

  @override
  void initState() {
    _controllerCenterRight =
        ConfettiController(duration: const Duration(milliseconds: 2200));
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _controllerCenterRight.dispose();
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
        builder: (BuildContext buildContext,
            AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return const Text(ERROR_MESSAGE);
          //if connecting show progressIndicator
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) return const Center(child: SizedBox());
          //List questionsData = (snapshot.data!.data() as Map<dynamic, dynamic>)["questions"] as List<dynamic>;
          if ((snapshot.data!.data() as Map<dynamic, dynamic>)[UID1] == widget.userInfo[UID]) {
            user1Info = widget.userInfo;
            user2Info = widget.opponentInfo;
          } else {
            user2Info = widget.userInfo;
            user1Info = widget.opponentInfo;
          }
          // Find how won in this game!
          int winner = getWinner(snapshot.data!.data() as Map<dynamic, dynamic>);
          // after we know who is the winner we will show it to the screen.
          return Scaffold(
            body: Column(children: [
              SizedBox(
                height: SizeConfig.screenHeight * 0.12,
              ),
              SizedBox(
                width: SizeConfig.screenWidth * 0.8,
                child: Center(
                  child: Text("THE WINNER IS:",
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 15),
                      textAlign: TextAlign.center),
                ),
              ),
              SizedBox(
                height: SizeConfig.screenHeight * 0.07,
              ),
              Stack(
                children: [
                  getWinnerWidget(winner, user1Info, user2Info),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ConfettiWidget(
                      confettiController: _controllerCenterRight,
                      blastDirection: pi,
                      // radial value - LEFT
                      particleDrag: 0.05,
                      // apply drag to the confetti
                      emissionFrequency: 0.20,
                      // how often it should emit
                      numberOfParticles: 5,
                      // number of particles to emit
                      gravity: 0.1,
                      // gravity - or fall speed
                      shouldLoop: false,
                      colors: const [
                        Colors.green,
                        Colors.blue,
                        Colors.pink
                      ], // manually specify the colors to be used
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ConfettiWidget(
                      confettiController: _controllerCenterRight,
                      blastDirection: 0,
                      // radial value - LEFT
                      particleDrag: 0.05,
                      // apply drag to the confetti
                      emissionFrequency: 0.20,
                      // how often it should emit
                      numberOfParticles: 5,
                      // number of particles to emit
                      gravity: 0.05,
                      // gravity - or fall speed
                      shouldLoop: false,
                      colors: const [
                        Colors.green,
                        Colors.blue,
                        Colors.pink
                      ], // manually specify the colors to be used
                    ),
                  ),
                ],
              ),
            ]),
          );
        });
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
          Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeftWithFade,
                  child: GameSummaryPage(
                      widget.gameId, widget.userInfo, widget.opponentInfo)));
          setState(() {
            timer!.cancel();
            timer = null;
            _timer!.cancel();
            _timer = null;
          });
        } else {
          if (_start == 7) {
            _controllerCenterRight.play();
          }
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  int getWinner(Map game) {
    int user1Score = 0;
    int user2Score = 0;
    for (Map q in game[QUESTIONS]) {
      if (q[USER_1_ANSWER] == q[CORRECT_ANSWER]) {
        user1Score++;
      }
      if (q[USER_2_ANSWER] == q[CORRECT_ANSWER]) {
        user2Score++;
      }
    }
    if (user1Score > user2Score) {
      return USER1WIN;
    } else if (user2Score > user1Score) {
      return USER1LOSS;
    }
    return TIE;
  }

  Widget getWinnerWidget(int winner, Map user1, Map user2) {
    Map winnerInfo;
    Widget displayWidget;
    if (winner == TIE) {
      displayWidget = Center(
        child: Text(
          "IT'S A TIE 😃",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal * 18,
              color: PURPLE_COLOR),
        ),
      );
    } else {
      if (winner == USER1WIN) {
        winnerInfo = user1Info;
      } else {
        winnerInfo = user2Info;
      }
      displayWidget = Column(children: [
        CircleAvatar(
          radius: SizeConfig.blockSizeHorizontal * 30,
          backgroundImage: NetworkImage(winnerInfo["URL"]),
        ),
        SizedBox(
          height: SizeConfig.screenHeight * 0.02,
        ),
        SizedBox(
          width: SizeConfig.screenWidth * 0.7,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              child: Text(
                winnerInfo[USERNAME],
                style: TextStyle(
                    fontSize: SizeConfig.screenWidth * 0.12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('+  ',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: SizeConfig.blockSizeHorizontal * 6),
                textAlign: TextAlign.center),
            Image.asset(
              "assets/images/coin.png",
              width: SizeConfig.blockSizeHorizontal * 9,
            ),
            Image.asset(
              "assets/images/coin.png",
              width: SizeConfig.blockSizeHorizontal * 9,
            ),
          ],
        ),
      ]);
      addScore(winnerInfo[UID]);
    }

    return Align(
      alignment: Alignment.center,
      child: AnimatedOpacity(
        opacity: _start <= 6 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: displayWidget,
      ),
    );
  }

  void addScore(String uid){
    if (firstWin && uid == widget.userInfo[UID]){
      FirebaseFirestore.instance
          .collection(USERS)
          .doc(uid)
          .update({SCORE: FieldValue.increment(2)});
      firstWin = false;
    }
  }
}
