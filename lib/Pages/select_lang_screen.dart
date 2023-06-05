import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_2023/Pages/speech_recognition.dart';
import 'package:final_project_2023/Pages/video_learning_page.dart';
import 'package:final_project_2023/consts.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/screen_size_config.dart';
import '../FireBase/auth_repository.dart';

class ChooseLanguageSpeech extends StatefulWidget {

  StreamController<List<double>>? blurController;
  final String searchQuery;

  ChooseLanguageSpeech({required this.searchQuery});


  @override
  ChooseLanguageSpeechState createState() {
    return ChooseLanguageSpeechState();
  }
}

class ChooseLanguageSpeechState extends State<ChooseLanguageSpeech> {
  bool isLangSelected = true;
  bool isLoadingChat = false;
  String? languageId;
  List<String> languagesList = [];
  Map<String, String> languageToLevel = {};


  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection(USERS)
        .doc(AuthRepository.instance().user!.uid)
        .get()
        .then((value) {
      Map languages = value.data()!['Languages'];
        setState(() {
          languages.forEach((key, value) {
            // list of user's languages.
            languagesList.add(key);
            // mapping between language to the user level.
            languageToLevel[key] = value;
          });
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentUserID = AuthRepository.instance().user!.uid;
    SizeConfig().init(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.blueAccent, width: 2),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(USERS)
            .doc(currentUserID)
            .snapshots(),
        builder: (BuildContext buildContext, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return const Text(ERROR_MESSAGE);
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return const CircularProgressIndicator();
          } else {
            return Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Choose a Language", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.grey[200],
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("Select Language"),
                      underline: Container(),
                      value: languageId,
                      items: languagesList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          isLangSelected = true;
                          languageId = newVal!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  isLangSelected
                      ? Container()
                      : Text(
                    "You must pick a preferred language",
                    style: TextStyle(color: Colors.red[800]),
                  ),
                  const SizedBox(height: 20.0),
                  isLoadingChat
                      ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB9D9EB)))
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (languageId == null) {
                        setState(() {
                          isLangSelected = false;
                        });
                      } else {
                        if (widget.searchQuery == "Youtube"){
                          navigateToYoutube(context, languageId!);
                        }
                        else {
                          navigateToSpeechReco(context, languageId!);
                        }
                      }
                    },
                    child: const Text("OK ", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
  void navigateToSpeechReco(context, String language) {
    // each document is in format ==> language - level.
    String? languageLevel = languageToLevel[language]?.toLowerCase();
    // building query].
    String langAndLevel = "$language-$languageLevel";
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>  SpeechRecognitionScreen(
              selectedLanguage: langAndLevel,
            )));
  }

  void navigateToYoutube(context, String language) {
    String? languageLevel = languageToLevel[language]?.toLowerCase();
    String langAndLevel = "learning $language for $languageLevel";
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => YouTubeVideoListPage(searchQuery: langAndLevel )));
  }
}
