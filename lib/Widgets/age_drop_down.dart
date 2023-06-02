import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/firebase/auth_repository.dart';

import '../profile_vars.dart';
import 'package:final_project_2023/screen_size_config.dart';

class AgeDropDown extends StatefulWidget {
  String rangeType; //min or max
  StreamController<String> firebaseController;
  Map? userInfo;

  AgeDropDown(this.rangeType, this.firebaseController, this.userInfo);

  @override
  _AgeDropDownState createState() => _AgeDropDownState();
}

class _AgeDropDownState extends State<AgeDropDown> {
  int ageVal = 1;
  bool firstClick = true;
  @override
  Widget build(BuildContext context) {
    ProfileVars();
    return StreamBuilder(
        stream: widget.firebaseController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == "finish"){
            updateFirebase();
          }
          if (widget.userInfo!.isNotEmpty && firstClick){
            ageVal = widget.userInfo![widget.rangeType];
            firstClick = false;
            if (widget.rangeType == "minAge"){
              ProfileVars.minAge = ageVal;
            } else {
              ProfileVars.maxAge = ageVal;
            }
          }
          return Container(
            height: SizeConfig.blockSizeVertical * 10,
            width: SizeConfig.blockSizeHorizontal * 20,
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white,
              border: Border.all(
                  color: Colors.grey, style: BorderStyle.solid, width: 0.80),
            ),
            child: DropdownButton<int>(
                hint: Text("Pick"),
                underline: SizedBox.shrink(),
                value: ageVal == 1 ? null : ageVal,
                items:
                <int>[for (var i = 14; i < 100; i += 1) i].map((int value) {
                  return new DropdownMenuItem<int>(
                    value: value,
                    child: new Text(value.toString()),
                  );
                }).toList(),
                onChanged: (newVal) {
                  setState(() {
                    ageVal = newVal!;
                    if (widget.rangeType == "minAge"){
                      ProfileVars.minAge = newVal;
                    } else {
                      ProfileVars.maxAge = newVal;
                    }
                  });
                }),
          );
        });
  }

  void updateFirebase(){
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({widget.rangeType: ageVal});
  }
}
