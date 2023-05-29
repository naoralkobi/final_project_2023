import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Pages/friends_list.dart';
import '../Pages/leader_board.dart';
import '../Pages/login_page.dart';
import '../FireBase/auth_repository.dart';
import '../Pages/google_translate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Pages/select_lang_screen.dart';
import '../Pages/videoLearningPage.dart';
import '../Pages/view_user_profile.dart';
import '../screen_size_config.dart';

class NavBar extends StatelessWidget {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final Map<String, dynamic> userInfo;
  final StreamController<List<double>> blurController;
  NavBar(this.userInfo, this.blurController);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .snapshots(),
    builder:
    (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
    if (snapshot.hasError) {
    return Text('Something went wrong');
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
    return CircularProgressIndicator();
    }

    Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

        return Drawer(
        child: ListView(
        padding: EdgeInsets.zero,
        children: [
        UserAccountsDrawerHeader(
          accountName: Row(
            children: [
              Expanded(
                child: Text(data['username']),
              ),
              SizedBox(width: 5),
              Row(
                children: [
                  ImageIcon(
                    AssetImage("assets/images/trophy.png"),
                    color: Colors.white,
                    size: SizeConfig.blockSizeHorizontal * 4,
                  ),
                  SizedBox(width: 3),
                  (snapshot.data!.data() as Map<String, dynamic>).containsKey('score')
                      ? Text(
                    snapshot.data!["score"].toString(),
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 3.3,
                      color: Colors.white,
                    ),
                  )
                      : Text(""),
                ],
              ),
            ],
          ),
        accountEmail: Text(data['email']),
          currentAccountPicture: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ViewUserProfile(
                              (snapshot.data!.data() as Map<String, dynamic>)["UID"])));
            },
            child: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  data['URL'],
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
          ),
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                      'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Friends'),
            onTap: () {
              navigateToFriendsList(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.leaderboard),
            title: Text('Leaderboard'),
            onTap: () {
              navigateToLeaderboard(context, userInfo);
            },
          ),

          ListTile(
            leading: Icon(Icons.mic),
            title: Text('Learn to speak'),
            onTap: () {
              navigateToSpeechRecognition(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.play_arrow_outlined),
            title: Text('Learn with videos'),
            onTap: () {
              navigateToYoutube(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.translate),
            title: Text('Translate'),
            onTap: () =>
            {
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TranslationScreen()),
            )
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('About'),
            onTap: () => {
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
              ])
              },
          ),
          Divider(),
          ListTile(
            title: Text('Logout'),
            leading: Icon(Icons.exit_to_app),
            onTap: () {
              AuthRepository.instance().signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (BuildContext context) {
                  return LoginPage();
                }),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  },
    );
  }

  void navigateToFriendsList(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => FriendsList(false)));
  }

  void navigateToLeaderboard(context, Map userInfo) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Leaderboard(userInfo)));
  }

  void navigateToSpeechRecognition(context) {
  showDialog(
  barrierColor: Colors.transparent,
  context: context,
  builder: (BuildContext context) {
    blurController.add([1.5, 1.5]);
    return ChooseLanguageSpeech(searchQuery: "Speech");
    },
    ).then((value) => blurController.add([0, 0]));
  }


  void navigateToYoutube(context) {
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        blurController.add([1.5, 1.5]);
        return ChooseLanguageSpeech(searchQuery: "Youtube");
      },
    ).then((value) => blurController.add([0, 0]));
  }

}