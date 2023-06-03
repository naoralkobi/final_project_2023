import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:final_project_2023/screen_size_config.dart';
import 'package:final_project_2023/Pages/add_question.dart';
import '../FireBase/question.dart';
import '../consts.dart';

class TranslateTheWord extends StatefulWidget {
  final String? language;
  final String? level;
  final String? languageLevel;
  TranslateTheWord(this.language, this.level, this.languageLevel);

  @override
  State<StatefulWidget> createState() => TranslateTheWordState();
}

class TranslateTheWordState extends State<TranslateTheWord> {
  final bodyController = TextEditingController();
  final answer1Controller = TextEditingController();
  final answer2Controller = TextEditingController();
  final answer3Controller = TextEditingController();
  final answer4Controller = TextEditingController();
  bool isFieldsFilled = true;

  Question question = new Question();

  Widget _appBarTitle = Text(
    "Translate the Word",
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
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
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
            Text("The word in " + _getLanguage() + ":", style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 4.8, fontWeight: FontWeight.w500)),
            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
            ),
            Container(
              width: SizeConfig.blockSizeHorizontal * 75,
              height: SizeConfig.blockSizeVertical * 6,
              child: TextFormField(
                controller: bodyController,
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
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
            ),

            Text("The correct English translation:", style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 4.8, fontWeight: FontWeight.w500)),
            /*Text("(select the correct one)", style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500)),*/
            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
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
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
            ),
            Text("Incorrect translations:", style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 4.8, fontWeight: FontWeight.w500)),
            /*Text("(select the correct one)", style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500)),*/
            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
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

            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
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
            Padding(
              padding:
              EdgeInsets.only(top: SizeConfig.blockSizeVertical * 7),
            ),
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
                      if (bodyController.text == "" || answer1Controller.text == "" || answer2Controller.text == "" ||
                          answer3Controller.text == "" || answer4Controller.text == "") {
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
                            builder: (BuildContext context) => StatefulBuilder(
                              builder: (context, setStateDialog){
                                return AlertDialog(
                                  title: const Text('Add a Question', textAlign: TextAlign.center),
                                  content: const Text('Are you sure you would like to submit the question?', textAlign: TextAlign.center),
                                  elevation: 24.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  actions: <Widget>[
                                    isLoading? SizedBox() : TextButton(
                                      onPressed: () => Navigator.pop(context, 'No'),
                                      child: const Text('No', style: TextStyle(color: PURPLE_COLOR, fontSize: 18.0,)),
                                    ),
                                    //SizedBox(width: SizeConfig.blockSizeHorizontal * 8.0),
                                    isLoading? CircularProgressIndicator() : TextButton(
                                      onPressed: () {
                                        setStateDialog((){
                                          isLoading = true;
                                        });
                                        question.type = "Translate the word";
                                        question.questionBody = bodyController.text;
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
                                    //SizedBox(width: SizeConfig.blockSizeHorizontal * 15.0),
                                  ],
                                );
                              },
                            ));
                      }}
                ),
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

  void _updateFirebase() {
    FirebaseFirestore.instance
        .collection('questions')
        .doc(widget.languageLevel)
        .update({"questions" : FieldValue.arrayUnion([question.toJson()])});
  }

  String _getLanguage(){
    return widget.language == null ? "" : widget.language.toString();
  }

  String _getLevel(){
    return widget.level == null ? "" : widget.level.toString();
  }

  void navigateToAddQuestion(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddQuestion()));
  }

  void _addScore (){
    showDialog<String>(
        context: context,
        barrierDismissible: false,

        builder: (BuildContext context) {
          var user = FirebaseAuth.instance.currentUser;
          FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .update({"score": FieldValue.increment(1)});
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
              SizedBox(width: SizeConfig.blockSizeHorizontal * 60.0),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'Close');
                  Navigator.pop(context);
                },
                child: const Text('Close', style: TextStyle(color: PURPLE_COLOR, fontSize: 18.0,)),
              ),

              /*SizedBox(width: SizeConfig.blockSizeHorizontal * 7.0),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'Finish');
                  navigateToHomePage(context);
                },
                child: const Text('Close', style: TextStyle(color: PURPLE_COLOR, fontSize: 16.0)),
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 1.0),*/
            ],
          );}
    );
  }
}


