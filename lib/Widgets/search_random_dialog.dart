import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/Pages/chat_page.dart';
import 'package:final_project_2023/screen_size_config.dart';
import 'package:final_project_2023/consts.dart';
import '../FireBase/fireBaseDB.dart';
import '../FireBase/auth_repository.dart';

class SearchRandomDialog extends StatefulWidget {
  Map userInfo;
  String language;

  SearchRandomDialog(this.userInfo, this.language);

  @override
  _SearchRandomDialogState createState() => _SearchRandomDialogState();
}

class _SearchRandomDialogState extends State<SearchRandomDialog> {
  late String level;
  bool isFound = false;
  bool isInWaitingList = false;

  @override
  void initState() {
    super.initState();
    String languageLevelUpper = widget.userInfo[LANGUAGES][widget.language];
    level = languageLevelUpper.toLowerCase();
  }

  String _findMatch(List waitingList, Map userInfo) {
    String match = "";
    int myAge = FirebaseDB.firebaseDb.getAge(userInfo["birthDate"]);
    if (waitingList.isEmpty) {
      return match;
    }
    for (var friendInfo in waitingList) {
      if (friendInfo is Map && friendInfo.containsKey("UID") && userInfo.containsKey("UID")) {
        if (friendInfo["UID"] != userInfo["UID"]) {

          if ((myAge >= friendInfo["minAge"] && myAge <= friendInfo["maxAge"]) &&
              (friendInfo["age"] >= userInfo["minAge"] &&
                  friendInfo["age"] <= userInfo["maxAge"])) {
            if ((friendInfo["preferred gender"] == "Dont Care" ||
                friendInfo["preferred gender"] == userInfo["gender"]) &&
                (userInfo["preferred gender"] == "Dont Care" ||
                    userInfo["preferred gender"] == friendInfo["gender"])) {
              match = friendInfo["UID"];
            }
          }
        }
      }
    }
    return match;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(WAITING_LIST)
            .doc("${widget.language}-$level")
            .snapshots(),
        builder: (BuildContext buildContext,
            AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return const Text(ERROR_MESSAGE);
          //if connecting show progressIndicator
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null) {
            return dialog(context, widget.userInfo);
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (isFound) return const SizedBox();
            if ((snapshot.data!.data() as Map<dynamic, dynamic>).containsKey(widget.userInfo["UID"])) {
              _enterChatPage(
                  widget.language,
                  (snapshot.data!.data() as Map<dynamic, dynamic>)[widget.userInfo["UID"]],
                  false,
                  widget.userInfo);
            }
            else {
              List waitingList = (snapshot.data!.data() as Map<String, dynamic>)[WAITING_LIST];
              String match = _findMatch(waitingList, widget.userInfo);
              if (match.isEmpty && !isInWaitingList) {
                FirebaseDB.firebaseDb.addToWaitingList(
                    widget.userInfo, widget.language, level);
                isInWaitingList = true;
              } else if (match.isNotEmpty) {
                _enterChatPage(widget.language, match, true, widget.userInfo);
              }
            }
          }
          return dialog(context, widget.userInfo);
        });
  }

  void _enterChatPage(
      String language, String friendID, bool isCreateChat, Map userInfo) async {
    String currentUserID = AuthRepository.instance().user!.uid;
    String chatID = await FirebaseDB.firebaseDb.getChatIdOfFriend(
        currentUserID, friendID, language);
    isFound = true;
    if (isCreateChat) {
      FirebaseDB.firebaseDb.startChatWithRandom(
          widget.userInfo, friendID, widget.language, chatID);
    } else {
      FirebaseDB.firebaseDb.removeChatInvite(userInfo, language);
    }
    if (isInWaitingList) {
      FirebaseDB.firebaseDb.removeFromWaitingList(
          widget.userInfo, widget.language, level);
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection(USERS)
                  .doc(friendID)
                  .get(),
              builder: (BuildContext buildContext,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) return const Text(ERROR_MESSAGE);
                //if connecting show progressIndicator
                if (snapshot.connectionState == ConnectionState.waiting &&
                    snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return ChatPage(chatID, currentUserID, snapshot.data!.data()! as Map<String, dynamic>,
                      language, widget.userInfo);
                }
              });
        },
      ),
    );
  }

  dialog(BuildContext context, Map userInfo) {
    return Dialog(
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(18.0)),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          //height: SizeConfig.blockSizeVertical * 12,
          child: Row(
            children: [
              Container(
                margin:
                EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 5),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(PURPLE_COLOR),
                ),
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 6.5),
              const Text("Looking for a match..."),
              Container(
                  margin:
                  EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 8),
                  child: IconButton(
                      icon: const Icon(Icons.cancel_outlined),
                      onPressed: () {
                        if (isInWaitingList) {
                          FirebaseDB.firebaseDb.removeFromWaitingList(
                              userInfo, widget.language, level);
                        }
                        Navigator.of(context).pop();
                      }))
            ],
          ),
        ));
  }
}
