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

  Widget _appBarTitle = Text(
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
          backgroundColor: Color(0xFFF8F5F5),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(appBarHeight),
            child: AppBar(
              shape: RoundedRectangleBorder(
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
                  padding: EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Row(
                          children: <Widget>[
                            SizedBox(
                              width: 2,
                            ),
                            IconButton(
                                icon: Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                ),
                                iconSize: SizeConfig
                                    .blockSizeHorizontal * 8,
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                            SizedBox(
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
                                  ImageIcon(AssetImage(
                                      "assets/images/trophy.png"),
                                    color: Colors.white,
                                    size: SizeConfig
                                        .blockSizeHorizontal * 7,),
                                  SizedBox(width: 3,),
                                  widget.userInfo.containsKey(
                                      SCORE) ? Text(
                                    widget.userInfo[SCORE].toString(),
                                    style: TextStyle(
                                        fontSize: SizeConfig
                                            .blockSizeHorizontal * 4,
                                        color: Colors.white
                                    ),
                                  ) : Text("")
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
                                SizedBox(width: 3,),
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
              LeaderboardList([], true, false, widget.userInfo[USERNAME]),
              LeaderboardList([], false, false, widget.userInfo[USERNAME]),
              LeaderboardList(friendsList, false, true, widget.userInfo[USERNAME]),
            ],
          )
      ),
    );
  }

  void _getCurrentRank(String username)  async {
    int prevRank = -1;
    int prevScore = -1;
    int userRank = 0;

    await FirebaseFirestore.instance
        .collection(USERS)
        .orderBy(SCORE, descending: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (prevScore == -1){
          prevRank = 1;
          prevScore = doc[SCORE];
        }
        else{
          if (prevScore > doc[SCORE]){
            prevRank += 1;
            prevScore = doc[SCORE];
          }
        }
        if (doc[USERNAME] == username){
          userRank = prevRank;
        }
      });
    });
    if (mounted){
      setState(() {
        rank = userRank;
      });}
  }
}
