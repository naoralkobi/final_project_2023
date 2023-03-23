import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/screen_size_config.dart';
import 'package:final_project_2023/firebase/auth_repository.dart';

import '../ProfileVars.dart';

class LanguageWidget extends StatefulWidget {
  String languageName;
  StreamController<String> firebaseController;
  Map? userInfo;

  LanguageWidget(this.languageName, this.firebaseController, this.userInfo);

  @override
  _LanguageWidgetState createState() => _LanguageWidgetState();
}

class _LanguageWidgetState extends State<LanguageWidget> {
  bool isChecked = false;
  String languageLvl = 'temp';
  bool firstClick = true;

  @override
  Widget build(BuildContext context) {
    ProfileVars();
    SizeConfig().init(context);
    return StreamBuilder(
        stream: widget.firebaseController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == "finish") {
            updateFirebase();
          }
          if (widget.userInfo!.isNotEmpty &&
              widget.userInfo!["Languages"][widget.languageName] != null &&
              firstClick) {
            isChecked = true;
            languageLvl = widget.userInfo!["Languages"][widget.languageName];
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
                //  <-- leading Checkbox
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
                      if (languageLvl != "temp"){
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
                      ? <String>['Beginner', 'Intermediate', 'Advanced']
                      .map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value.toString()),
                    );
                  }).toList()
                      : null,
                  onChanged: (newVal) {
                    setState(() {
                      if (languageLvl == "temp"){
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

  void updateFirebase() {
    final user = FirebaseAuth.instance.currentUser;
    if (isChecked) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'Languages.' + widget.languageName: languageLvl});
    }
  }
}
