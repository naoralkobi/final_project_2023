import 'dart:async';
import 'dart:ui';
import 'package:final_project_2023/Pages/select_lang_screen.dart';
import 'package:final_project_2023/Pages/view_user_profile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../FireBase/auth_repository.dart';
import '../Widgets/custom_pop_up_menu.dart';
import '../Widgets/start_chat.dart';
import '../utils/colors.dart';
import 'add_question.dart';
import 'friends_list.dart';
import 'leader_board.dart';
import 'login_page.dart';
import 'register_page.dart';
import '../Widgets/chat_list.dart';
import 'package:final_project_2023/screen_size_config.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  Map userInfo = {};
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool pressed = false;
  var user = FirebaseAuth.instance.currentUser;
  final notImplementedSnackBar = SnackBar(
    duration: Duration(milliseconds: 1000),
    content: Text('Not implemented yet!'),
    behavior: SnackBarBehavior.floating,
  );
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  Icon _searchIcon = Icon(
    Icons.search,
    color: Colors.white,
    size: 30,
  );
  Widget _appBarTitle = Text(
    "Friends List",
    style: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
  );
  bool isSearching = false;
  StreamController<List<double>> blurController =
  StreamController<List<double>>();

  @override
  void initState() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.getToken().then((token) {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      return db.collection('tokens').where('token', isEqualTo: token)
          .get().then((snapshot) async {
        if (snapshot.docs.isEmpty) {
          print("before adding to db");
          return db
              .collection('tokens')
              .add({'token': token, 'UID': user!.uid})
              .then((value) => null);
        }
      });
    });
    super.initState();
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
    getUserData();
  }

  @override
  // Widget build(BuildContext context) {
  //   SizeConfig().init(context);
  //   return StreamBuilder(
  //   stream: FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(user!.uid)
  //       .snapshots(),
  //   builder: (BuildContext buildContext,
  //   AsyncSnapshot<DocumentSnapshot> snapshot) {
  //   if (snapshot.hasError) return Text("There has been an error");
  //   //if connecting show progressIndicator
  //   if (snapshot.connectionState == ConnectionState.waiting &&
  //   snapshot.data == null)
  //   return Center(child: SizedBox());
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user?.uid) // Use the null-aware operator here
            .snapshots(),
        builder: (BuildContext buildContext, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return Text("There has been an error");
          // If connecting, show progressIndicator
          if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null)
            return Center(child: SizedBox());
    else {
      if (!(snapshot.data!.data() as Map<String, dynamic>).containsKey('score')) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .update(
    {
    'score': 0,
    },
    );
    }
    return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: PreferredSize(
    preferredSize: Size.fromHeight(70),
    child: AppBar(
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
    bottom: Radius.circular(18.0),
    ),
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    automaticallyImplyLeading: false,
    flexibleSpace: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [
    hexStringToColor("0077be"),
    hexStringToColor("00bfff"),
    hexStringToColor("40e0d0")
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter
    )
    ),
    child: SafeArea(
    child: Container(
    padding: EdgeInsets.only(
    right: SizeConfig.blockSizeHorizontal * 1),
    child: Row(
    children: <Widget>[
    SizedBox(
    width: 12,
    ),
    GestureDetector(
    onTap: () =>
    {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) =>
    ViewUserProfile(
        (snapshot.data!.data() as Map<String, dynamic>)["UID"])))
        .then((value) => clearSearch()),
    },
    child: CircleAvatar(
    backgroundImage:
    NetworkImage(snapshot.data!['URL']),
    maxRadius: 20,
    ),
    ),
    SizedBox(
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
    decoration: new InputDecoration(
    prefixIcon: new Icon(Icons.search),
    hintText: 'Search...'),
    cursorColor: Colors.white,
    ),
    )
    else
    Column(
    crossAxisAlignment:
    CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
      snapshot.data!["username"],
      style: TextStyle(
          fontSize:
          SizeConfig.blockSizeHorizontal *
              5,
          fontWeight: FontWeight.w600,
          color: Colors.white),
    ),
    SizedBox(
    height: 3,
    ),
    Visibility(
      visible: (snapshot.data!.data() as Map<String, dynamic>).containsKey('score'),
      child: Row(
        children: [
          ImageIcon(
            AssetImage(
                "assets/images/trophy.png"),
            color: Colors.white,
            size: SizeConfig
                .blockSizeHorizontal *
                4,
          ),
          SizedBox(
            width: 3,
          ),
          (snapshot.data!.data() as Map<String, dynamic>).containsKey('score')
              ? Text(
            snapshot.data!["score"]
                .toString(),
            style: TextStyle(
                fontSize: SizeConfig
                    .blockSizeHorizontal *
                    3.3,
                color: Colors.white),
          )
              : Text("")
        ],
      ),
    )
    ],
    ),
    SizedBox(
    height: 3,
    ),
    ],
    ),
    ),
    isSearching
    ? SizedBox()
        : IconButton(
    icon: Image.asset(
    "assets/images/question.png",
    width: SizeConfig.blockSizeHorizontal * 7,
    height: SizeConfig.blockSizeVertical * 3,
    ),
    onPressed: () {
    navigateToAddQuestion(context);
    }),
    IconButton(
    icon: _searchIcon,
    iconSize: SizeConfig.blockSizeHorizontal * 7,
    onPressed: () {
    //_searchPressed();
    },
    ),
    CustomPopupMenuButton<String>(
    onSelected: (value) => handleClick(value, context),
    color: Colors.white,
    shape: RoundedRectangleBorder(
    side: BorderSide(color: Colors.grey, width: 1),
    borderRadius: BorderRadius.circular(18.0)),
    icon: Icon(
    Icons.more_vert,
    color: Colors.white,
    ),
    itemBuilder: (BuildContext context) {
    return {'Logout', 'About'}.map((String choice) {
    return PopupMenuItem<String>(
    value: choice,
    child: FittedBox(
    child: Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment:
    MainAxisAlignment.spaceEvenly,
    children: [
    Container(
    child: Text(choice),
    width:
    SizeConfig.blockSizeHorizontal *
    15,
    ),
    SizedBox(
    width:
    SizeConfig.blockSizeHorizontal *
    2,
    ),
    Icon(choice == "Logout"
    ? Icons.logout
        : Icons.info_outline)
    ]),
    ),
    );
    }).toList();
    },
    ),
    ],
    ),
    ),
    ),
    ),
    ),
    ),
    body: ChatsList(_searchText, snapshot.data!.data()! as Map<dynamic, dynamic>,blurController),
    floatingActionButtonLocation:
    FloatingActionButtonLocation.startFloat,
    floatingActionButton: Container(
    height: SizeConfig.blockSizeVertical * 10,
    width: SizeConfig.blockSizeHorizontal * 22,
    child: FloatingActionButton(
    backgroundColor: Color(0xFF0077BE),
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
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: SizeConfig.blockSizeVertical * 8,
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: SizeConfig.blockSizeHorizontal * 4),
                  child: IconButton(
                    iconSize: SizeConfig.blockSizeHorizontal * 10,
                    icon: Icon(Icons.leaderboard_rounded),
                    color: Colors.white,
                    onPressed: () {
                      navigateToLeaderboard(
                          context, snapshot.data!.data()! as Map<String, dynamic>);
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: SizeConfig.blockSizeHorizontal * 2,
                      right: SizeConfig.blockSizeHorizontal * 2),
                  child: IconButton(
                    iconSize: SizeConfig.blockSizeHorizontal * 10,
                    icon: Icon(Icons.mic),
                    color: Colors.white,
                    onPressed: () {
                      navigateToSpeechRecognition(context);
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.only(
                      right: SizeConfig.blockSizeHorizontal * 4),
                  child: IconButton(
                    iconSize: SizeConfig.blockSizeHorizontal * 10,
                    icon: Icon(Icons.people_alt_rounded),
                    color: Colors.white,
                    onPressed: () {
                      navigateToFriendsList(context);
                    },
                  ),
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                hexStringToColor("0077be"),
                hexStringToColor("00bfff"),
                hexStringToColor("40e0d0")
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,),
          ),
        ),
      ),

    );
    }
    });
  }


  void handleClick(String value, BuildContext context) {
    switch (value) {
      case 'Logout':
        AuthRepository.instance().signOut();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) {
            return LoginPage();
          }),
              (route) => false,
        );


        break;
    case 'About':
      showAboutDialog(
          context: context,
          applicationName: 'lang',
          applicationVersion: '1.0.0',
          applicationLegalese:
          '© Developed by Naor Alkobi, Ron Harel and Aviv Harel.',
          children: [
            TextButton(
                onPressed: () => launch(
                    'https://github.com/naoralkobi/final_project_2023'),
                child: Text(
                  'Privacy Policy',
                )),
            TextButton(
              onPressed: () => launch(
                  'https://github.com/naoralkobi/final_project_2023'),
              child: Text('Terms of Service'),
            ),
          ]);
    }
  }
  void navigateToFriendsList(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => FriendsList(false)));
  }
  
    void navigateToLeaderboard(context, Map userInfo) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Leaderboard(userInfo)));
  }

  void navigateToAddQuestion(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddQuestion()));
  }

  void navigateToSpeechRecognition(context) {
    Navigator.push(context,
    MaterialPageRoute(builder: (context) => ChooseLanguageSpeech()));
  }

  void getUserData() async {
    print("in user data");
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) => widget.userInfo = value.data()!);
    setState(() {});
  }


  void clearSearch() {
    _filter.text = "";
    isSearching = false;
    this._searchIcon = new Icon(
      Icons.search,
      color: Colors.white,
      size: 30,
    );
  }
}
