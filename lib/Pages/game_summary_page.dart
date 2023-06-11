import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:final_project_2023/Widgets/game_summary_row.dart';
import 'package:final_project_2023/screen_size_config.dart';
import '../consts.dart';
import 'full_game_summary_page.dart';

class GameSummaryPage extends StatefulWidget {
  String gameId;
  Map userInfo;
  Map opponentInfo;

  GameSummaryPage(this.gameId, this.userInfo, this.opponentInfo);

  @override
  _GameSummaryPageState createState() => _GameSummaryPageState();
}

class _GameSummaryPageState extends State<GameSummaryPage> {
  var user1Info;
  var user2Info;

  @override
  Widget build(BuildContext context) {
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
          List questionsData = (snapshot.data!.data() as Map<String, dynamic>)[QUESTIONS];
          if (snapshot.data![UID1] == widget.userInfo[UID]) {
            user1Info = widget.userInfo;
            user2Info = widget.opponentInfo;
          } else {
            user2Info = widget.userInfo;
            user1Info = widget.opponentInfo;
          }
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
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      children: <Widget>[
                        const SizedBox(
                          width: 2,
                        ),
                        IconButton(
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                            iconSize: SizeConfig.blockSizeHorizontal * 8,
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Game Summary",
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 6,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                              const SizedBox(
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
            body: SafeArea(
              child: Column(children: [
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 5,
                ),
                ListView.separated(
                    shrinkWrap: true,
                    itemCount: questionsData.length + 1,
                    separatorBuilder: (context, index) {
                      if (index == 0) {
                        return SizedBox(
                          height: SizeConfig.blockSizeVertical * 3,
                        );
                      }
                      return Divider(
                        indent: SizeConfig.screenWidth * 0.04,
                        endIndent: SizeConfig.screenWidth * 0.04,
                        thickness: SizeConfig.blockSizeVertical * 0.15,
                      );
                    },
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Row(
                          children: [
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal * 28,
                            ),
                            Column(children: [
                              CircleAvatar(
                                radius: SizeConfig.blockSizeVertical * 3.5,
                                backgroundImage: NetworkImage(user1Info["URL"]),
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal * 22,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: SizedBox(
                                    child: Text(
                                      user1Info[USERNAME],
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal * 6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal * 17,
                            ),
                            Column(children: [
                              CircleAvatar(
                                radius: SizeConfig.blockSizeVertical * 3.5,
                                backgroundImage: NetworkImage(user2Info["URL"]),
                              ),
                              Container(
                                width: SizeConfig.blockSizeHorizontal * 20,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: SizedBox(
                                    child: Text(
                                      user2Info[USERNAME],
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal * 6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        );
                      }
                      return GameSummaryRow(questionsData[index - 1]);
                    }),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 13,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: Row(
                        children: [
                          Text("Full Summary ",
                              style: TextStyle(
                                  fontSize: SizeConfig.blockSizeHorizontal * 6,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey)),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.grey)
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeftWithFade,
                                child: FullGameSummaryPage(
                                    snapshot.data!.data()! as Map<dynamic, dynamic>,
                                    user1Info,
                                    user2Info)));
                      },
                    ),
                  ],
                )
              ]),
            ),
          );
        });
  }
}
