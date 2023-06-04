import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Pages/view_user_profile.dart';
import '../consts.dart';
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
    return LeaderboardListState();
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
                                        usersDocs[index].data()[USERNAME],
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
                                          .data()[SCORE]
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
    int prevRank = -1; // Initialize previous rank variable
    int prevScore = -1; // Initialize previous score variable

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

        if (widget.usernames.contains(doc[USERNAME])) {
          // If the document's username is in the list of usernames passed to the widget, store the document and rank
          if (mounted) {
            setState(() {
              usersDocs.add(doc);
              ranks.add(prevRank);
            });
          }
        }
      }
    });
  }

  void _getAllUsers(String username) async {
    int index = 0; // Initialize an index variable
    int indexUser = 0; // Initialize an indexUser variable
    int prevRank = -1; // Initialize previous rank variable
    int prevScore = -1; // Initialize previous score variable

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
          // If the document's username matches the user's username, store the index
          indexUser = index;
        }

        // Add the document and rank to the lists
        if (mounted) {
          setState(() {
            usersDocs.add(doc);
            ranks.add(prevRank);
          });
        }

        index++;
      }
    });

    if (widget.isMyRank) {
      // If it's the user's own rank, animate to the corresponding index
      _animateToIndex(indexUser);
    }
  }

  _animateToIndex(index) => _controller.animateTo(tileSize * index,
      duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
}
