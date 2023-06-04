import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_2023/Pages/show_image.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/FireBase/FirebaseDB.dart';
import 'package:page_transition/page_transition.dart';
import '../consts.dart';
import '../screen_size_config.dart';
import '../Pages/game_summary_page.dart';


class ChatMessages extends StatefulWidget {
  final String userID;
  final String chatID;
  final Map friendInfo;
  final String language;
  final Map userInfo;


  ChatMessages(
      {required this.chatID,
        required this.userID,
        required this.friendInfo,
        required this.language,
        required this.userInfo});

  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  Timestamp? lastMessageTime;
  FirebaseFirestore _db = FirebaseFirestore.instance;
  var dateDividersIndices = [];
  String gameID = "";

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    //return StreamBuilder<Object>(
    //    stream: gameController.stream,
    //    builder: (context, gameSnapshot) {
    return Column(
      children: [
        Flexible(
            child: Container(
              height: MediaQuery.of(context).size.height / 1.1,
              child: StreamBuilder(
                stream: _db
                    .collection(CHATS)
                    .doc(widget.chatID)
                    .collection(MESSAGES_COLLECTION)
                    .orderBy(MESSAGE_TIMESTAMP, descending: true)
                    .snapshots(),
                builder: (BuildContext buildContext,
                    AsyncSnapshot<QuerySnapshot> snapshots) {
                  if (snapshots.hasError) return const Text(ERROR_MESSAGE);
                  //if connecting show progressIndicator
                  if (snapshots.connectionState == ConnectionState.waiting &&
                      snapshots.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return ListView.builder(
                      reverse: true,
                      itemCount: snapshots.data!.docs.length + 1,
                      itemBuilder: (context, index) {
                        if (index == snapshots.data!.docs.length) {
                          return SizedBox(
                              height: SizeConfig.blockSizeVertical * 10);
                        } else {
                          if (snapshots.data!.docs[index][MESSAGE_TYPE] ==
                              MESSAGE_TYPE_DATE_DIVIDER) {
                            return _buildDateSeparator(
                                snapshots.data!.docs[index][MESSAGE_TIMESTAMP]);
                          } else if (snapshots.data!.docs[index][MESSAGE_TYPE] ==
                              MESSAGE_TYPE_GAME) {
                            return _buildGameInvite(snapshots.data!.docs[index]);
                          } else if (snapshots.data!.docs[index][MESSAGE_TYPE] ==
                              MESSAGE_TYPE_GAME_SUMMARY) {
                            return _buildGameSummary(snapshots.data!.docs[index]);
                          } else if (snapshots.data!.docs[index][MESSAGE_TYPE] ==
                              MESSAGE_TYPE_GAME_CANCELED) {
                            return _buildGameCanceled(snapshots.data!.docs[index]);
                          } else {
                            return _buildMessage(snapshots.data!.docs[index],
                                widget.userID, widget.chatID);
                          }
                        }
                      },
                    );
                  }
                },
              ),
            )),
      ],
    );
    // });
  }

  Widget _buildGameSummary(DocumentSnapshot snapshot) {
    return Row(
      mainAxisAlignment: snapshot[MESSAGE_ID_FROM] == widget.userID
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: snapshot[MESSAGE_ID_FROM] == widget.userID
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                  constraints: BoxConstraints(
                      minWidth: SizeConfig.blockSizeHorizontal * 10,
                      maxWidth: SizeConfig.blockSizeHorizontal * 80),
                  padding: const EdgeInsets.all(MESSAGE_PADDING),
                  margin: snapshot[MESSAGE_ID_FROM] == widget.userID
                      ? const EdgeInsets.fromLTRB(5, 5, 10, 5)
                      : const EdgeInsets.fromLTRB(10, 5, 5, 5),
                  decoration: BoxDecoration(
                    color: snapshot[MESSAGE_ID_FROM] == widget.userID
                        ? SENT_MESSAGE_BACKGROUND_COLOR
                        : Colors.white,
                    borderRadius: BorderRadius.circular(MESSAGE_RADIUS),
                    border: Border.all(color: Colors.grey,width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0.8,
                        blurRadius: 1.2,
                        offset: const Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        child: Text("Game Is Over",
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 6)),
                      ),
                      Container(
                        alignment: Alignment.center,
                        //margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*5, 0, SizeConfig.blockSizeHorizontal*5, 0),
                        child: RawMaterialButton(
                          elevation: 0,
                          fillColor: GAME_SUMMARY__COLOR,
                          padding: const EdgeInsets.only(right: 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: const BorderSide(
                                  color: Colors.grey, width: 0.5)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type:
                                    PageTransitionType.rightToLeftWithFade,
                                    child:
                                    // GameSummaryPage(
                                    GameSummaryPage(
                                        snapshot[MESSAGE_CONTENT],
                                        widget.userInfo,
                                        widget.friendInfo)
                                ));
                          },
                          child: Container(
                              padding: const EdgeInsets.only(left: 16, right: 15),
                              child: const Text("View game summary",
                                  style: TextStyle(color: Colors.white))),
                        ),
                      )
                    ],
                  )),
              Container(
                padding: snapshot[MESSAGE_ID_FROM] == widget.userID
                    ? const EdgeInsets.fromLTRB(0, 0, 10, 0)
                    : const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(
                  timeConverter(snapshot[MESSAGE_TIMESTAMP]),
                  style: const TextStyle(
                      fontSize: MESSAGE_DATE_FONT_SIZE, color: Colors.grey),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameInvite(DocumentSnapshot snapshot) {
    String invitedBy = snapshot[MESSAGE_ID_FROM] == widget.userID
        ? "You"
        : widget.friendInfo[USERNAME];
    String inviteTo = snapshot[MESSAGE_ID_FROM] == widget.userID
        ? widget.friendInfo[USERNAME]
        : "you";
    return Row(
      mainAxisAlignment: snapshot[MESSAGE_ID_FROM] == widget.userID
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: snapshot[MESSAGE_ID_FROM] == widget.userID
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                  constraints: BoxConstraints(
                      minWidth: SizeConfig.blockSizeHorizontal * 10,
                      maxWidth: SizeConfig.blockSizeHorizontal * 80),
                  padding: const EdgeInsets.all(MESSAGE_PADDING),
                  margin: snapshot[MESSAGE_ID_FROM] == widget.userID
                      ? const EdgeInsets.fromLTRB(5, 5, 10, 5)
                      : const EdgeInsets.fromLTRB(10, 5, 5, 5),
                  decoration: BoxDecoration(
                    color: snapshot[MESSAGE_ID_FROM] == widget.userID
                        ? SENT_MESSAGE_BACKGROUND_COLOR
                        : Colors.white,
                    borderRadius: BorderRadius.circular(MESSAGE_RADIUS),
                    border: Border.all(color: Colors.grey,width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0.8,
                        blurRadius: 1.2,
                        offset: const Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal * 4,
                              right: SizeConfig.blockSizeHorizontal * 4),
                          child: Text(
                              "$invitedBy invited $inviteTo to a fun",
                              style: TextStyle(
                                  fontSize:
                                  SizeConfig.blockSizeHorizontal * 4)),
                        ),
                      ),
                      Flexible(
                        child: Text("language game",
                            style: TextStyle(
                                fontSize:
                                SizeConfig.blockSizeHorizontal * 4)),
                      ),
                      snapshot[MESSAGE_ID_FROM] == widget.userID
                          ? RawMaterialButton(
                        elevation: 2,
                        fillColor: CANCEL_GAME_COLOR,
                        padding: EdgeInsets.only(
                            left: SizeConfig.blockSizeHorizontal * 5,
                            right: SizeConfig.blockSizeHorizontal * 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(
                                color: Colors.grey, width: 0.5)),
                        onPressed: () async {
                          FirebaseDB.Firebase_db.cancelGameInvite(
                              widget.userID,
                              widget.chatID,
                              snapshot.id);
                        },
                        child: const Text("Cancel",
                            style: TextStyle(color: Colors.white)),
                      )
                          : Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        children: [
                          RawMaterialButton(
                            elevation: 2,
                            fillColor: ACCEPT_GAME_COLOR,
                            padding: EdgeInsets.only(
                                left:
                                SizeConfig.blockSizeHorizontal * 5,
                                right:
                                SizeConfig.blockSizeHorizontal * 5),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(18.0),
                                side: const BorderSide(
                                    color: Colors.grey, width: 0.5)),
                            onPressed: () async {
                              String lvl = widget.friendInfo[LANGUAGES]
                              [widget.language];
                              if(widget.friendInfo[LANGUAGES][widget.language] == BEGINNER
                                  || widget.userInfo[LANGUAGES][widget.language] == BEGINNER){
                                lvl = BEGINNER;
                              }else if (widget.friendInfo[LANGUAGES][widget.language] == INTERMEDIATE
                                  || widget.userInfo[LANGUAGES][widget.language] == INTERMEDIATE){
                                lvl = INTERMEDIATE;
                              }else{
                                lvl = ADVANCED;
                              }
                              //print("widget.userID = " + widget.userID + " widget.friendInfo[uid] = " +widget.friendInfo["UID"] + "widget.language = " + widget.language + "lvl = " +lvl);
                              gameID = await FirebaseDB.Firebase_db
                                  .makeNewGame(
                                  widget.userID,
                                  widget.friendInfo["UID"],
                                  widget.language,
                                  lvl);
                              updateAcceptedGame(widget.chatID,
                                  widget.userID, snapshot.id);
                            },
                            child: const Text("Accept",
                                style: TextStyle(
                                    color: Colors.white)),
                          ),
                          RawMaterialButton(
                            elevation: 2,
                            fillColor: CANCEL_GAME_COLOR,
                            padding: EdgeInsets.only(
                                left:
                                SizeConfig.blockSizeHorizontal * 5,
                                right:
                                SizeConfig.blockSizeHorizontal * 5),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(18.0),
                                side: const BorderSide(
                                    color: Colors.grey, width: 0.5)),
                            onPressed: () async {
                              FirebaseDB.Firebase_db.cancelGameInvite(
                                  widget.userID,
                                  widget.chatID,
                                  snapshot.id);
                            },
                            child: const Text("Decline",
                                style: TextStyle(
                                    color: Colors.white)),
                          ),
                        ],
                      )
                    ],
                  )),
              Container(
                padding: snapshot[MESSAGE_ID_FROM] == widget.userID
                    ? const EdgeInsets.fromLTRB(0, 0, 10, 0)
                    : const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(
                  timeConverter(snapshot[MESSAGE_TIMESTAMP]),
                  style: const TextStyle(
                      fontSize: MESSAGE_DATE_FONT_SIZE, color: Colors.grey),
                ),
              )
            ],
          ),
        ),
      ],
    );

    // });
  }

  Widget _buildGameCanceled(DocumentSnapshot snapshot) {
    String canceledBy = snapshot[MESSAGE_CONTENT] == widget.userID
        ? "You"
        : widget.friendInfo[USERNAME];
    String verb =
    snapshot[MESSAGE_ID_FROM] == widget.userID ? "canceled" : "declined";
    return Row(
      mainAxisAlignment: snapshot[MESSAGE_ID_FROM] == widget.userID
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: snapshot[MESSAGE_ID_FROM] == widget.userID
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                  constraints: BoxConstraints(
                      minWidth: SizeConfig.blockSizeHorizontal * 10,
                      maxWidth: SizeConfig.blockSizeHorizontal * 80),
                  padding: const EdgeInsets.all(MESSAGE_PADDING),
                  margin: snapshot[MESSAGE_ID_FROM] == widget.userID
                      ? const EdgeInsets.fromLTRB(5, 5, 10, 5)
                      : const EdgeInsets.fromLTRB(10, 5, 5, 5),
                  decoration: BoxDecoration(
                    color: snapshot[MESSAGE_ID_FROM] == widget.userID
                        ? SENT_MESSAGE_BACKGROUND_COLOR
                        : Colors.white,
                    borderRadius: BorderRadius.circular(MESSAGE_RADIUS),
                    border: Border.all(color: Colors.grey,width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0.8,
                        blurRadius: 1.2,
                        offset: const Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                              "$canceledBy $verb the game",
                              style: TextStyle(
                                  fontSize:
                                  SizeConfig.blockSizeHorizontal * 5)),
                        ),
                        Flexible(
                          child: Text("invitation",
                              style: TextStyle(
                                  fontSize:
                                  SizeConfig.blockSizeHorizontal * 5)),
                        ),
                      ],
                    ),
                  )),
              Container(
                padding: snapshot[MESSAGE_ID_FROM] == widget.userID
                    ? const EdgeInsets.fromLTRB(0, 0, 10, 0)
                    : const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(
                  timeConverter(snapshot[MESSAGE_TIMESTAMP]),
                  style: const TextStyle(
                      fontSize: MESSAGE_DATE_FONT_SIZE, color: Colors.grey),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSeparator(Timestamp timestamp) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            alignment: Alignment.center,
            //width: DATE_DIVIDER_WIDTH,
            padding: const EdgeInsets.all(MESSAGE_PADDING),
            margin: const EdgeInsets.all(MESSAGE_MARGIN),
            decoration: BoxDecoration(
              color: DATE_DIVIDER_COLOR,
              borderRadius: BorderRadius.circular(MESSAGE_RADIUS),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0.8,
                  blurRadius: 1.2,
                  offset: const Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Text(
                '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'))
      ],
    );
  }

  Widget _buildMessage(
      DocumentSnapshot snapshot, String userID, String chatID) {
    return GestureDetector(
      child: Row(
        //mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: snapshot[MESSAGE_ID_FROM] == userID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: snapshot[MESSAGE_ID_FROM] == userID
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                    constraints: BoxConstraints(
                        minWidth: SizeConfig.blockSizeHorizontal * 10,
                        maxWidth: SizeConfig.blockSizeHorizontal * 80),
                    //width: MESSAGE_WIDTH,
                    //height: snapshot[MESSAGE_TYPE] == MESSAGE_TYPE_IMAGE ? SizeConfig.blockSizeVertical * 40 :null,
                    padding: snapshot[MESSAGE_TYPE] == MESSAGE_TYPE_IMAGE
                        ? const EdgeInsets.all(4)
                        : const EdgeInsets.all(MESSAGE_PADDING),
                    margin: snapshot[MESSAGE_ID_FROM] == userID
                        ? const EdgeInsets.fromLTRB(5, 5, 10, 5)
                        : const EdgeInsets.fromLTRB(10, 5, 5, 5),
                    decoration: BoxDecoration(
                      color: snapshot[MESSAGE_ID_FROM] == userID
                          ? SENT_MESSAGE_BACKGROUND_COLOR
                          : Colors.white,
                      borderRadius: BorderRadius.circular(MESSAGE_RADIUS),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0.8,
                          blurRadius: 1.2,
                          offset: const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child: snapshot[MESSAGE_TYPE] == MESSAGE_TYPE_IMAGE
                              ? AspectRatio(
                            aspectRatio: 1.1,
                            child: Hero(
                              tag: snapshot[MESSAGE_TIMESTAMP],
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        MESSAGE_RADIUS),
                                    image: DecorationImage(
                                        alignment:
                                        FractionalOffset.center,
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            snapshot[MESSAGE_CONTENT]))),
                              ),
                            ),
                          )
                              : Padding(
                            padding:
                            const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Text(
                              snapshot[MESSAGE_CONTENT],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    )),
                Container(
                  padding: snapshot[MESSAGE_ID_FROM] == userID
                      ? const EdgeInsets.fromLTRB(0, 0, 10, 0)
                      : const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  //alignment: Alignment.bottomRight,
                  child: Text(
                    timeConverter(snapshot[MESSAGE_TIMESTAMP]),
                    style: const TextStyle(
                        fontSize: MESSAGE_DATE_FONT_SIZE, color: Colors.grey),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      onTap: () => snapshot[MESSAGE_TYPE] == MESSAGE_TYPE_IMAGE
          ? _showImage(snapshot[MESSAGE_CONTENT], snapshot[MESSAGE_TIMESTAMP])
          : null,
    );
  }

  String timeConverter(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    String hour = date.hour.toString();
    String minutes = date.minute.toString();
    if (date.hour < 10) {
      hour = '0$hour';
    }
    if (date.minute < 10) {
      minutes = '0$minutes';
    }
    return "$hour:$minutes";
  }

  _showImage(String imageUrl, Timestamp tag) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ShowImage(
          imageUrl: imageUrl,
          tag: tag,
        )));
  }

  updateAcceptedGame(String docId, String userId, String inviteID) {
    FirebaseFirestore.instance.collection(CHATS).doc(docId).update({
      "acceptedInviteUID": userId,
      "currentGame": gameID,
      INVITE_ID: inviteID
    });
  }
}
