import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../consts.dart';
import '../firebase/auth_repository.dart';

class FirebaseDB {
  static final FirebaseDB firebaseDb = FirebaseDB._internal();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  factory FirebaseDB() {
    return firebaseDb;
  }

  FirebaseDB._internal();

  Future<void> sendMessageNotification(BuildContext context, String message,
      String type, String username, String friendID) async {
  }

  /// Marks unread messages in a chat between two users.
  ///
  /// Parameters:
  /// - [context]: The build context.
  /// - [chatID]: The ID of the chat.
  /// - [userID]: The ID of the current user.
  /// - [friendID]: The ID of the friend user.
  void markUnreadMessages(
      BuildContext context, String chatID, String userID, String friendID) {
    // Get the reference to the chat document in the database
    DocumentReference documentReference = _db.collection(CHATS).doc(chatID);

    // Run a transaction to update the unread messages count for the friend user
    _db.runTransaction((transaction) async {
      transaction.update(documentReference, {
        "$UNREAD_MESSAGES.$friendID": FieldValue.increment(1)
      });
    });
  }


  /// Marks all messages in a chat as read for a specific user.
  ///
  /// Parameters:
  /// - [chatID]: The ID of the chat.
  /// - [userID]: The ID of the user.
  void markReadMessages(String chatID, String userID) {
    // Get the reference to the chat document in the database
    DocumentReference documentReference = _db.collection(CHATS).doc(chatID);

    // Run a transaction to update the unread messages count for the user to 0
    _db.runTransaction((transaction) async {
      transaction.update(documentReference, {
        "$UNREAD_MESSAGES.$userID": 0
      });
    });
  }


