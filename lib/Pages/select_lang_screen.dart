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
      Map languages = value.data()![LANGUAGES];
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
    // Obtain the current user's ID from the AuthRepository
    String currentUserID = AuthRepository.instance().user!.uid;
    // Initialize the SizeConfig to provide responsive sizing
    SizeConfig().init(context);
    // Return a Dialog widget
    return Dialog(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.blueAccent, width: 2),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: StreamBuilder(
        // Stream data from Firestore collection using the current user's ID
        stream: FirebaseFirestore.instance
            .collection(USERS)
            .doc(currentUserID)
            .snapshots(),
        builder: (BuildContext buildContext,
            AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return const Text(ERROR_MESSAGE);
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return const CircularProgressIndicator();
          } else {
            // Create a dropdown menu for selecting a language
            return Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(CHOOSE_A_LANGAUGE,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.grey[200],
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text(CHOOSE_A_LANGAUGE),
                      underline: Container(),
                      value: languageId,
                      // Map the list of languages to dropdown menu items
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
                  // Show a text error message if no language is selected
                  isLangSelected
                      ? Container()
                      : Text(
                          MUST_PICK_LANGAUGE,
                          style: TextStyle(color: Colors.red[800]),
                        ),
                  const SizedBox(height: 20.0),
                  // Show a CircularProgressIndicator if the chat is loading
                  isLoadingChat
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFB9D9EB)))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            // Validate the language selection and navigate accordingly
                            if (languageId == null) {
                              setState(() {
                                isLangSelected = false;
                              });
                            } else {
                              if (widget.searchQuery == YOUTUBE) {
                                navigateToYoutube(context, languageId!);
                              } else {
                                navigateToSpeechReco(context, languageId!);
                              }
                            }
                          },
                          child: const Text(OK,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
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
            builder: (context) => SpeechRecognitionScreen(
                  selectedLanguage: langAndLevel,
                )));
  }

  void navigateToYoutube(context, String language) {
    // Get the language level based on the selected language
    String? languageLevel = languageToLevel[language]?.toLowerCase();
    // Create a string representing the language and its level
    String langAndLevel = "learning $language for $languageLevel";
    // Navigate to the YouTubeVideoListPage passing the language and level as a search query
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                YouTubeVideoListPage(searchQuery: langAndLevel)));
  }
}
