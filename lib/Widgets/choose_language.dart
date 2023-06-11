import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/Pages/chat_page.dart';
import 'package:final_project_2023/screen_size_config.dart';
import 'package:final_project_2023/consts.dart';
import '../FireBase/fireBaseDB.dart';
import '../FireBase/auth_repository.dart';
import '../Pages/friends_list.dart';
import 'search_random_dialog.dart';

class ChooseLanguage extends StatefulWidget {
  final bool isRandom;
  final bool isFromFriendList;
  Map friendInfo;
  StreamController<List<double>>? blurController;

  ChooseLanguage(this.isRandom, this.friendInfo,
      {this.isFromFriendList = false, this.blurController});

  @override
  ChooseLanguageState createState() {
    return ChooseLanguageState();
  }
}

class ChooseLanguageState extends State<ChooseLanguage> {
  bool isLangSelected = true;
  bool isLoadingChat = false;
  String? languageId;
  List<String> languagesList = [];

  @override
  void initState() {
    // Call the parent's initState() method.
    super.initState();

    // Retrieve user data from the Firestore database.
    FirebaseFirestore.instance
        .collection(USERS)
        .doc(AuthRepository.instance().user!.uid) // Access the document using the user's UID.
        .get()
        .then((value) {
      // Retrieve the 'languages' field from the document data.
      Map languages = value.data()![LANGUAGES];

      // Check if the widget is loaded from the friend list.
      if (widget.isFromFriendList) {
        setState(() {
          Map friendLanguages = widget.friendInfo[LANGUAGES];
          // Iterate through the languages and add them to the 'languagesList' if they exist in both the user's and friend's languages.
          languages.forEach((key, value) {
            if (friendLanguages.containsKey(key)) {
              languagesList.add(key);
            }
          });
        });
      } else {
        setState(() {
          // Iterate through the languages and add them to the 'languagesList'.
          languages.forEach((key, value) {
            languagesList.add(key);
          });
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    String currentUserID = AuthRepository.instance().user!.uid;
    SizeConfig().init(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.blueAccent, width: 2),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(USERS)
            .doc(currentUserID)
            .snapshots(),
        builder: (BuildContext buildContext, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return const Text(ERROR_MESSAGE);
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) return const CircularProgressIndicator();
          if (widget.isFromFriendList && languagesList.isEmpty){
            return Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "${"You and " + widget.friendInfo[USERNAME]} don't learn a common language",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(OK, style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            );
          }
          else {
            return Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(CHOOSE_LANGUAGE, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.grey[200],
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text(CHOOSE_LANGUAGE),
                      underline: Container(),
                      value: languageId,
                      items: languagesList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          isLangSelected = true;
                          languageId = newVal!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  isLangSelected
                      ? Container()
                      : Text(
                    "You must pick a preferred language",
                    style: TextStyle(color: Colors.red[800]),
                  ),
                  const SizedBox(height: 20.0),
                  isLoadingChat
                      ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB9D9EB)))
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (languageId == null) {
                        setState(() {
                          isLangSelected = false;
                        });
                      } else {
                        if (widget.isFromFriendList) {
                          _enterChatPage(
                              languageId!,
                              widget.friendInfo,
                              snapshot.data!.data()! as Map<dynamic, dynamic>
                          );
                        } else if (widget.isRandom)      {
                          Navigator.of(context).pop();
                          showDialog(
                              barrierDismissible: false,
                              barrierColor: Colors.transparent,
                              context: context,
                              builder: (context) {
                                widget.blurController!
                                    .add([1.5, 1.5]);
                                return SearchRandomDialog(
                                    snapshot.data!.data()! as Map<dynamic, dynamic>
                                    ,
                                    languageId!);
                              }).then((value) async {
                            widget.blurController!.add([0, 0]);
                          });
                        } else {
                          navigateToSelectFriend(
                              context, languageId!);
                        }
                      }
                    },
                    child: const Text(OK, style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void navigateToSelectFriend(context, String language) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FriendsList(
              true,
              selectedLanguage: language,
            )));
  }

  void _enterChatPage(String language, Map friendInfo, Map userInfo) async {
    String currentUserID = AuthRepository.instance().user!.uid;
    setState(() {
      isLoadingChat = true;
    });
    String chatID = await FirebaseDB.Firebase_db.getChatIdOfFriend(
        currentUserID, friendInfo[UID], language);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return ChatPage(
              chatID, currentUserID, friendInfo, language, userInfo);
        },
      ),
    );
    setState(() {
      isLoadingChat = false;
    });
  }
}
