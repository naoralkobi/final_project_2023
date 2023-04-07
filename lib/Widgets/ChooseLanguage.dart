import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/Pages/chat_page.dart';
import 'package:final_project_2023/Pages/friends_list.dart';
import 'package:final_project_2023/screen_size_config.dart';
import 'package:final_project_2023/consts.dart';
import '../FireBase/fireBaseDB.dart';
import '../FireBase/auth_repository.dart';
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
    return new ChooseLanguageState();
  }
}

class ChooseLanguageState extends State<ChooseLanguage> {
  bool isLangSelected = true;
  bool isLoadingChat = false;
  String? languageId;
  List<String> languagesList = [];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('users')
        .doc(AuthRepository.instance().user!.uid)
        .get()
        .then((value) {
      Map languages = value.data()!['Languages'];
      if (widget.isFromFriendList){
        setState(() {
          Map friendLanguages = widget.friendInfo["Languages"];
          languages.forEach((key, value) {
            if (friendLanguages.containsKey(key))
              languagesList.add(key);
          });
        });
      }
      else{
        setState(() {
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
    return new Dialog(
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(18.0)),
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserID)
              .snapshots(),
          builder: (BuildContext buildContext,
              AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) return Text("There has been an error");
            //if connecting show progressIndicator
            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.data == null) return SizedBox();
            if (widget.isFromFriendList && languagesList.isEmpty){
              return Container(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                alignment: Alignment.center,
                height: SizeConfig.blockSizeVertical * 30,
                width: SizeConfig.blockSizeHorizontal * 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("You and " + widget.friendInfo["username"] + " don't learn a common language",
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                    SizedBox(height: SizeConfig.blockSizeVertical * 4),
                    TextButton(
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(Size(65, 40)),
                        backgroundColor: MaterialStateProperty.all(Color(0xFFB9D9EB)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        )),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("OK ", style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              );
            }
            else
              return Container(
                height: SizeConfig.blockSizeVertical * 30,
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Choose a Language", style: TextStyle(fontSize: 18)),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 3,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Color(0xFFDFDFDF),
                          border: Border.all(color: Colors.grey)),
                      child: DropdownButton<String>(
                          hint: Text("Language"),
                          underline: SizedBox.shrink(),
                          value: languageId,
                          items: languagesList.map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            setState(() {
                              isLangSelected = true;
                              languageId = newVal!;
                            });
                          }),
                    ),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: isLangSelected
                          ? Text(" ")
                          : Text(
                        "You must pick a preferred language",
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 2,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: SizeConfig.blockSizeHorizontal * 4),
                      child: isLoadingChat
                          ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFB9D9EB)))
                          : Padding(
                        padding: EdgeInsets.only(
                            left: SizeConfig.blockSizeHorizontal * 4),
                        child: TextButton(
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(65, 36)),
                            backgroundColor: MaterialStateProperty.all(Color(0xFFB9D9EB)),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            )),
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
                              } else if (widget.isRandom) {
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
                          child:
                          Text("OK ", style: TextStyle(fontSize: 14)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
          }),
    );
  }

  void navigateToSelectFriend(context, String language) {
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => FriendsList(
    //           true,
    //           selectedLanguage: language,
    //         )));
  }

  void _enterChatPage(String language, Map friendInfo, Map userInfo) async {
    String currentUserID = AuthRepository.instance().user!.uid;
    setState(() {
      isLoadingChat = true;
    });
    String chatID = await FirebaseDB.Firebase_db.getChatIdOfFriend(
        currentUserID, friendInfo["UID"], language);
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
