import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../consts.dart';
import 'view_user_profile.dart';
import '../Widgets/leader_board_list.dart';
import '../screen_size_config.dart';

class Leaderboard extends StatefulWidget {
  Map userInfo;

  Leaderboard(this.userInfo);

  @override
  State<StatefulWidget> createState() => LeaderboardState();
}

class LeaderboardState extends State<Leaderboard> {

  List friendsList = [];
  int rank = 0;
  double sizedBoxSize = SizeConfig.blockSizeVertical * 2;
  double avatarRadius = SizeConfig.blockSizeHorizontal * 12.0;
  double appBarHeight =  SizeConfig.blockSizeHorizontal * 7 * 2 + SizeConfig.blockSizeVertical * 10 +
      SizeConfig.blockSizeHorizontal * 12.0 + SizeConfig.blockSizeVertical * 15;

  final Widget _appBarTitle = const Text(
    "Leaderboard",
    style: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
  );


  @override
  void initState() {
    super.initState();
    _getCurrentRank(widget.userInfo[USERNAME]);
    friendsList = widget.userInfo['friends'];
    friendsList.add(widget.userInfo[USERNAME]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFFF8F5F5),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(appBarHeight),
            child: AppBar(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(18.0),
                ),
              ),
              automaticallyImplyLeading: false,
              bottom: TabBar(
                indicatorColor: Colors.white,
                tabs: [
                  Text('My Rank', style: TextStyle(fontSize: SizeConfig
                      .blockSizeHorizontal * 5)),
                  Text('All', style: TextStyle(fontSize: SizeConfig
                      .blockSizeHorizontal * 5)),
                  Text('Friends', style: TextStyle(fontSize: SizeConfig
                      .blockSizeHorizontal * 5)),
                ],
              ),
              flexibleSpace: SafeArea(
                child: Container(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Row(
                          children: <Widget>[
                            const SizedBox(
                              width: 2,
                            ),
                            IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                ),
                                iconSize: SizeConfig
                                    .blockSizeHorizontal * 8,
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                            const SizedBox(
                              width: 12,
                            ),
                            _appBarTitle,
                          ]),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ViewUserProfile(
                                                widget.userInfo["UID"])));
                              },
                              child: CircleAvatar(
                                backgroundImage:
                                NetworkImage(widget.userInfo['URL']),
                                maxRadius: avatarRadius,
                              ),
                            ),
                            SizedBox(
                              height: sizedBoxSize,
                            ),
                            Visibility(
                              visible: widget.userInfo
                                  .containsKey(SCORE),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .center,
                                mainAxisAlignment: MainAxisAlignment
                                    .center,
                                children: [
                                  ImageIcon(const AssetImage(
                                      "assets/images/trophy.png"),
                                    color: Colors.white,
                                    size: SizeConfig
                                        .blockSizeHorizontal * 7,),
                                  const SizedBox(width: 3,),
                                  widget.userInfo.containsKey(
                                      SCORE) ? Text(
                                    widget.userInfo[SCORE].toString(),
                                    style: TextStyle(
                                        fontSize: SizeConfig
                                            .blockSizeHorizontal * 4,
                                        color: Colors.white
                                    ),
                                  ) : const Text("")
                                ],
                              ),
                            ),
                            SizedBox(
                              height: sizedBoxSize,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment
                                  .center,
                              mainAxisAlignment: MainAxisAlignment
                                  .center,
                              children: [
                                Icon(
                                  Icons.leaderboard_outlined,
                                  color: Colors.white,
                                  size: SizeConfig.blockSizeHorizontal *
                                      7,),
                                const SizedBox(width: 3,),
                                Text(
                                  rank.toString(),
                                  style: TextStyle(
                                      fontSize: SizeConfig
                                          .blockSizeHorizontal * 4,
                                      color: Colors.white
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: sizedBoxSize * 3,
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
          body: TabBarView(
            children: <Widget>[
              LeaderboardList(const [], true, false, widget.userInfo[USERNAME]),
              LeaderboardList(const [], false, false, widget.userInfo[USERNAME]),
              LeaderboardList(friendsList, false, true, widget.userInfo[USERNAME]),
            ],
          )
      ),
    );
  }

  void _getCurrentRank(String username) async {
    int prevRank = -1; // Initialize previous rank variable
    int prevScore = -1; // Initialize previous score variable
    int userRank = 0; // Initialize user's rank variable

    // Retrieve the user data from the Firestore collection
    await FirebaseFirestore.instance
        .collection(USERS)
        .orderBy(SCORE, descending: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        // Iterate through each document in the query snapshot

        if (prevScore == -1) {
          // If it's the first document, set previous rank to 1 and previous score to the document's score
          prevRank = 1;
          prevScore = doc[SCORE];
        } else {
          // If it's not the first document, check if the previous score is greater than the current document's score
          // If it is, increment the previous rank and update the previous score
          if (prevScore > doc[SCORE]) {
            prevRank += 1;
            prevScore = doc[SCORE];
          }
        }

        if (doc[USERNAME] == username) {
          // If the document's username matches the user's username, store the user's rank
          userRank = prevRank;
        }
      }
    });

    // Update the 'rank' state variable with the user's rank
    if (mounted) {
      setState(() {
        rank = userRank;
      });
    }
  }
}
