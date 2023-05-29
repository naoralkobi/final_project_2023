import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_2023/Pages/speech_recognition.dart';
import 'package:final_project_2023/Pages/videoLearningPage.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/screen_size_config.dart';
import '../FireBase/auth_repository.dart';

class ChooseLanguageSpeech extends StatefulWidget {

  StreamController<List<double>>? blurController;
  final String searchQuery;

  ChooseLanguageSpeech({required this.searchQuery});


  @override
  ChooseLanguageSpeechState createState() {
    return new ChooseLanguageSpeechState();
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
        .collection('users')
        .doc(AuthRepository.instance().user!.uid)
        .get()
        .then((value) {
      Map languages = value.data()!['Languages'];
        setState(() {
          languages.forEach((key, value) {
            languagesList.add(key);
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
        side: BorderSide(color: Colors.blueAccent, width: 2),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserID)
            .snapshots(),
        builder: (BuildContext buildContext, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return Text("There has been an error");
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) return CircularProgressIndicator();
          else
            return Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Choose a Language", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.grey[200],
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text("Select Language"),
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
                  SizedBox(height: 10.0),
                  isLangSelected
                      ? Container()
                      : Text(
                    "You must pick a preferred language",
                    style: TextStyle(color: Colors.red[800]),
                  ),
                  SizedBox(height: 20.0),
                  isLoadingChat
                      ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB9D9EB)))
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
                    child: Text("OK ", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            );
        },
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   String currentUserID = AuthRepository.instance().user!.uid;
  //   SizeConfig().init(context);
  //   return new Dialog(
  //     shape: RoundedRectangleBorder(
  //         side: BorderSide(color: Colors.grey, width: 2),
  //         borderRadius: BorderRadius.circular(18.0)),
  //     child: StreamBuilder(
  //         stream: FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(currentUserID)
  //             .snapshots(),
  //         builder: (BuildContext buildContext,
  //             AsyncSnapshot<DocumentSnapshot> snapshot) {
  //           if (snapshot.hasError) return Text("There has been an error");
  //           //if connecting show progressIndicator
  //           if (snapshot.connectionState == ConnectionState.waiting &&
  //               snapshot.data == null) return SizedBox();
  //           else
  //             return Container(
  //               height: SizeConfig.blockSizeVertical * 30,
  //               child: new Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text("Choose a Language", style: TextStyle(fontSize: 18)),
  //                   SizedBox(
  //                     height: SizeConfig.blockSizeVertical * 3,
  //                   ),
  //                   Container(
  //                     padding: const EdgeInsets.only(left: 20.0, right: 20.0),
  //                     decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(10.0),
  //                         color: Color(0xFFDFDFDF),
  //                         border: Border.all(color: Colors.grey)),
  //                     child: DropdownButton<String>(
  //                         hint: Text("Language"),
  //                         underline: SizedBox.shrink(),
  //                         value: languageId,
  //                         items: languagesList.map((String value) {
  //                           return new DropdownMenuItem<String>(
  //                             value: value,
  //                             child: new Text(value),
  //                           );
  //                         }).toList(),
  //                         onChanged: (newVal) {
  //                           setState(() {
  //                             isLangSelected = true;
  //                             languageId = newVal!;
  //                           });
  //                         }),
  //                   ),
  //                   FittedBox(
  //                     fit: BoxFit.fitWidth,
  //                     child: isLangSelected
  //                         ? Text(" ")
  //                         : Text(
  //                       "You must pick a preferred language",
  //                       style: TextStyle(color: Colors.red[800]),
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: SizeConfig.blockSizeVertical * 2,
  //                   ),
  //                   Padding(
  //                     padding: EdgeInsets.only(
  //                         right: SizeConfig.blockSizeHorizontal * 4),
  //                     child: isLoadingChat
  //                         ? CircularProgressIndicator(
  //                         valueColor: AlwaysStoppedAnimation<Color>(
  //                             Color(0xFFB9D9EB)))
  //                         : Padding(
  //                       padding: EdgeInsets.only(
  //                           left: SizeConfig.blockSizeHorizontal * 4),
  //                       child: TextButton(
  //                         style: ButtonStyle(
  //                           minimumSize: MaterialStateProperty.all(Size(65, 36)),
  //                           backgroundColor: MaterialStateProperty.all(Color(0xFFB9D9EB)),
  //                           shape: MaterialStateProperty.all(RoundedRectangleBorder(
  //                             side: BorderSide(color: Colors.grey),
  //                             borderRadius: BorderRadius.circular(10.0),
  //                           )),
  //                         ),
  //                         onPressed: () {
  //                           if (languageId == null) {
  //                             setState(() {
  //                               isLangSelected = false;
  //                             });
  //                           } else {
  //                           navigateToSpeechReco(
  //                                   context, languageId!);
  //                              }
  //                         },
  //                         child:
  //                         Text("OK ", style: TextStyle(fontSize: 14)),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //         }),
  //   );
  // }

  void navigateToSpeechReco(context, String language) {
    String? languageLevel = languageToLevel[language]?.toLowerCase();
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
