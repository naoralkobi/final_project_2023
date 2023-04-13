import 'package:final_project_2023/Pages/translate_the_word.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_2023/firebase/FirebaseDB.dart';
import 'package:final_project_2023/firebase/auth_repository.dart';
import 'package:final_project_2023/consts.dart';
import '../screen_size_config.dart';

class AddQuestion extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddQuestionState();
}

class AddQuestionState extends State<AddQuestion> {
  bool isLangSelected = true;
  bool isLevelSelected = true;
  String? languageId;
  String? levelId;
  List<String> languagesList = [
    "Arabic",
    "French",
    "German",
    "Hebrew",
    "Italian",
    "Portuguese",
    "Spanish"
  ];
  List<String> levelList = ["Beginner", "Intermediate", "Advanced"];

  Widget _appBarTitle = Text(
    "Add a Question",
    style: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFF8F5F5),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(18.0),
            ),
          ),
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Container(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 2,
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                      iconSize: SizeConfig.blockSizeHorizontal * 8,
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _appBarTitle,
                        SizedBox(
                          height: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 6),
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: SizeConfig.blockSizeVertical * 3),
            ),
            Container(
              width: SizeConfig.blockSizeHorizontal * 45,
              child: Text(
                "Select a language:",
                style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal*4.5, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              width: SizeConfig.blockSizeHorizontal * 43,
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey)),
              child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Language",
                      style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal*4, fontWeight: FontWeight.w500)),
                  underline: SizedBox.shrink(),
                  value: languageId,
                  items: languagesList.map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value,
                          style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal*4, fontWeight: FontWeight.w500)),
                    );
                  }).toList(),
                  onChanged: (newVal) {
                    setState(() {
                      isLangSelected = true;
                      languageId = newVal!;
                    });
                  }),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: SizeConfig.blockSizeVertical * 3),
            ),
            Container(
              width: SizeConfig.blockSizeHorizontal * 45,
              child: Text(
                "Select a level:",
                style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal*4.5, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              width: SizeConfig.blockSizeHorizontal * 43,
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey)),
              child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Level",
                      style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal*4, fontWeight: FontWeight.w500)),
                  underline: SizedBox.shrink(),
                  value: levelId,
                  items: levelList.map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value,
                          style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal*4, fontWeight: FontWeight.w500)),
                    );
                  }).toList(),
                  onChanged: (newVal) {
                    setState(() {
                      isLevelSelected = true;
                      levelId = newVal!;
                    });
                  }),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: SizeConfig.blockSizeVertical * 3),
            ),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: isLangSelected
                  ? (isLevelSelected
                  ? Text(" ", style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal*4))
                  : (Text(
                "You must select a level",
                style:
                TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 4, color: Colors.red[800]),
              )))
                  : Text(
                "You must select a language",
                style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 4, color: Colors.red[800]),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: SizeConfig.blockSizeVertical * 3),
            ),
            Text(
              "Select a type of question:",
              style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal*4.5, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 5),
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: SizeConfig.blockSizeVertical * 3),
            ),
            Container(
              height: SizeConfig.blockSizeHorizontal * 40,
              width: SizeConfig.blockSizeHorizontal * 40,
              child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(color: Colors.grey))),
                    backgroundColor:
                    MaterialStateProperty.all(Color(0xFFB9D9EB)),
                  ),
                  onPressed: () {
                    if (languageId == null) {
                      setState(() {
                        isLangSelected = false;
                      });
                    } else {
                      if (levelId == null) {
                        setState(() {
                          isLevelSelected = false;
                        });
                      } else {
                        navigateToTranslateTheWord(context);
                      }
                    }
                  },
                  child: Text('Translate the word',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal*5, color: Colors.black))),
            ),
            Padding(
              padding: EdgeInsets.only(left: SizeConfig.blockSizeVertical * 4),
            ),
            Container(
              height: SizeConfig.blockSizeHorizontal * 40,
              width: SizeConfig.blockSizeHorizontal * 40,
              child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(color: Colors.grey))),
                    backgroundColor:
                    MaterialStateProperty.all(Color(0xFFB9D9EB)),
                  ),
                  onPressed: () {
                    if (languageId == null) {
                      setState(() {
                        isLangSelected = false;
                      });
                    } else {
                      if (levelId == null) {
                        setState(() {
                          isLevelSelected = false;
                        });
                      } else {
                        navigateToWhatsInThePicture(context);
                      }
                    }
                  },
                  child: Text('What’s in the picture',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal*5, color: Colors.black))),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: SizeConfig.blockSizeVertical * 3),
            ),
            Container(
              height: SizeConfig.blockSizeHorizontal * 40,
              width: SizeConfig.blockSizeHorizontal * 40,
              child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(color: Colors.grey))),
                    backgroundColor:
                    MaterialStateProperty.all(Color(0xFFB9D9EB)),
                  ),
                  onPressed: () {
                    if (languageId == null) {
                      setState(() {
                        isLangSelected = false;
                      });
                    } else {
                      if (levelId == null) {
                        setState(() {
                          isLevelSelected = false;
                        });
                      } else {
                        navigateToCompleteTheSentence(context);
                      }
                    }
                  },
                  child: Text('Complete the sentence',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal*5, color: Colors.black))),
            ),
            Padding(
              padding: EdgeInsets.only(left: SizeConfig.blockSizeVertical * 4),
            ),
            Container(
              height: SizeConfig.blockSizeHorizontal * 40,
              width: SizeConfig.blockSizeHorizontal * 40,
              child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(color: Colors.grey))),
                    backgroundColor:
                    MaterialStateProperty.all(Color(0xFFB9D9EB)),
                  ),
                  onPressed: () {
                    if (languageId == null) {
                      setState(() {
                        isLangSelected = false;
                      });
                    } else {
                      if (levelId == null) {
                        setState(() {
                          isLevelSelected = false;
                        });
                      } else {
                        navigateToVerbConjugation(context);
                      }
                    }
                  },
                  child: Text('Verb conjugation',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal*5, color: Colors.black))),
            ),
          ],
        ),
      ]),
    );
  }

  void navigateToTranslateTheWord(context) {
    String? languageLevel = _getLanguageLevel();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TranslateTheWord(languageId, levelId, languageLevel)));
  }

  void navigateToWhatsInThePicture(context) {
  }

  void navigateToCompleteTheSentence(context) {
  }

  void navigateToVerbConjugation(context) {
  }

  String? _getLanguageLevel() {
    return languageId! + "-" + levelId!.toLowerCase();
  }
}
