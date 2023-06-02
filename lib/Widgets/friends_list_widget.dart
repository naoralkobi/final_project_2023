import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/Pages/chat_page.dart';
import 'package:final_project_2023/Pages/view_user_profile.dart';
import 'package:final_project_2023/screen_size_config.dart';
import 'package:final_project_2023/Widgets/ChooseLanguage.dart';
import 'package:final_project_2023/consts.dart';
import 'package:final_project_2023/firebase/FirebaseDB.dart';
import 'package:final_project_2023/firebase/auth_repository.dart';
import 'package:tuple/tuple.dart';
import 'package:final_project_2023/Pages/add_friend.dart';

class ListViewFriends extends StatefulWidget {
  bool isSelectFriendPage;
  String searchText;
  String selectedLanguage;

  ListViewFriends(this.isSelectFriendPage, this.searchText,
      {this.selectedLanguage = ""});

  @override
  ListViewFriendsState createState() {
    return new ListViewFriendsState();
  }
}

class ListViewFriendsState extends State<ListViewFriends> {
  bool isLoadingChat = false;
  var user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingChat) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA66CB7)),
          ),
        ),
      );
    }
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot> currentUserInfo) {
          if (currentUserInfo.hasError) return Text("There has been an error");
          //if connecting show progressIndicator
          if (currentUserInfo.connectionState == ConnectionState.waiting &&
              currentUserInfo.data == null)
            return Center(child: CircularProgressIndicator());
          else
            return Container(
              color: const Color(0xFFF8F5F5),
              padding: EdgeInsets.only(top: 10),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .orderBy("username")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshots) {
                    if (snapshots.hasError)
                      return Text("There has been an error ");
                    if (snapshots.connectionState == ConnectionState.waiting &&
                        snapshots.data == null)
                      return Center(child: CircularProgressIndicator());
                    else {
                      List friends = currentUserInfo.data!["friends"];
                      if (friends.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("You don't have any friends 🙁",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize:
                                      SizeConfig.blockSizeHorizontal * 5)),
                              SizedBox(
                                  height: SizeConfig.blockSizeVertical * 2.0),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xFF6D94BE),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: EdgeInsets.all(10.0),
                                ),
                                onPressed: () {
                                  navigateToAddFriend(context);
                                },
                                child: Text(
                                  "Add a friend",
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        );
                      } else
                        return ListView.separated(
                            separatorBuilder:
                                (BuildContext context, int index) {
                                  Map<String, dynamic>? friendData = snapshots.data!.docs[index]?.data() as Map<String, dynamic>?;
                                  Map<String, dynamic>? friendLanguages = friendData?[LANGUAGES];
                                  if (((widget.isSelectFriendPage &&
                                      (friendLanguages == null || !friendLanguages.containsKey(widget.selectedLanguage))) ||
                                      !friends.contains(friendData?["username"]))) {
                                    return SizedBox();
                              } else if (widget.searchText != "" &&
                                  !friendData?["username"]
                                      .toLowerCase()
                                      .contains(
                                      widget.searchText.toLowerCase())) {
                                return SizedBox();
                              } else
                                return Divider();
                            },
                            scrollDirection: Axis.vertical,
                            itemCount: snapshots.data!.size,
                            itemBuilder: (context, index) {
                              Map<String, dynamic>? friendData = snapshots.data!.docs[index]?.data() as Map<String, dynamic>?;
                              Map<String, dynamic>? friendLanguages = friendData?[LANGUAGES];
                              if ((widget.isSelectFriendPage &&
                                  !(friendLanguages?.containsKey(widget.selectedLanguage) ?? false) ||
                                  !friends.contains(friendData?["username"]))) {
                                return SizedBox();
                              } else if (widget.searchText != "" &&
                                  !friendData!["username"]
                                      .toLowerCase()
                                      .contains(
                                      widget.searchText.toLowerCase())) {
                                return SizedBox();
                              } else
                                Map<String, dynamic>? friendData = snapshots.data!.docs[index]?.data() as Map<String, dynamic>?;
                              return createUserListTile(
                                    friendData!,
                                  currentUserInfo.data!.data() as Map<dynamic, dynamic>);
                            });
                    }
                  }),
            );
        });
  }

  ListTile createUserListTile(Map friendInfo, Map userInfo) {
    return ListTile(
      onTap: () {
        if (widget.isSelectFriendPage) {
          //_enterChatPage(widget.selectedLanguage, friendInfo, userInfo);
        }
      },
      dense: true,
      tileColor: Color(0xFFF8F5F5),
      title: Text(
        friendInfo["username"],
        style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 5),
      ),
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewUserProfile(friendInfo["UID"])));
        },
        child: CircleAvatar(
          backgroundImage: NetworkImage(friendInfo["URL"]),
          maxRadius: 20,
        ),
      ),
      trailing: Container(
        width: SizeConfig.blockSizeHorizontal * 20,
        margin: EdgeInsets.only(right: SizeConfig.blockSizeHorizontal * 6),
        child: Row(
          children: [
            widget.isSelectFriendPage
                ? SizedBox()
                : Flexible(
              child: IconButton(
                icon: Icon(Icons.person_remove_alt_1_outlined,
                    size: 25, color: Color(0xFF6D94BE)),
                onPressed: () async {
                  deleteFriend(friendInfo["username"]);
                },
              ),
            ),
            SizedBox(width: SizeConfig.blockSizeHorizontal * 8),
            widget.isSelectFriendPage
                ? SizedBox()
                : Flexible(
              child: IconButton(
                icon: Icon(Icons.chat_outlined,
                    size: 25, color: Color(0xFF6D94BE)),
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => ChooseLanguage(
                          false, friendInfo,
                          isFromFriendList: true));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deleteFriend(String friendUsername) {
    showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Remove a friend', textAlign: TextAlign.center),
          content: Text(
              "Are you sure you would like to remove " +
                  friendUsername +
                  " from your friends?",
              textAlign: TextAlign.center),
          elevation: 24.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'No'),
              child: const Text('No',
                  style: TextStyle(
                    color: Color(0xFFA66CB7),
                    fontSize: 18.0,
                  )),
            ),
            //SizedBox(width: SizeConfig.blockSizeHorizontal * 8.0),
            TextButton(
              onPressed: () async {
                await FirebaseDB.Firebase_db.removeFriend(
                    friendUsername, context);
                Navigator.pop(context, 'Yes');
              },
              child: const Text('Yes',
                  style:
                  TextStyle(color: Color(0xFFA66CB7), fontSize: 18.0)),
            ),
            //SizedBox(width: SizeConfig.blockSizeHorizontal * 15.0),
          ],
        ));
  }

  // void _enterChatPage(String language, Map friendInfo, Map userInfo) async {
  //   String currentUserID = AuthRepository.instance().user!.uid;
  //   setState(() {
  //     isLoadingChat = true;
  //   });
  //   String chatID = await FirebaseDB.Firebase_db.getChatIdOfFriend(
  //       currentUserID, friendInfo["UID"], language);
  //   Navigator.of(context).pop();
  //   Navigator.of(context).pop();
  //   Navigator.of(context).push(
  //     MaterialPageRoute<void>(
  //       builder: (BuildContext context) {
  //         return ChatPage(
  //             chatID, currentUserID, friendInfo, language, userInfo);
  //       },
  //     ),
  //   );
  //   setState(() {
  //     isLoadingChat = false;
  //   });
  // }

  void navigateToAddFriend(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddFriend()));
  }
}
