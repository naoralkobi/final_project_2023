import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:final_project_2023/Pages/chat_massages.dart';
import 'package:final_project_2023/Pages/send_image.dart';
import 'package:final_project_2023/screen_size_config.dart';
import 'package:final_project_2023/Widgets/custom_chat_bar.dart';
import 'package:final_project_2023/firebase/FirebaseDB.dart';
import '../consts.dart';
import 'questions_page.dart';
import 'view_user_profile.dart';

class ChatPage extends StatefulWidget {
  final String chatID;
  final String currentUserID;
  final Map friendInfo;
  final String language;
  final Map userInfo;
  bool isMyFriend = false;
  ChatPage(this.chatID, this.currentUserID, this.friendInfo, this.language,
      this.userInfo);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final messageController = TextEditingController();
  StreamController<String> gameController = StreamController.broadcast();
  final picker = ImagePicker();
  final notImplementedSnackBar = const SnackBar(
    duration: Duration(milliseconds: 1000),
    content: Text('Not implemented yet!'),
    behavior: SnackBarBehavior.floating,
  );
  late Image languageFlag;
  String gameID = "";
  StreamSubscription<DocumentSnapshot>? streamSubscription;

  @override
  void initState() {
    super.initState();
    switch (widget.language) {
      case "Arabic":
        languageFlag = Image.asset(
          "assets/images/united-arab-emirates.png",
          width: SizeConfig.blockSizeHorizontal * 7,
          height: SizeConfig.blockSizeVertical * 4,
        );
        break;
      case "French":
        languageFlag = Image.asset(
          "assets/images/france.png",
          width: SizeConfig.blockSizeHorizontal * 7,
          height: SizeConfig.blockSizeVertical * 4,
        );
        break;
      case "German":
        languageFlag = Image.asset(
          "assets/images/germany.png",
          width: SizeConfig.blockSizeHorizontal * 7,
          height: SizeConfig.blockSizeVertical * 4,
        );
        break;
      case "Hebrew":
        languageFlag = Image.asset(
          "assets/images/israel.png",
          width: SizeConfig.blockSizeHorizontal * 7,
          height: SizeConfig.blockSizeVertical * 4,
        );
        break;
      case "Italian":
        languageFlag = Image.asset(
          "assets/images/italy.png",
          width: SizeConfig.blockSizeHorizontal * 7,
          height: SizeConfig.blockSizeVertical * 4,
        );
        break;
      case "Portuguese":
        languageFlag = Image.asset(
          "assets/images/portugal.png",
          width: SizeConfig.blockSizeHorizontal * 7,
          height: SizeConfig.blockSizeVertical * 4,
        );
        break;
      case "Spanish":
        languageFlag = Image.asset(
          "assets/images/spain.png",
          width: SizeConfig.blockSizeHorizontal * 7,
          height: SizeConfig.blockSizeVertical * 4,
        );
        break;
    }
    _listen();
  }

