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
import '../Pages/view_user_profile.dart';
import '../consts.dart';
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
        .collection(USERS)
        .doc(currentUser!.uid)
        .snapshots(),
    builder:
    (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
    if (snapshot.hasError) {
    return const Text('Something went wrong');
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
    return const CircularProgressIndicator();
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
                child: Text(data[USERNAME]),
              ),
              const SizedBox(width: 5),
              Row(
                children: [
                  ImageIcon(
                    const AssetImage("assets/images/trophy.png"),
                    color: Colors.white,
                    size: SizeConfig.blockSizeHorizontal * 4,
                  ),
                  const SizedBox(width: 3),
                  (snapshot.data!.data() as Map<String, dynamic>).containsKey(SCORE)
                      ? Text(
                    snapshot.data![SCORE].toString(),
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 3.3,
                      color: Colors.white,
                    ),
                  )
                      : const Text(""),
                ],
              ),
            ],
          ),
        accountEmail: Text(data[EMAIL]),
          currentAccountPicture: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ViewUserProfile(
                              (snapshot.data!.data() as Map<String, dynamic>)[UID])));
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
            decoration: const BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                      'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Friends'),
            onTap: () {
              navigateToFriendsList(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard),
            title: const Text('Leaderboard'),
            onTap: () {
              navigateToLeaderboard(context, userInfo);
            },
          ),

          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text('Learn to speak'),
            onTap: () {
              navigateToSpeechRecognition(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.play_arrow_outlined),
            title: const Text('Learn with videos'),
            onTap: () {
              navigateToYoutube(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: const Text('Translate'),
            onTap: () =>
            {
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TranslationScreen()),
            )
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('About'),
            onTap: () => {
              showAboutDialog(
              context: context,
              applicationName: 'EasyLang',
              applicationVersion: '1.0.0',
              applicationLegalese:
              '© Developed by Naor Alkobi, Ron Harel and Aviv Harel.',
              children: [
              TextButton(
              onPressed: () => launch(
              'https://github.com/naoralkobi/final_project_2023'),
              child: const Text(
              'Privacy Policy',
              )),
              TextButton(
              onPressed: () => launch(
              'https://github.com/naoralkobi/final_project_2023'),
              child: const Text('Terms of Service'),
              ),
              ])
              },
          ),
          const Divider(),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          AuthRepository.instance().signOut();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (BuildContext context) {
                              return const LoginPage();
                            }),
                                (route) => false,
                          );
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
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

  //  This function is responsible for
  //  showing a dialog in the application when invoked.
  // input:
  // context -  represents the current build context of the application.
  //  The purpose of a callback function is to be called or executed by the
  //  receiving function at a specific point or in response to a particular
  //  event.
  void navigateToYoutube(context) {
    showDialog(
      // the dialog will be displayed without any background color overlay
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        // sets the blur effect to 1.5 in both horizontal and vertical directions
        blurController.add([1.5, 1.5]);
        return ChooseLanguageSpeech(searchQuery: YOUTUBE);
      },
    ).then((value) => blurController.add([0, 0]));
  }

}