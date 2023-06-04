import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../consts.dart';
import '../firebase/auth_repository.dart';

class FirebaseDB {
  static final FirebaseDB Firebase_db = FirebaseDB._internal();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  factory FirebaseDB() {
    return Firebase_db;
  }
  FirebaseDB._internal();

  Future<void> sendMessageNotification(BuildContext context,String message,String type, String username, String friendID)async {
    var url = Uri.parse("https://us-central1-socialang-980c8.cloudfunctions.net/sendMessageNotification");
    List tokens = [];
    var docs = await _db
        .collection(TOKENS)
        .where("UID",isEqualTo: friendID)
        .get();
    docs.docs.forEach((element) {
      tokens.add(element.data()["token"]);
    });
    if(type == MESSAGE_TYPE_IMAGE)
      message = "🖼️ Image";
    Map body = {
      "title" : username,
      "message" : message,
      "tokens" : tokens
    };
    http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body)
    ).then((value) {
      print("body: " + value.body + "\nstatus code" + value.statusCode.toString());
    }).catchError((onError) => _onMessageSendingError(context));
  }

  void markUnreadMessages(BuildContext context, String chatID, String userID, String friendID){
    DocumentReference documentReference = _db.collection(CHATS).doc(chatID);
    _db.
    runTransaction((transaction) async{
      transaction.update(documentReference, {
        UNREAD_MESSAGES + "." + friendID : FieldValue.increment(1)
      });
    });
  }

  void markReadMessages(String chatID, String userID) {
    DocumentReference documentReference = _db.collection(CHATS).doc(chatID);
    _db.
    runTransaction((transaction) async {
      transaction.update(documentReference, {
        UNREAD_MESSAGES + "." +userID : 0
      });
    });
  }

  Future<void> sendMessage(BuildContext context, String chatID,String message,String type, String userID, String username, String friendID) async {
    if(message.isEmpty){
      return;
    }
    Timestamp? lastMessageDate;

    await _db.
    collection(CHATS)
        .doc(chatID)
        .collection(MESSAGES_COLLECTION)
        .orderBy(MESSAGE_TIMESTAMP,descending: true)
        .limit(1)
        .get()
        .then((value) => {
      if(value.docs.isEmpty){
        _db
            .collection(CHATS)
            .doc(chatID)
            .collection(MESSAGES_COLLECTION)
            .add(
            {
              'message': "",
              'messageDate': Timestamp.now(),
              'messageType': MESSAGE_TYPE_DATE_DIVIDER,
              'sentBy': userID
            }
        ).catchError((onError) => _onMessageSendingError(context))
      }else {
        lastMessageDate = value.docs[0].data()[MESSAGE_TIMESTAMP]
      }
    })
        .catchError((onError) => _onMessageSendingError(context)
    );

    if(lastMessageDate != null){
      DateTime currentDateTime = DateTime.now();
      DateTime lastMessageDateTime = lastMessageDate!.toDate();
      if(lastMessageDateTime.day != currentDateTime.day || lastMessageDateTime.month != currentDateTime.month ||
          lastMessageDateTime.year != currentDateTime.year){
        _db
            .collection(CHATS)
            .doc(chatID)
            .collection(MESSAGES_COLLECTION)
            .add(
            {
              'message': "",
              'messageDate': Timestamp.now(),
              'messageType': "DateDivider",
              'sentBy': userID
            }
        ).catchError((onError) => _onMessageSendingError(context));
      }
    }
    _db
        .collection(CHATS)
        .doc(chatID)
        .collection(MESSAGES_COLLECTION)
        .add(
        {
          'message': message,
          'messageDate': Timestamp.now(),
          'messageType': type,
          'sentBy': userID
        }
    ).then((value) => {
      _db
          .collection(CHATS)
          .doc(chatID)
          .update({
        'lastMessageSent' : type == MESSAGE_TYPE_IMAGE ? "🖼️ Image" : message,
        'lastMessageDate' : Timestamp.now()
      }).catchError(_onMessageSendingError(context))
    }).catchError((onError) => _onMessageSendingError(context));
    markUnreadMessages(context, chatID, userID, friendID);
    sendMessageNotification(context, message, type, username, friendID);
  }

  Future<void> deleteMessage(String chatID, String messageID) async{
    _db
        .collection(CHATS)
        .doc(chatID)
        .collection(MESSAGES_COLLECTION)
        .doc(messageID)
        .delete();
  }

  Future<String> uploadImage(File image, String chatID, String imageID) async{
    FirebaseStorage storage = FirebaseStorage.instance;
    TaskSnapshot uploadTask = await storage
        .ref()
        .child("chats/" + chatID + '/'+ imageID)
        .putFile(image);
    String url = await uploadTask.ref.getDownloadURL();
    return url;
  }

  Future<String> getChatIdOfFriend(String currentUserID, String friendID, String language) async{
    String chatID = "";
    await _db
        .collection(CHATS)
        .get()
        .then((value) async {
      value.docs.forEach((element) {
        if (((element.data()["members"][0] == currentUserID && element.data()["members"][1] == friendID) ||
            (element.data()["members"][0] == friendID && element.data()["members"][1] == currentUserID))
            && element.data()["language"] == language) {
          chatID =  element.id;
        }
      });
      if(chatID.isEmpty){
        chatID = await makeNewChatWithFriend(currentUserID, friendID, language);
      }
    });
    return chatID;
  }

  Future<String> makeNewChatWithFriend(
      String currentUserID, String friendID, String language) async {
    String chatID = "";
    await _db.collection(CHATS).add({
      "lastMessageSent": "",
      "members": [currentUserID, friendID],
      "language": language
    }).then((value) {
      chatID = value.id;
      value.collection(MESSAGES_COLLECTION).add({
        'message': "",
        'messageDate': Timestamp.now(),
        'messageType': "DateDivider",
        'sentBy': currentUserID
      });
    });
    return chatID;
  }

  Future<void> addFriend(String friendUsername, BuildContext context) async{
    String currentUSerID = AuthRepository.instance().user!.uid;
    List friendsList = [];
    await _db
        .collection(USERS)
        .doc(currentUSerID)
        .get()
        .then((value) => friendsList = value.data()!["friends"]);
    friendsList.add(friendUsername);
    friendsList = friendsList.toSet().toList();
    await _db
        .collection(USERS)
        .doc(currentUSerID)
        .update({'friends': friendsList});
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('Friend added successfully'),
      duration: Duration(milliseconds: 1000),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> removeFriend(String friendUsername, BuildContext context) async{
    String currentUSerID = AuthRepository.instance().user!.uid;
    List friendsList = [];
    await _db
        .collection(USERS)
        .doc(currentUSerID)
        .get()
        .then((value) => friendsList = value.data()!["friends"]);
    friendsList.remove(friendUsername);
    friendsList = friendsList.toSet().toList();
    _db
        .collection(USERS)
        .doc(currentUSerID)
        .update({'friends': friendsList});
    final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Friend removed successfully'),
        duration: Duration(milliseconds: 1000)
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<List> searchChatWithRandom(Map userInfo, String language) async{
    String languageLevelUpper = userInfo[LANGUAGES][language];
    String languageLevel = languageLevelUpper.toLowerCase();
    List list = (await _db
        .collection(WAITING_LIST)
        .doc(language + "-" + languageLevel)
        .get())
        .data()!["waitingList"];
    return list;
  }

  Future<void> startChatWithRandom(Map userInfo ,String randomUID, String language, String chatID) async {
    String languageLevelUpper = userInfo[LANGUAGES][language];
    String languageLevel = languageLevelUpper.toLowerCase();
    //List UIDS = [userInfo["UID"], randomUID];
    DocumentReference documentReference = _db.collection(WAITING_LIST).doc(language + "-" + languageLevel);
    return _db.
    runTransaction((transaction) async{
      transaction.update(documentReference, {
        randomUID : userInfo["UID"],
      });
    });
/*    await _db.collection(WAITING_LIST)
        .doc(language + "-" + languageLevel)
        .update({
        "waitingList" : FieldValue.arrayRemove(UIDS)
    });*/
  }

  int getAge(String birthDate){
    List<String> birthDateList = birthDate.split(".");
    DateTime now = new DateTime.now();
    int age = now.year - int.parse(birthDateList[2]);
    if( now.month < int.parse(birthDateList[1]) ||
        (now.month == int.parse(birthDateList[1]) && now.day < int.parse(birthDateList[0]))) age--;
    return age;
  }

  addToWaitingList(Map userInfo, String language, String level){
    int age = getAge(userInfo["birthDate"]);
    Map waitingUserInfo = {
      "UID": userInfo["UID"],
      "maxAge": userInfo["maxAge"],
      "minAge": userInfo["minAge"],
      "preferred gender": userInfo["preferred gender"],
      "age" : age,
      "gender" : userInfo["gender"]
    };
    List list = [waitingUserInfo];
    DocumentReference documentReference = _db.collection(WAITING_LIST).doc(language + "-" + level);
    _db
        .runTransaction((transaction) async{
      transaction.update(documentReference, {
        WAITING_LIST : FieldValue.arrayUnion(list)
      });
    });
  }

  removeFromWaitingList(Map userInfo, String language, String level){
    int age = getAge(userInfo["birthDate"]);
    Map waitingUserInfo = {
      "UID": userInfo["UID"],
      "maxAge": userInfo["maxAge"],
      "minAge": userInfo["minAge"],
      "preferred gender": userInfo["preferred gender"],
      "age" : age,
      "gender" : userInfo["gender"]
    };
    List list = [waitingUserInfo];
    DocumentReference documentReference = _db.collection(WAITING_LIST).doc(language + "-" + level);
    _db
        .runTransaction((transaction) async{
      transaction.update(documentReference, {
        WAITING_LIST : FieldValue.arrayRemove(list)
      });
    });
  }

  void removeChatInvite(Map userInfo, String language){
    String languageLevelUpper = userInfo[LANGUAGES][language];
    String languageLevel = languageLevelUpper.toLowerCase();

    DocumentReference documentReference = _db.collection(WAITING_LIST).doc(language + "-" + languageLevel);
    _db
        .runTransaction((transaction) async{
      transaction.update(documentReference, {
        userInfo["UID"] : FieldValue.delete()
      });
    });
  }

  _onMessageSendingError(BuildContext context){
  }

  Future<String> makeNewGame(
      String uid1, String uid2, String lang, String lvl) async {
    List questions = await getQuestions(lang, lvl);
    int i = 1;
    for (Map q in questions){
      q["user1Answer"] = "";
      q["user2Answer"] = "";
      q["questionNumber"] = i;
      i++;
    }
    String gameId = "";
    await _db.collection(GAMES).add({
      "questions": questions,
      "uid1": uid1,
      "uid2": uid2,
      "language": lang,
      "level": lvl,
    }).then((value) {
      _db.collection(GAMES).doc(value.id).update({"gameId": value.id});
      gameId = value.id;
    });
    return gameId;
  }

  Future<void> cancelGameInvite(String userID,String chatID,String inviteID) async {
    _db
        .collection(CHATS)
        .doc(chatID)
        .collection(MESSAGES_COLLECTION)
        .doc(inviteID)
        .update({
      MESSAGE_CONTENT : userID,
      MESSAGE_TYPE : MESSAGE_TYPE_GAME_CANCELED
    });
  }

  Future<List> getQuestions(String lang, String lvl) async {
    var snapshot = await FirebaseDB()
        ._db
        .collection("questions")
        .doc(lang + "-" + lvl.toLowerCase())
        .get();
    List questions = snapshot.data()!["questions"];
    questions = shuffleList(questions);
    List picked = [];
    for (int i = 0; i < questions.length && i < 5; i++) {
      picked.add(questions[i]);
    }
    return picked;
  }

  List shuffleList(List items) {
    var random = new Random();
    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {
      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }
    return items;
  }

  void removeUserToken(String userID){
    _db
        .collection(TOKENS)
        .where("UID", isEqualTo: userID)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        _db.collection(TOKENS).doc(element.id).delete();
      });
    });
  }
/*  Future<bool> isChatWithUserExist(String currentUserID, String chatWithUserID) async{
    await _db.
            collection(CHATS)
            .where()
  }*/
/*  Future<bool> isChatWithUserExist(String currentUserID, String chatWithUserID) async{
    await _db.
            collection(CHATS)
            .where()
  }*/
}
