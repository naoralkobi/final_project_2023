import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/screen_size_config.dart';
import '../consts.dart';
import '../profile_vars.dart';

/// This is a StatefulWidget that represents a language widget in the profile screen.
class LanguageWidget extends StatefulWidget {
  String languageName;
  StreamController<String> firebaseController; // Stream controller for Firebase events
  Map? userInfo;

  /// Constructs a LanguageWidget instance with the given parameters.
  LanguageWidget(this.languageName, this.firebaseController, this.userInfo);

  @override
  _LanguageWidgetState createState() => _LanguageWidgetState();
}

class _LanguageWidgetState extends State<LanguageWidget> {
  bool isChecked = false; // Indicates whether the checkbox is checked or not
  String languageLvl = 'temp'; // The selected language level
  bool firstClick = true; // Indicates whether it's the first click on the language widget


  @override
  Widget build(BuildContext context) {
    ProfileVars(); // Initialize the profile variables
    SizeConfig().init(context); // Initialize the size configuration
    return StreamBuilder(
        stream: widget.firebaseController.stream,
        builder: (context, snapshot) {
          // Check if the stream has data and the data is 'finish'
          if (snapshot.hasData && snapshot.data == "finish") {
            // Update Firebase if the stream data is 'finish'
            updateFirebase();
          }
          // Check if the user information is not empty and the language exists in the user's languages
          if (widget.userInfo!.isNotEmpty &&
              widget.userInfo![LANGUAGES][widget.languageName] != null &&
              firstClick) {
            isChecked = true;
            languageLvl = widget.userInfo![LANGUAGES][widget.languageName];
            ProfileVars.languageNum++;
            ProfileVars.numOfLvls++;
            firstClick = false;
          }
          return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            SizedBox(
              width: 200,
              child: CheckboxListTile(
                title: Text(widget.languageName,
                    style: TextStyle(
                        color: isChecked ? Colors.black : Colors.grey)),
                controlAffinity: ListTileControlAffinity.leading,
                value: isChecked,
                contentPadding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                activeColor: Color(0xFFA66CB7),
                onChanged: (newValue) {
                  setState(() {
                    isChecked = newValue!;
                    if (isChecked) {
                      ProfileVars.languageNum++;
                    } else {
                      ProfileVars.languageNum--;
                      if (languageLvl != "temp") {
                        ProfileVars.numOfLvls--;
                      }
                    }
                  });
                  languageLvl = "temp";
                },
              ),
            ),
            isChecked
                ? Container(
              height: 35,
              width: 150,
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
                border: Border.all(
                    color: Colors.grey,
                    style: BorderStyle.solid,
                    width: 0.80),
              ),
              child: DropdownButton<String>(
                  hint: Text('Level'),
                  underline: SizedBox.shrink(),
                  value: languageLvl == 'temp' ? null : languageLvl,
                  items: isChecked
                      ? <String>[
                    'Beginner',
                    'Intermediate',
                    'Advanced'
                  ].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value.toString()),
                    );
                  }).toList()
                      : null,
                  onChanged: (newVal) {
                    setState(() {
                      if (languageLvl == "temp") {
                        ProfileVars.numOfLvls++;
                      }
                      languageLvl = newVal!;
                    });
                  }),
            )
                : SizedBox(),
          ]);
        });
  }

  /// Updates the language level in Firebase.
  void updateFirebase() {
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    if (isChecked) {
      // If the checkbox is checked
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid) // Get the document for the current user
          .update({'Languages.' + widget.languageName: languageLvl});
      // Update the language level in the 'Languages' field of the user document
    }
  }
}
