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
    int myAge = FirebaseDB.Firebase_db.getAge(userInfo[BIRTHDATE]);

    // If the waitingList is empty, return an empty match string.
    if (waitingList.isEmpty) {
      return match;
    }

    // Iterate through the waitingList to find a matching friend.
    for (var friendInfo in waitingList) {
      if (friendInfo is Map && friendInfo.containsKey(UID) && userInfo.containsKey(UID)) {
        // Check if the friendInfo and userInfo contain the required keys.
        if (friendInfo[UID] != userInfo[UID]) {
          // Exclude the user itself from being a match.

          // Check if the age range of the friend and user overlaps.
          if ((myAge >= friendInfo[MIN_AGE] && myAge <= friendInfo[MAX_AGE]) &&
              (friendInfo[AGE] >= userInfo[MIN_AGE] && friendInfo[AGE] <= userInfo[MAX_AGE])) {

            // Check if the preferred genders match or if 'Dont Care' is selected.
            if ((friendInfo[PREFERRED_GENDER] == DONT_CARE ||
                friendInfo[PREFERRED_GENDER] == userInfo[GENDER]) &&
                (userInfo[PREFERRED_GENDER] == DONT_CARE ||
                    userInfo[PREFERRED_GENDER] == friendInfo[GENDER])) {
              // Set the match as the friend's UID.
              match = friendInfo[UID];
            }
          }
        }
      }
    }

    return match; // Return the matching friend's UID (if found).
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Listen to a stream of snapshots from Firestore.
      stream: FirebaseFirestore.instance
          .collection(WAITING_LIST)
          .doc("${widget.language}-$level")
          .snapshots(),
      builder: (
          BuildContext buildContext,
          AsyncSnapshot<DocumentSnapshot> snapshot,
          ) {
        if (snapshot.hasError) return const Text(ERROR_MESSAGE);

        // Show a progress indicator or loading state when connecting or if data is null.
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return dialog(context, widget.userInfo);
        } else if (snapshot.connectionState == ConnectionState.active) {
          // If a match is found, return an empty SizedBox to render nothing.
          if (isFound) return const SizedBox();

          // Check if the user's UID is in the waiting list data.
          if ((snapshot.data!.data() as Map<dynamic, dynamic>)
              .containsKey(widget.userInfo[UID])) {
            _enterChatPage(
              widget.language,
              (snapshot.data!.data() as Map<dynamic, dynamic>)[widget.userInfo[UID]],
              false,
              widget.userInfo,
            );
          } else {
            // Get the waiting list from the snapshot data.
            List waitingList = (snapshot.data!.data() as Map<String, dynamic>)[WAITING_LIST];

            // Find a match in the waiting list using the _findMatch method.
            String match = _findMatch(waitingList, widget.userInfo);

            // If no match is found and the user is not in the waiting list, add them to the waiting list.
            if (match.isEmpty && !isInWaitingList) {
              FirebaseDB.Firebase_db.addToWaitingList(
                widget.userInfo,
                widget.language,
                level,
              );
              isInWaitingList = true;
            }
            // If a match is found, enter the chat page with the match's UID.
            else if (match.isNotEmpty) {
              _enterChatPage(widget.language, match, true, widget.userInfo);
            }
          }
        }

        // Return a dialog widget with the user's information if none of the previous conditions match.
        return dialog(context, widget.userInfo);
      },
    );
  }


  void _enterChatPage(
      String language,
      String friendID,
      bool isCreateChat,
      Map userInfo,
      ) async {
    // Get the current user's ID using AuthRepository.
    String currentUserID = AuthRepository.instance().user!.uid;

    // Obtain the chat ID based on the current user's ID, friend's ID, and language.
    String chatID = await FirebaseDB.Firebase_db.getChatIdOfFriend(
      currentUserID,
      friendID,
      language,
    );

    // Set the 'isFound' flag to true.
    isFound = true;

    if (isCreateChat) {
      // If it's a new chat, start the chat with a random message.
      FirebaseDB.Firebase_db.startChatWithRandom(
        widget.userInfo,
        friendID,
        widget.language,
        chatID,
      );
    } else {
      // If it's not a new chat, remove the chat invite for the user.
      FirebaseDB.Firebase_db.removeChatInvite(userInfo, language);
    }

    if (isInWaitingList) {
      // If the user is in the waiting list, remove them from the waiting list.
      FirebaseDB.Firebase_db.removeFromWaitingList(
        widget.userInfo,
        widget.language,
        level,
      );
    }

    // Navigate to the chat page.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection(USERS)
                .doc(friendID)
                .get(),
            builder: (
                BuildContext buildContext,
                AsyncSnapshot<DocumentSnapshot> snapshot,
                ) {
              if (snapshot.hasError) return const Text(ERROR_MESSAGE);

              // Show a progress indicator while connecting.
              if (snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              } else {
                // Return the ChatPage widget with the necessary data.
                return ChatPage(
                  chatID,
                  currentUserID,
                  snapshot.data!.data()! as Map<String, dynamic>,
                  language,
                  widget.userInfo,
                );
              }
            },
          );
        },
      ),
    );
  }


  dialog(BuildContext context, Map userInfo) {
    return Dialog(
      // Configure the shape of the dialog.
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 5),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(PURPLE_COLOR),
              ),
            ),
            SizedBox(width: SizeConfig.blockSizeHorizontal * 6.5),
            const Text("Looking for a match..."),
            Container(
              margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 8),
              child: IconButton(
                icon: const Icon(Icons.cancel_outlined),
                onPressed: () {
                  // If the user is in the waiting list, remove them from the waiting list.
                  if (isInWaitingList) {
                    FirebaseDB.Firebase_db.removeFromWaitingList(
                      userInfo,
                      widget.language,
                      level,
                    );
                  }
                  Navigator.of(context).pop(); // Close the dialog.
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