  void _listen() async {
    print("chat id - " + widget.chatID);
    DocumentReference reference =
    FirebaseFirestore.instance.collection(CHATS).doc(widget.chatID);
    streamSubscription = reference.snapshots().listen((querySnapshot) {
      Map<String, dynamic> data = querySnapshot.data() as Map<String, dynamic>;

      if (!data.containsKey(UNREAD_MESSAGES) ||
          (data.containsKey(UNREAD_MESSAGES) &&
              data[UNREAD_MESSAGES][widget.currentUserID] != 0)) {
        int unreadMessages = 0;
        if (data.containsKey(UNREAD_MESSAGES)) {
          unreadMessages = data[UNREAD_MESSAGES][widget.friendInfo["UID"]];
        }
        FirebaseDB.Firebase_db.markReadMessages(widget.chatID, widget.currentUserID);
      }

      if (data["acceptedInviteUID"] != null &&
          data["acceptedInviteUID"] != "") {
        if (data["acceptedInviteUID"] == widget.currentUserID) {
          if (data["currentGame"] != null)
            enterGame(data["currentGame"], 1, data[INVITE_ID]);
        } else {
          if (data["currentGame"] != null)
            enterGame(data["currentGame"], 2, data[INVITE_ID]);
        }
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    List friendsList = widget.userInfo["friends"];
    return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 6),
                color: const Color(0xFFF8F5F5),
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          0, 0, 0, SizeConfig.blockSizeVertical * 9),
                      child: ChatMessages(
                        chatID: widget.chatID,
                        userID: widget.currentUserID,
                        friendInfo: widget.friendInfo,
                        language: widget.language,
                        userInfo: widget.userInfo,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(
                          0, 0, 0, SizeConfig.blockSizeVertical * 1),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(
                                  SizeConfig.blockSizeHorizontal * 2,
                                  0,
                                  SizeConfig.blockSizeHorizontal * 1,
                                  0),
                              padding: EdgeInsets.fromLTRB(
                                  SizeConfig.blockSizeHorizontal * 2,
                                  0,
                                  SizeConfig.blockSizeHorizontal * 1,
                                  0),
                              width: SizeConfig.blockSizeHorizontal * 80,
                              height: SizeConfig.blockSizeVertical * 7.5,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: const BorderRadius.all(Radius.circular(30)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset:
                                    const Offset(3, 4), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: SizeConfig.blockSizeHorizontal * 2,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: messageController,
                                      decoration: const InputDecoration(
                                          hintText: TEXT_FIELD_HINT,
                                          hintStyle:
                                          TextStyle(color: Colors.black54),
                                          border: InputBorder.none),
                                      style: TextStyle(
                                          fontSize:
                                          SizeConfig.blockSizeHorizontal * 4),
                                    ),
                                  ),
                                  SizedBox(
                                      width: SizeConfig.blockSizeHorizontal * 5),
                                  IconButton(
                                    icon: const Icon(Icons.add_photo_alternate_outlined,
                                        color: SEND_IMAGE_ICON_COLOR),
                                    onPressed: pickImage,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: SizeConfig.blockSizeHorizontal * 15,
                              height: SizeConfig.blockSizeVertical * 7.5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset:
                                    const Offset(3, 4), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: FloatingActionButton(
                                onPressed: () {
                                  FirebaseDB.Firebase_db.sendMessage(
                                      context,
                                      widget.chatID,
                                      messageController.text,
                                      MESSAGE_TYPE_TEXT,
                                      widget.currentUserID,
                                      widget.userInfo["username"],
                                      widget.friendInfo["UID"]);
                                  messageController.clear();
                                },
                                backgroundColor: const Color(0xFF6D94BE),
                                elevation: 0,
                                child: Icon(
                                  Icons.send_outlined,
                                  color: Colors.white,
                                  size: SizeConfig.blockSizeHorizontal * 7.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  Container(
                    alignment: Alignment.topCenter,
                    //width: SizeConfig.blockSizeHorizontal,
                    height: SizeConfig.blockSizeVertical * 8.5,
                    decoration: const BoxDecoration(
/*                        boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 0.1,
                          blurRadius: 0.1,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],*/
                      color: MAIN_BLUE_COLOR,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0)),
                    ),
                  ),
                  Container(
                    //alignment: Alignment.topCenter,
                    width: 0,
                    height: SizeConfig.blockSizeVertical * 8.5,
                    decoration: ShapeDecoration(
                      color: MAIN_BLUE_COLOR,
                      shape: AppBarBorder(),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    //width: SizeConfig.blockSizeHorizontal,
                    height: SizeConfig.blockSizeVertical * 8.5,
                    decoration: const BoxDecoration(
                      color: MAIN_BLUE_COLOR,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0)),
                    ),
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            iconSize: SizeConfig.blockSizeHorizontal * 8,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewUserProfile(
                                          widget.friendInfo["UID"])));
                            },
                            child: CircleAvatar(
                              backgroundImage:
                              NetworkImage(widget.friendInfo["URL"]),
                              maxRadius: 20,
                            ),
                          ),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal * 4,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  widget.friendInfo["username"],
                                  style: TextStyle(
                                      fontSize:
                                      SizeConfig.blockSizeHorizontal * 5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal * 2,
                          ),
                          if (friendsList
                              .contains(widget.friendInfo["username"]) || widget.isMyFriend)
                            SizedBox()
                          else
                            IconButton(
                                icon: const Icon(
                                  Icons.person_add_alt_1_outlined,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                onPressed: () {
                                  FirebaseDB.Firebase_db.addFriend(
                                      widget.friendInfo["username"],
                                      context);
                                  setState(() {
                                    widget.isMyFriend = true;
                                  });
                                })
                          ,
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal * 2,
                          ),
                          languageFlag,
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal * 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                //alignment: Alignment.center,
                  width: double.infinity,
                  height: SizeConfig.blockSizeVertical * 11,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 5.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Image.asset(
                          "assets/images/joystick_1.png",
                        ),
                        onPressed: () {
                          const snackBar = SnackBar(
                            content: Text('start game pressed'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          _sendGameInvite();
                        },
                        iconSize: SizeConfig.blockSizeHorizontal * 16.2,
                      ),
                    ],
                  )),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    messageController.dispose();
    if(streamSubscription != null) {
      streamSubscription!.cancel();
    }
    super.dispose();
  }

  Future pickImage() async {
    picker.getImage(source: ImageSource.gallery).then((imageFile) => {
      if (imageFile != null)
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (context, anim1, anim2) =>
                    SendImage(imageFile: File(imageFile.path))))
            .then((value) => {
          if (value[0]) {_sendImage(imageFile)}
        })
            .onError((error, stackTrace) => {})
    });
  }

  _sendGameInvite() {
    FirebaseDB.Firebase_db.sendMessage(context, widget.chatID, "🎮",
        MESSAGE_TYPE_GAME, widget.currentUserID,widget.userInfo["username"],widget.friendInfo["UID"]);
  }

  _sendImage(PickedFile pickedFile) async {
    var db = FirebaseDB.Firebase_db;
    String imageURL = await db.uploadImage(File(pickedFile.path), widget.chatID,
        widget.currentUserID + "-" + DateTime.now().toString());
    db.sendMessage(context, widget.chatID, imageURL, MESSAGE_TYPE_IMAGE,
        widget.currentUserID,widget.userInfo["username"],widget.friendInfo["UID"]);
  }

  enterGame(String gameID, int userNumber, String inviteID) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              child: QuestionsPage(
                  widget.chatID, gameID, widget.userInfo,widget.friendInfo, 1, userNumber,inviteID)
          ));
  }
}
