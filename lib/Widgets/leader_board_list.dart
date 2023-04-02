import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../Pages/view_user_profile.dart';

import '../screen_size_config.dart';

class LeaderboardList extends StatefulWidget {
  List usernames;
  bool isMyRank;
  bool isFriends;
  String currentUser;

  LeaderboardList(
      this.usernames, this.isMyRank, this.isFriends, this.currentUser);

  @override
  LeaderboardListState createState() {
    return new LeaderboardListState();
  }
}

class LeaderboardListState extends State<LeaderboardList> {
  List usersDocs = [];
  List ranks = [];
  int currentRank = -1;
  final _controller = ScrollController();
  final tileSize = SizeConfig.blockSizeVertical * 10.0;
  final medalSize = SizeConfig.blockSizeVertical * 6.5;

  @override
  void initState() {
    super.initState();
    if (widget.isFriends) {
      _getFriends();
    } else {
      _getAllUsers(widget.currentUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1.5),
      child: Container(
        height: tileSize,
        child: ListView.builder(
            controller: _controller,
            itemCount: usersDocs.length,
            itemExtent: tileSize,
            itemBuilder: (context, index) {
              currentRank = ranks.elementAt(index);
              return FittedBox(
                child: InkWell(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            SizedBox(width: SizeConfig.blockSizeHorizontal * 5.0),
                            Row(
                              children: <Widget>[
                                Text("#" + currentRank.toString(),
                                    style: TextStyle(
                                        fontSize:
                                        SizeConfig.blockSizeVertical * 2.5)),
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal * 4.0),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ViewUserProfile(
                                                usersDocs[index].data()['UID'])));
                                  },
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        usersDocs[index].data()['URL']),
                                    maxRadius:
                                    SizeConfig.blockSizeVertical * 3.25,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: SizeConfig.blockSizeHorizontal * 4.0),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 9.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        usersDocs[index].data()['username'],
                                        style: TextStyle(
                                            fontSize:
                                            SizeConfig.blockSizeVertical *
                                                2.5,
                                            color: Colors.purple,
                                            fontWeight: FontWeight.w500),
                                        maxLines: 6,
                                      )),
                                  Row(
                                    children: [
                                      ImageIcon(
                                        AssetImage("assets/images/trophy.png"),
                                        color: Colors.black,
                                        size: SizeConfig.blockSizeHorizontal * 4,
                                      ),
                                      Text(usersDocs[index]
                                          .data()['score']
                                          .toString()),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Flexible(child: Container()),
                            currentRank == 1
                                ? Image.asset('assets/images/first.png',
                                height: medalSize, width: medalSize)
                                : currentRank == 2
                                ? Image.asset('assets/images/second.png',
                                height: medalSize, width: medalSize)
                                : currentRank == 3
                                ? Image.asset('assets/images/third.png',
                                height: medalSize, width: medalSize)
                                : Text(''),
                            Padding(
                              padding: EdgeInsets.only(
                                  right: SizeConfig.blockSizeHorizontal * 10.0,
                                  bottom: SizeConfig.blockSizeVertical * 8.0),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: SizeConfig.blockSizeVertical * 0.1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  void _getFriends() async {
    int prevRank = -1;
    int prevScore = -1;
    await FirebaseFirestore.instance
        .collection('users')
        .orderBy('score', descending: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (prevScore == -1) {
          prevRank = 1;
          prevScore = doc['score'];
        } else {
          if (prevScore > doc['score']) {
            prevRank += 1;
            prevScore = doc['score'];
          }
        }
        if (widget.usernames.contains(doc["username"])) {
          if (mounted) {
            setState(() {
              usersDocs.add(doc);
              ranks.add(prevRank);
            });
          }
        }
      });
    });
  }

  void _getAllUsers(String username) async {
    int index = 0;
    int indexUser = 0;
    int prevRank = -1;
    int prevScore = -1;
    await FirebaseFirestore.instance
        .collection('users')
        .orderBy('score', descending: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (prevScore == -1) {
          prevRank = 1;
          prevScore = doc['score'];
        } else {
          if (prevScore > doc['score']) {
            prevRank += 1;
            prevScore = doc['score'];
          }
        }
        if (doc['username'] == username) {
          indexUser = index;
        }
        if (mounted) {
          setState(() {
            usersDocs.add(doc);
            ranks.add(prevRank);
          });
        }
        index++;
      });
    });
    if (widget.isMyRank) {
      _animateToIndex(indexUser);
    }
  }

  _animateToIndex(index) => _controller.animateTo(tileSize * index,
      duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
}
