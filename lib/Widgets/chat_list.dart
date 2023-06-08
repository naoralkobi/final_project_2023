import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/Pages/chat_page.dart';
import 'package:final_project_2023/firebase/auth_repository.dart';
import '../screen_size_config.dart';
import '../consts.dart';

class ChatsList extends StatefulWidget {
  String searchText;
  Map userInfo;
  StreamController<List<double>> blurController;
  ChatsList(this.searchText, this.userInfo,this.blurController, {super.key});

  @override
  ChatsListState createState() {
    return ChatsListState();
  }
}

class ChatsListState extends State<ChatsList> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    String currentUserID = AuthRepository.instance().user!.uid;
    SizeConfig().init(context);
    return Container(
      color: const Color(0xFFF8F5F5),
      child: StreamBuilder(
          stream: _db
              .collection(CHATS)
              .where("members", arrayContains: currentUserID)
              .orderBy("lastMessageDate", descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
            if (snapshots.hasError) return const Text(ERROR_MESSAGE);
            //if connecting show progressIndicator
            if (snapshots.connectionState == ConnectionState.waiting &&
                snapshots.data == null) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (snapshots.data!.docs.isEmpty) {
                return Center(
                    child: Text("You don't have active chats",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.blockSizeHorizontal * 5)));
              } else {
                return StreamBuilder<List<double>>(
                    stream: widget.blurController.stream,
                    builder: (context, blurSnapshot) {
                      double sigmaX = 0;
                      double sigmaY = 0;
                      if (blurSnapshot.hasError) return const Text(ERROR_MESSAGE);
                      if (blurSnapshot.data != null){
                        sigmaX = blurSnapshot.data![0];
                        sigmaY = blurSnapshot.data![1];
                      }
                      return ImageFiltered(
                        imageFilter: ImageFilter.blur(
                            sigmaX: sigmaX, sigmaY: sigmaY),
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: snapshots.data!.docs.length,
                            itemBuilder: (context, index) {
                              String friendID = "";
                              if (snapshots.data!.docs[index]['members'][0] ==
                                  currentUserID) {
                                friendID = snapshots.data!.docs[index]['members'][1];
                              } else {
                                friendID = snapshots.data!.docs[index]['members'][0];
                              }
                              return StreamBuilder(
                                  stream:
                                  _db.collection(USERS).doc(friendID).snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot> friendInfo) {
                                    if (friendInfo.hasError) {
                                      return Text(ERROR_MESSAGE);
                                    }
                                    //if connecting show progressIndicator
                                    if (friendInfo.connectionState ==
                                        ConnectionState.waiting &&
                                        friendInfo.data == null) {
                                      return const Center(child: SizedBox());
                                    } else {
                                      if (widget.searchText != "" &&
                                          !friendInfo.data![USERNAME]
                                              .toLowerCase()
                                              .contains(
                                              widget.searchText.toLowerCase())) {
                                        return const SizedBox();
                                      }
                                      int numUnreadMessages = 0;
                                      String unreadMessages = "";
                                      if((snapshots.data!.docs[index].data() as Map<String, dynamic>).containsKey(UNREAD_MESSAGES)) {
                                        Map map = snapshots.data!.docs[index][UNREAD_MESSAGES];
                                        if(map.containsKey(widget.userInfo["UID"])){
                                          numUnreadMessages = map[widget.userInfo["UID"]];
                                          unreadMessages = "$numUnreadMessages";
                                        }
                                        if (numUnreadMessages > 99) {
                                          unreadMessages = "99+";
                                        }
                                      }
                                      return Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18)),
                                          child: ListTile(
                                              onTap: () => _enterChatPage(
                                                  snapshots.data!.docs[index].id,
                                                  snapshots.data!.docs[index]
                                                  ['language'],
                                                  friendInfo.data!.data()! as Map<dynamic, dynamic>),
                                              title: Text(friendInfo.data![USERNAME]),
                                              subtitle: Row(
                                                children: [
                                                  Flexible(
                                                    child: RichText(
                                                      overflow: TextOverflow.ellipsis,
                                                      strutStyle:
                                                      const StrutStyle(fontSize: 12.0),
                                                      text: TextSpan(
                                                          style: const TextStyle(
                                                              color: Colors.black),
                                                          text: snapshots
                                                              .data!.docs[index]
                                                          ['lastMessageSent']),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              leading: CircleAvatar(
                                                backgroundImage: CachedNetworkImageProvider(
                                                    friendInfo.data!["URL"],
                                                    scale: 20
                                                ),
                                                maxRadius: 20,
                                              ),
                                              trailing:
                                              SizedBox(
                                                width: SizeConfig.blockSizeHorizontal*32,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  //mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                          snapshots.data!.docs[index]
                                                          ['language'],
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w600,
                                                              color: Color(0xFF6D94BE)),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        numUnreadMessages != 0 ?
                                                        Container(
                                                          //width: SizeConfig.blockSizeHorizontal*9,
                                                            decoration: BoxDecoration(
                                                              //shape: BoxShape.circle,
                                                              // You can use like this way or like the below line
                                                              borderRadius: BorderRadius.circular(30.0),
                                                              color: MAIN_BLUE_COLOR,
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                    padding:EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*2
                                                                        ,right: SizeConfig.blockSizeHorizontal*2),
                                                                    child: Text(unreadMessages, style: const TextStyle(color: Colors.white),)),
                                                              ],
                                                            )
                                                        ): const SizedBox(),
                                                        const Icon(
                                                          Icons.arrow_forward_ios_rounded,
                                                          size: 20,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )
                                          ));
                                    }
                                  });
                            }),
                      );
                    }
                );
              }
            }
          }),
    );
  }

  void _enterChatPage(String chatID, String language, Map friendInfo) async {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return ChatPage(chatID, AuthRepository.instance().user!.uid, friendInfo, language,widget.userInfo);
        }, // ...to here.
      ),
    );
  }
}