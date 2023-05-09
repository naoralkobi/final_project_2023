import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_2023/Pages/speech_recognition.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/screen_size_config.dart';
import '../FireBase/auth_repository.dart';

class ChooseLanguageSpeech extends StatefulWidget {

  StreamController<List<double>>? blurController;

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
          });
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentUserID = AuthRepository.instance().user!.uid;
    SizeConfig().init(context);
    return new Dialog(
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(18.0)),
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserID)
              .snapshots(),
          builder: (BuildContext buildContext,
              AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) return Text("There has been an error");
            //if connecting show progressIndicator
            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.data == null) return SizedBox();
            else
              return Container(
                height: SizeConfig.blockSizeVertical * 30,
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Choose a Language", style: TextStyle(fontSize: 18)),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 3,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Color(0xFFDFDFDF),
                          border: Border.all(color: Colors.grey)),
                      child: DropdownButton<String>(
                          hint: Text("Language"),
                          underline: SizedBox.shrink(),
                          value: languageId,
                          items: languagesList.map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            setState(() {
                              isLangSelected = true;
                              languageId = newVal!;
                            });
                          }),
                    ),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: isLangSelected
                          ? Text(" ")
                          : Text(
                        "You must pick a preferred language",
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 2,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: SizeConfig.blockSizeHorizontal * 4),
                      child: isLoadingChat
                          ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFB9D9EB)))
                          : Padding(
                        padding: EdgeInsets.only(
                            left: SizeConfig.blockSizeHorizontal * 4),
                        child: TextButton(
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(65, 36)),
                            backgroundColor: MaterialStateProperty.all(Color(0xFFB9D9EB)),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                          ),
                          onPressed: () {
                            if (languageId == null) {
                              setState(() {
                                isLangSelected = false;
                              });
                            } else {
                            navigateToSpeechReco(
                                    context, languageId!);
                               }
                          },
                          child:
                          Text("OK ", style: TextStyle(fontSize: 14)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
          }),
    );
  }

  void navigateToSpeechReco(context, String language) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SpeechRecognitionScreen(
              selectedLanguage: language,
            )));
  }
}
