import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:final_project_2023/Pages/add_question.dart';
import 'package:final_project_2023/screen_size_config.dart';

import '../consts.dart';
import '../firebase/Question.dart';

/// Purpose of the code:
/// This class represents a screen that allows users to add verb conjugation questions.


class VerbConjugation extends StatefulWidget {
  final String? language;
  final String? level;
  final String? languageLevel;
  // Constructor to initialize the VerbConjugation widget
  VerbConjugation(this.language, this.level, this.languageLevel);

  @override
  State<StatefulWidget> createState() => VerbConjugationState();
}

class VerbConjugationState extends State<VerbConjugation> {
  // Controllers for text fields
  final beginningController = TextEditingController();
  final endController = TextEditingController();
  final answer1Controller = TextEditingController();
  final answer2Controller = TextEditingController();
  final answer3Controller = TextEditingController();
  final answer4Controller = TextEditingController();
  bool isFieldsFilled = true;

  Question question = new Question();

  Widget _appBarTitle = Text(
    "Verb Conjugation",
    style: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
        body: Column(
          children: [
            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Text("Language: ",style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 4, color: Colors.black) ),
                    Text(_getLanguage(),style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 4, color: Color(0xFF6D94BE)) ),
                  ],
                ),
                // Display selected level
                Row(
                  children: [
                    Text("Level: ",style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 4, color: Colors.black)),
                    Text(_getLevel(),style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 4, color: Color(0xFF6D94BE))),
                  ],
                ),
              ],
            ),
            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
            ),
            /*Align(
              alignment: Alignment.centerLeft,
              child: Text("     Insert a word in " + _getLanguage() + " and 4 translations " + "\n"+
              "     in English and select the correct translation",
                  style: TextStyle(
                  fontSize: 16)),
            ),
            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
            ),*/
            Text("The beginning of the sentence:", style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 4.8, fontWeight: FontWeight.w500)),
            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
            ),
            Container(
              width: SizeConfig.blockSizeHorizontal * 75,
              height: SizeConfig.blockSizeVertical * 9,
              child: TextFormField(
                maxLines: 5,
                controller: beginningController,
                cursorColor: PURPLE_COLOR,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: PURPLE_COLOR,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
            ),

            Text("The correct verb conjugation:", style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 4.8, fontWeight: FontWeight.w500)),
            /*Text("(select the correct one)", style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500)),*/
            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
            ),
            Row(
              children: [
                SizedBox(
                  width: SizeConfig.blockSizeHorizontal * 12.7,
                ),
                Container(
                  width: SizeConfig.blockSizeHorizontal * 75,
                  height: SizeConfig.blockSizeVertical * 6,
                  child: TextFormField(
                    controller: answer1Controller,
                    cursorColor: PURPLE_COLOR,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: PURPLE_COLOR,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
            ),
            Text("The end of the sentence:", style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 4.8, fontWeight: FontWeight.w500)),
            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
            ),
            Container(
              width: SizeConfig.blockSizeHorizontal * 75,
              height: SizeConfig.blockSizeVertical * 9,
              child: TextFormField(
                maxLines: 5,
                controller: endController,
                cursorColor: PURPLE_COLOR,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: PURPLE_COLOR,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
            ),
            Text("Incorrect conjugations:", style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 4.8, fontWeight: FontWeight.w500)),
            /*Text("(select the correct one)", style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500)),*/
            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
            ),
            Row(
              children: [
                Padding(
                    padding:
                    EdgeInsets.only(left: SizeConfig.blockSizeVertical * 3)),
                Text("1.", style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 5.5, fontWeight: FontWeight.w500)),
                Padding(
                    padding:
                    EdgeInsets.only(left: SizeConfig.blockSizeVertical * 1)),
                Container(
                  width: SizeConfig.blockSizeHorizontal * 75,
                  height: SizeConfig.blockSizeVertical * 6,
                  child: TextFormField(
                    controller: answer2Controller,
                    cursorColor: PURPLE_COLOR,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: PURPLE_COLOR,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
            ),
            Row(
              children: [
                Padding(
                    padding:
                    EdgeInsets.only(left: SizeConfig.blockSizeVertical * 3)),
                Text("2.", style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 5.5, fontWeight: FontWeight.w500)),
                Padding(
                    padding:
                    EdgeInsets.only(left: SizeConfig.blockSizeVertical * 1)),
                Container(
                  width: SizeConfig.blockSizeHorizontal * 75,
                  height: SizeConfig.blockSizeVertical * 6,
                  child: TextFormField(
                    controller: answer3Controller,
                    cursorColor: PURPLE_COLOR,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: PURPLE_COLOR,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
            ),
            Row(
              children: [
                Padding(
                    padding:
                    EdgeInsets.only(left: SizeConfig.blockSizeVertical * 3)),
                Text("3.", style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 5.5, fontWeight: FontWeight.w500)),
                Padding(
                    padding:
                    EdgeInsets.only(left: SizeConfig.blockSizeVertical * 1)),
                Container(
                  width: SizeConfig.blockSizeHorizontal * 75,
                  height: SizeConfig.blockSizeVertical * 6,
                  child: TextFormField(
                    controller: answer4Controller,
                    cursorColor: PURPLE_COLOR,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: PURPLE_COLOR,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /* Padding(
                padding:
                EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
              ),
              Text("The correct translation:", style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w500)),
              Padding(
                padding:
                EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
              ),
              Row(
              children: <Widget>[
                // SizedBox(
                //   width: 30,
                // ),
                Radio<String>(
                  value: '1',
                  activeColor: PURPLE_COLOR,
                  groupValue: correctAnswer,
                  onChanged: (String? value) {
                    setState(() {
                      correctAnswer = value!;
                    });
                  },
                ),
                Text("1       "),
                Radio<String>(
                  value: '2',
                  activeColor: PURPLE_COLOR,
                  groupValue: correctAnswer,
                  onChanged: (String? value) {
                    setState(() {
                      correctAnswer = value!;
                    });
                  },
                ),
                Text("2       "),
                Radio<String>(
                  value: '3',
                  activeColor: PURPLE_COLOR,
                  groupValue: correctAnswer,
                  onChanged: (String? value) {
                    setState(() {
                      correctAnswer = value!;
                    });
                  },
                ),
                Text("3       "),
                Radio<String>(
                  value: '4',
                  activeColor: PURPLE_COLOR,
                  groupValue: correctAnswer,
                  onChanged: (String? value) {
                    setState(() {
                      correctAnswer = value!;
                    });
                  },
                ),
                Text("4       "),
              ],
            ),*/

            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: isFieldsFilled
                    ? Text(" ", style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 4))
                    : Text(
                  "     Fill in all fields",
                  style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 4, color: Colors.red[800]),
                ),
              ),
            ),
            /*Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 7),
            ),*/
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    child: Row(
                      children: [
                        Text("Finish ", style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal * 5.5, fontWeight: FontWeight.w500, color: Colors.grey)),
                        Icon(Icons.arrow_forward_rounded,
                          color: Colors.grey, size: SizeConfig.blockSizeHorizontal * 6,)
                      ],
                    ),
                    onPressed: (){
                      if (beginningController.text == "" || endController.text == "" || answer1Controller.text == "" ||
                          answer2Controller.text == "" || answer3Controller.text == "" || answer4Controller.text == "") {
                        setState(() {
                          isFieldsFilled = false;
                        });
                      } else{
                        setState(() {
                          isFieldsFilled = true;
                        });
                        bool isLoading = false;
                        showDialog<String>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) =>
                                StatefulBuilder(
                                  builder: (context, setStateDialog){
                                    return AlertDialog(
                                      title: const Text('Add a Question', textAlign: TextAlign.center),
                                      content: const Text('Are you sure you would like to submit the question?', textAlign: TextAlign.center),
                                      elevation: 24.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      ),
                                      actions: <Widget>[
                                        isLoading? SizedBox(): TextButton(
                                          onPressed: () => Navigator.pop(context, 'No'),
                                          child: const Text('No', style: TextStyle(color: PURPLE_COLOR, fontSize: 18.0,)),
                                        ),
                                        isLoading? CircularProgressIndicator() : TextButton(
                                          onPressed: () {
                                            setStateDialog((){
                                              isLoading = true;
                                            });
                                            question.type = "Verb conjugation";
                                            question.questionBody = beginningController.text + " _______ " + endController.text;
                                            question.correctAnswer = answer1Controller.text;
                                            question.answers.add(answer1Controller.text);
                                            question.answers.add(answer2Controller.text);
                                            question.answers.add(answer3Controller.text);
                                            question.answers.add(answer4Controller.text);
                                            _updateFirebase();
                                            Navigator.pop(context, 'Yes');
                                            _addScore();
                                          },
                                          child: const Text('Yes', style: TextStyle(color: PURPLE_COLOR, fontSize: 18.0)),
                                        ),
                                      ],
                                    );
                                  },
                                ));

                      }}),
                Padding(
                  padding:
                  EdgeInsets.only(right: SizeConfig.blockSizeHorizontal * 4),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

// This method updates the Firebase collection with the current question data
  void _updateFirebase() {
    // Access the Firestore instance and select the 'questions' collection
    FirebaseFirestore.instance
        .collection('questions')
        .doc(widget.languageLevel) // Use the language level as the document ID
        .update({"questions" : FieldValue.arrayUnion([question.toJson()])});
  }

// This method returns the selected language or an empty string if no language is selected
  String _getLanguage(){
    return widget.language == null ? "" : widget.language.toString();
  }

// This method returns the selected level or an empty string if no level is selected
  String _getLevel(){
    return widget.level == null ? "" : widget.level.toString();
  }

// This method navigates to the AddQuestion screen
  void navigateToAddQuestion(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddQuestion()));
  }

// This method adds a score to the user and displays an AlertDialog
  void _addScore (){
    showDialog<String>(
        context: context,
        barrierDismissible: false,

        builder: (BuildContext context) {
          // Get the current user
          var user = FirebaseAuth.instance.currentUser;

          // Increment the user's score in the Firestore collection
          FirebaseFirestore.instance
              .collection(USERS)
              .doc(user!.uid)
              .update({SCORE: FieldValue.increment(1)});

          return AlertDialog(
            title: const Text('Your question was added', textAlign: TextAlign.center),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('+  ',style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.0), textAlign: TextAlign.center),
                Image.asset(
                  "assets/images/coin.png",
                  width: SizeConfig.blockSizeHorizontal * 9,
                ),
              ],
            ),
            elevation: 24.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            actions: <Widget>[
              // Close button
              SizedBox(width: SizeConfig.blockSizeHorizontal * 60.0),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'Close');
                  Navigator.pop(context);
                },
                child: const Text('Close', style: TextStyle(color: PURPLE_COLOR, fontSize: 18.0,)),
              ),
            ],
          );
        }
    );
  }

}