  /// Sends a message in a chat.
  ///
  /// Parameters:
  /// - [context]: The build context.
  /// - [chatID]: The ID of the chat.
  /// - [message]: The content of the message.
  /// - [type]: The type of message (e.g., text or image).
  /// - [userID]: The ID of the user sending the message.
  /// - [username]: The username of the user sending the message.
  /// - [friendID]: The ID of the friend receiving the message.
  Future<void> sendMessage(
      BuildContext context,
      String chatID,
      String message,
      String type,
      String userID,
      String username,
      String friendID) async {

    if (message.isEmpty) {
      return;
    }

    Timestamp? lastMessageDate;

    // Retrieve the last message in the chat
    await _db
        .collection(CHATS)
        .doc(chatID)
        .collection(MESSAGES_COLLECTION)
        .orderBy(MESSAGE_TIMESTAMP, descending: true)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        // Add an empty date divider message if no previous messages exist
        _db
            .collection(CHATS)
            .doc(chatID)
            .collection(MESSAGES_COLLECTION)
            .add({
          'message': "",
          'messageDate': Timestamp.now(),
          'messageType': MESSAGE_TYPE_DATE_DIVIDER,
          'sentBy': userID
        }).catchError((onError) => _onMessageSendingError(context));
      } else {
        lastMessageDate = value.docs[0].data()[MESSAGE_TIMESTAMP];
      }
    }).catchError((onError) => _onMessageSendingError(context));

    if (lastMessageDate != null) {
      DateTime currentDateTime = DateTime.now();
      DateTime lastMessageDateTime = lastMessageDate!.toDate();
      if (lastMessageDateTime.day != currentDateTime.day ||
          lastMessageDateTime.month != currentDateTime.month ||
          lastMessageDateTime.year != currentDateTime.year) {
        // Add a date divider message if the last message was sent on a different day
        _db
            .collection(CHATS)
            .doc(chatID)
            .collection(MESSAGES_COLLECTION)
            .add({
          'message': "",
          'messageDate': Timestamp.now(),
          'messageType': "DateDivider",
          'sentBy': userID
        }).catchError((onError) => _onMessageSendingError(context));
      }
    }

    // Add the new message to the chat
    _db
        .collection(CHATS)
        .doc(chatID)
        .collection(MESSAGES_COLLECTION)
        .add({
      'message': message,
      'messageDate': Timestamp.now(),
      'messageType': type,
      'sentBy': userID
    }).then((value) {
      // Update the chat document with the latest message information
      _db
          .collection(CHATS)
          .doc(chatID)
          .update({
        'lastMessageSent': type == MESSAGE_TYPE_IMAGE ? "🖼️ Image" : message,
        'lastMessageDate': Timestamp.now()
      }).catchError(_onMessageSendingError(context));
    }).catchError((onError) => _onMessageSendingError(context));

    // Mark unread messages as read
    markUnreadMessages(context, chatID, userID, friendID);

    // Send a message notification
    sendMessageNotification(context, message, type, username, friendID);
  }

  /// Uploads an image file to Firebase Storage and returns the download URL.
  ///
  /// Parameters:
  /// - [image]: The image file to be uploaded.
  /// - [chatID]: The ID of the chat associated with the image.
  /// - [imageID]: The ID of the image.
  ///
  /// Returns:
  /// The download URL of the uploaded image.
  Future<String> uploadImage(File image, String chatID, String imageID) async {
    FirebaseStorage storage = FirebaseStorage.instance;

    // Upload the image file to the specified location in Firebase Storage
    TaskSnapshot uploadTask = await storage
        .ref()
        .child("chats/" + chatID + '/' + imageID)
        .putFile(image);

    // Get the download URL of the uploaded image
    String url = await uploadTask.ref.getDownloadURL();
    return url;
  }


  /// Retrieves the chat ID associated with a conversation between the current user and a friend.
  ///
  /// Parameters:
  /// - [currentUserID]: The ID of the current user.
  /// - [friendID]: The ID of the friend.
  /// - [language]: The language associated with the chat.
  ///
  /// Returns:
  /// The chat ID of the conversation between the current user and the friend.
  Future<String> getChatIdOfFriend(String currentUserID, String friendID, String language) async {
    String chatID = "";

    // Query the CHATS collection to find the chat with the specified friend and language
    await _db.collection(CHATS).get().then((value) async {
      for (var element in value.docs) {
        if (((element.data()["members"][0] == currentUserID &&
            element.data()["members"][1] == friendID) ||
            (element.data()["members"][0] == friendID &&
                element.data()["members"][1] == currentUserID)) &&
            element.data()["language"] == language) {
          chatID = element.id;
        }
      }

      // If a chat ID is not found, create a new chat with the friend
      if (chatID.isEmpty) {
        chatID = await makeNewChatWithFriend(currentUserID, friendID, language);
      }
    });

    return chatID;
  }


  /// Creates a new chat with a friend.
  ///
  /// Parameters:
  /// - [currentUserID]: The ID of the current user.
  /// - [friendID]: The ID of the friend.
  /// - [language]: The language associated with the chat.
  ///
  /// Returns:
  /// The ID of the newly created chat.
  Future<String> makeNewChatWithFriend(String currentUserID, String friendID, String language) async {
    String chatID = "";

    // Add a new document to the CHATS collection
    await _db.collection(CHATS).add({
      "lastMessageSent": "",
      "members": [currentUserID, friendID],
      "language": language
    }).then((value) {
      chatID = value.id;

      // Create a subcollection for messages and add a document with a date divider message
      value.collection(MESSAGES_COLLECTION).add({
        'message': "",
        'messageDate': Timestamp.now(),
        'messageType': "DateDivider",
        'sentBy': currentUserID
      });
    });

    return chatID;
  }


  /// Adds a friend to the current user's friends list.
  ///
  /// Parameters:
  /// - [friendUsername]: The username of the friend to be added.
  /// - [context]: The BuildContext object for displaying the snackbar notification.
  ///
  /// Returns: Future<void>
  Future<void> addFriend(String friendUsername, BuildContext context) async {
    String currentUserID = AuthRepository.instance().user!.uid;
    List friendsList = [];

    // Retrieve the current user's friends list
    await _db.collection(USERS).doc(currentUserID).get().then((value) {
      friendsList = value.data()!["friends"];
    });

    // Add the friend's username to the friends list
    friendsList.add(friendUsername);

    // Remove any duplicate entries from the friends list
    friendsList = friendsList.toSet().toList();

    // Update the current user's document with the updated friends list
    await _db.collection(USERS).doc(currentUserID).update({'friends': friendsList});

    // Show a snackbar notification indicating the friend was added successfully
    const snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('Friend added successfully'),
      duration: Duration(milliseconds: 1000),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  /// Removes a friend from the current user's friends list.
  ///
  /// Parameters:
  /// - [friendUsername]: The username of the friend to be removed.
  /// - [context]: The BuildContext object for displaying the snackbar notification.
  ///
  /// Returns: Future<void>
  Future<void> removeFriend(String friendUsername, BuildContext context) async {
    String currentUserID = AuthRepository.instance().user!.uid;
    List friendsList = [];

    // Retrieve the current user's friends list
    await _db.collection(USERS).doc(currentUserID).get().then((value) {
      friendsList = value.data()!["friends"];
    });

    // Remove the friend's username from the friends list
    friendsList.remove(friendUsername);

    // Remove any duplicate entries from the friends list
    friendsList = friendsList.toSet().toList();

    // Update the current user's document with the updated friends list
    _db.collection(USERS).doc(currentUserID).update({'friends': friendsList});

    // Show a snackbar notification indicating the friend was removed successfully
    const snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('Friend removed successfully'),
      duration: Duration(milliseconds: 1000),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  /// Starts a chat with a randomly matched partner.
  ///
  /// Parameters:
  /// - [userInfo]: A map containing the user's information, including language levels.
  /// - [randomUID]: The UID of the randomly matched partner.
  /// - [language]: The language for the chat.
  /// - [chatID]: The ID of the chat.
  ///
  /// Returns: Future<void>
  Future<void> startChatWithRandom(Map userInfo, String randomUID, String language, String chatID) async {
    // Retrieve the user's language level for the specified language
    String languageLevelUpper = userInfo[LANGUAGES][language];
    String languageLevel = languageLevelUpper.toLowerCase();

    // Retrieve the document reference for the waiting list
    DocumentReference documentReference = _db.collection(WAITING_LIST).doc("$language-$languageLevel");

    // Update the document reference in a transaction to start the chat with the random partner
    return _db.runTransaction((transaction) async {
      transaction.update(documentReference, {
        randomUID: userInfo["UID"],
      });
    });
  }


  /// Calculates the age based on the given birth date.
  ///
  /// Parameters:
  /// - [birthDate]: The birth date in the format "day.month.year".
  ///
  /// Returns: The calculated age.
  int getAge(String birthDate) {
    // Split the birth date into day, month, and year
    List<String> birthDateList = birthDate.split(".");

    // Get the current date and time
    DateTime now = DateTime.now();

    // Calculate the age based on the current year and the birth year
    int age = now.year - int.parse(birthDateList[2]);

    // Check if the current month is before the birth month,
    // or if the current month is the birth month but the current day is before the birth day
    if (now.month < int.parse(birthDateList[1]) ||
        (now.month == int.parse(birthDateList[1]) &&
            now.day < int.parse(birthDateList[0]))) {
      age--;
    }

    // Return the calculated age
    return age;
  }


  /// Adds a user to the waiting list for a specific language and level.
  ///
  /// Parameters:
  /// - [userInfo]: User information including UID, birthDate, maxAge, minAge,
  ///   preferred gender, and gender.
  /// - [language]: The target language.
  /// - [level]: The language level.
  void addToWaitingList(Map userInfo, String language, String level) {
    // Calculate the user's age based on the birth date
    int age = getAge(userInfo["birthDate"]);

    // Create the waiting user information map
    Map<String, dynamic> waitingUserInfo = {
      "UID": userInfo["UID"],
      "maxAge": userInfo["maxAge"],
      "minAge": userInfo["minAge"],
      "preferred gender": userInfo["preferred gender"],
      "age": age,
      "gender": userInfo["gender"],
    };

    // Create a list containing the waiting user information
    List<Map<String, dynamic>> list = [waitingUserInfo];

    // Get the document reference for the specific language and level in the WAITING_LIST collection
    DocumentReference documentReference =
    _db.collection(WAITING_LIST).doc("$language-$level");

    // Run a transaction to update the waiting list document
    _db.runTransaction((transaction) async {
      transaction.update(documentReference, {
        WAITING_LIST: FieldValue.arrayUnion(list),
      });
    });
  }


  /// Removes a user from the waiting list for a specific language and level.
  ///
  /// Parameters:
  /// - [userInfo]: User information including UID, birthDate, maxAge, minAge,
  ///   preferred gender, and gender.
  /// - [language]: The target language.
  /// - [level]: The language level.
  void removeFromWaitingList(Map userInfo, String language, String level) {
    // Calculate the user's age based on the birth date
    int age = getAge(userInfo["birthDate"]);

    // Create the waiting user information map
    Map<String, dynamic> waitingUserInfo = {
      "UID": userInfo["UID"],
      "maxAge": userInfo["maxAge"],
      "minAge": userInfo["minAge"],
      "preferred gender": userInfo["preferred gender"],
      "age": age,
      "gender": userInfo["gender"],
    };

    // Create a list containing the waiting user information
    List<Map<String, dynamic>> list = [waitingUserInfo];

    // Get the document reference for the specific language and level in the WAITING_LIST collection
    DocumentReference documentReference =
    _db.collection(WAITING_LIST).doc("$language-$level");

    // Run a transaction to update the waiting list document
    _db.runTransaction((transaction) async {
      transaction.update(documentReference, {
        WAITING_LIST: FieldValue.arrayRemove(list),
      });
    });
  }


  /// Removes a chat invite for a specific user in the waiting list.
  ///
  /// Parameters:
  /// - [userInfo]: User information including UID and language levels.
  /// - [language]: The target language.
  void removeChatInvite(Map userInfo, String language) {
    // Get the language level based on the user's language information
    String languageLevelUpper = userInfo[LANGUAGES][language];
    String languageLevel = languageLevelUpper.toLowerCase();

    // Get the document reference for the specific language and level in the WAITING_LIST collection
    DocumentReference documentReference =
    _db.collection(WAITING_LIST).doc("$language-$languageLevel");

    // Run a transaction to remove the chat invite for the user
    _db.runTransaction((transaction) async {
      transaction.update(documentReference, {
        userInfo["UID"]: FieldValue.delete(),
      });
    });
  }


  _onMessageSendingError(BuildContext context) {
  }

  /// Creates a new game with two users and specified language and level.
  ///
  /// Parameters:
  /// - [uid1]: The ID of the first user.
  /// - [uid2]: The ID of the second user.
  /// - [lang]: The language of the game.
  /// - [lvl]: The level of the game.
  ///
  /// Returns:
  /// - The game ID of the newly created game.
  Future<String> makeNewGame(
      String uid1, String uid2, String lang, String lvl) async {
    // Retrieve questions based on the specified language and level
    List questions = await getQuestions(lang, lvl);

    // Initialize question properties and assign question numbers
    int i = 1;
    for (Map q in questions) {
      q["user1Answer"] = "";
      q["user2Answer"] = "";
      q["questionNumber"] = i;
      i++;
    }

    String gameId = "";

    // Create a new game document in the database
    await _db.collection(GAMES).add({
      "questions": questions,
      "uid1": uid1,
      "uid2": uid2,
      "language": lang,
      "level": lvl,
    }).then((value) {
      // Update the game document with the game ID
      _db.collection(GAMES).doc(value.id).update({"gameId": value.id});
      gameId = value.id;
    });

    return gameId;
  }

  /// Cancels a game invite by updating the corresponding message in the chat.
  ///
  /// Parameters:
  /// - [userID]: The ID of the user canceling the invite.
  /// - [chatID]: The ID of the chat.
  /// - [inviteID]: The ID of the game invite message.
  Future<void> cancelGameInvite(String userID, String chatID, String inviteID) async {
    // Get the document reference for the specific chat and invite message
    DocumentReference documentReference = _db
        .collection(CHATS)
        .doc(chatID)
        .collection(MESSAGES_COLLECTION)
        .doc(inviteID);

    // Update the message content and type to cancel the game invite
    await documentReference.update({
      MESSAGE_CONTENT: userID,
      MESSAGE_TYPE: MESSAGE_TYPE_GAME_CANCELED,
    });
  }


  /// Retrieves a list of questions from the Firestore database based on the specified language and level.
  ///
  /// Parameters:
  /// - [lang]: The language of the questions.
  /// - [lvl]: The level of the questions.
  ///
  /// Returns:
  /// A list of picked questions.
  Future<List> getQuestions(String lang, String lvl) async {
    // Retrieve the document snapshot for the specified language and level
    var snapshot = await FirebaseDB()
        ._db
        .collection("questions")
        .doc("$lang-${lvl.toLowerCase()}")
        .get();

    // Extract the list of questions from the snapshot data
    List questions = snapshot.data()!["questions"];

    // Shuffle the order of the questions
    questions = shuffleList(questions);

    // Pick a maximum of 5 questions
    List picked = [];
    for (int i = 0; i < questions.length && i < 5; i++) {
      picked.add(questions[i]);
    }

    // Return the picked questions
    return picked;
  }


  /// Shuffles the elements of a list using the Fisher-Yates algorithm.
  ///
  /// Parameters:
  /// - [items]: The list to be shuffled.
  ///
  /// Returns:
  /// The shuffled list.
  List shuffleList(List items) {
    var random = Random();

    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {
      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(i + 1);

      // Swap the elements at positions i and n
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }


  void removeUserToken(String userID) {
    _db
        .collection(TOKENS)
        .where("UID", isEqualTo: userID)
        .get()
        .then((value) {
      for (var element in value.docs) {
        _db.collection(TOKENS).doc(element.id).delete();
      }
    });
  }
}