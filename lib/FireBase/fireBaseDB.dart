import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'auth_repository.dart';

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import '../consts.dart';

const String WAITING_LIST = 'waitingList';
const String CHATS = 'chats';
const String MESSAGES_COLLECTION = 'messages';

class FirebaseDB {
  static final FirebaseDB Firebase_db = FirebaseDB._internal();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  factory FirebaseDB() {
    return Firebase_db;
  }

  FirebaseDB._internal();

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

  Future<void> startChatWithRandom(Map userInfo ,String randomUID, String language, String chatID) async {
    String languageLevelUpper = userInfo["Languages"][language];
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

  void removeChatInvite(Map userInfo, String language){
    String languageLevelUpper = userInfo["Languages"][language];
    String languageLevel = languageLevelUpper.toLowerCase();

    DocumentReference documentReference = _db.collection(WAITING_LIST).doc(language + "-" + languageLevel);
    _db
        .runTransaction((transaction) async{
      transaction.update(documentReference, {
        userInfo["UID"] : FieldValue.delete()
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
}