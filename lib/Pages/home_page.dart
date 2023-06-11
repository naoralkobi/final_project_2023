import 'dart:async';
import 'package:final_project_2023/consts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Widgets/nav_bar.dart';
import '../Widgets/start_chat.dart';
import 'add_question.dart';
import '../Widgets/chat_list.dart';
import 'package:final_project_2023/screen_size_config.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  Map userInfo = {};

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Variable to track whether a button is pressed or not.
  bool pressed = false;
  // Get the currently authenticated user using FirebaseAuth.
  var user = FirebaseAuth.instance.currentUser;
  // Determine if the user is an admin based on their email.
  // Only admins can add new questions to the game.
  bool isAdmin = [NAOR, AVIV, RON].contains(FirebaseAuth.instance.currentUser?.email);
  final TextEditingController _filter = TextEditingController();
  // The current search text entered by the user.
  String _searchText = "";
  // An Icon widget to display the search icon.
  Icon _searchIcon = const Icon(
    Icons.search,
    color: Colors.white,
    size: 30,
  );
  Widget _appBarTitle = const Text(
    "Friends List",
    style: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
  );
  // Variable to track whether the user is currently searching.
  bool isSearching = false;
  // A StreamController to manage a stream of blur values.
  StreamController<List<double>> blurController =
  StreamController<List<double>>();

  @override
  void initState() {
    // Get the instance of FirebaseMessaging for handling push notifications.
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    // Retrieve the device token for the current user.
    messaging.getToken().then((token) {
      // Get an instance of FirebaseFirestore for accessing the Firestore database.
      final FirebaseFirestore db = FirebaseFirestore.instance;
      // Query the 'tokens' collection to check if the token already exists.
      return db
          .collection(TOKENS)
          .where(TOKEN, isEqualTo: token)
          .get()
          .then((snapshot) async {
        if (snapshot.docs.isEmpty) {
          //debugPrint("before adding to db");
          // Add the token and user UID to the 'tokens' collection.
          return db
              .collection(TOKENS)
              .add({TOKEN: token, UID: user!.uid}).then((value) => null);
        }
      });
    });
    super.initState();
    // Listen to changes in the _filter TextEditingController.
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
    // Call a custom method to get user data of the current user.
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(USERS)
            .doc(user?.uid) // Use the null-aware operator here
            .snapshots(),
        builder: (BuildContext buildContext,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) return const Text(ERROR_MESSAGE);
          // If connecting, show progressIndicator
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data?.data() == null) {
            return const Center(child: SizedBox());
          } else {
            final data = snapshot.data?.data() as Map<String, dynamic>;
            return Scaffold(
              // left menu.
              drawer: NavBar(snapshot.data!.data()!,
                  blurController),
              resizeToAvoidBottomInset: false,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(18.0),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: Container(
                    color: MAIN_BLUE_COLOR,
                    child: SafeArea(
                      child: Container(
                        padding: EdgeInsets.only(
                            right: SizeConfig.blockSizeHorizontal * 1),
                        child: Row(
                          children: <Widget>[
                            const SizedBox(
                              width: 12,
                            ),
                            Builder(
                              builder: (context) => IconButton(
                                  icon: const Icon(Icons.menu),
                                  color: Colors.white,
                                  onPressed: () =>
                                      Scaffold.of(context).openDrawer()),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  if (isSearching)
                                    Theme(
                                      data: Theme.of(context)
                                          .copyWith(primaryColor: Colors.white),
                                      child: TextField(
                                        controller: _filter,
                                        autofocus: true,
                                        decoration: const InputDecoration(
                                            prefixIcon: Icon(Icons.search),
                                            hintText: 'Search...'),
                                        cursorColor: Colors.white,
                                      ),
                                    )
                                  else
                                    const SizedBox(
                                      height: 3,
                                    ),
                                ],
                              ),
                            ),
                            isSearching
                                ? const SizedBox()
                                : isAdmin // Check if the user is an admin.
                                ? IconButton(
                              icon: Image.asset(
                                "assets/images/question.png",
                                width: SizeConfig.blockSizeHorizontal * 7,
                                height: SizeConfig.blockSizeVertical * 3,
                              ),
                              onPressed: () {
                                navigateToAddQuestion(context);
                              },
                            )
                                : const SizedBox(),
                            IconButton(
                              icon: _searchIcon,
                              iconSize: SizeConfig.blockSizeHorizontal * 7,
                              onPressed: () {
                                _searchPressed();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              body: ChatsList(
                  _searchText,
                  snapshot.data!.data()!,
                  blurController),
              floatingActionButtonLocation:
              FloatingActionButtonLocation.startFloat,
              floatingActionButton: SizedBox(
                height: SizeConfig.blockSizeVertical * 10,
                width: SizeConfig.blockSizeHorizontal * 22,
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFF0077BE),
                  // new message icon
                  child: const Icon(
                    Icons.chat_outlined,
                    color: Colors.white,
                    size: 45,
                  ),
                  onPressed: () {
                    if (pressed) {
                      Navigator.of(context).pop();
                    } else {
                      blurController.add([1.5, 1.5]);
                      showDialog(
                          barrierColor: Colors.transparent,
                          context: context,
                          builder: (BuildContext context) =>
                              StartChat(blurController)).then((value) {
                        blurController.add([0, 0]);
                      });
                    }
                  },
                ),
              ),
            );
          }
        });
  }

  void navigateToAddQuestion(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddQuestion()));
  }

  void getUserData() async {
    // Get an instance of FirebaseFirestore for accessing the Firestore database.
    FirebaseFirestore.instance
        .collection(USERS)
        .doc(user!.uid)
        .get()
        .then((value) => widget.userInfo = value.data()!);
    // Update the widget's state to reflect the changes.
    setState(() {});
  }


  void _searchPressed() {
    setState(() {
      if (!isSearching) {
        _searchIcon = const Icon(
          Icons.close,
          size: 30,
          color: Colors.white,
        );
        _appBarTitle = Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.white),
          child: TextField(
            controller: _filter,
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Search...'),
            cursorColor: Colors.white,
          ),
        );
        isSearching = true;
      } else {
        _searchIcon = const Icon(
          Icons.search,
          color: Colors.white,
          size: 30,
        );
        isSearching = false;
        _filter.clear();
      }
    });
  }

  void clearSearch() {
    _filter.text = "";
    isSearching = false;
    _searchIcon = const Icon(
      Icons.search,
      color: Colors.white,
      size: 30,
    );
  }
}
