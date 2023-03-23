import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileDatePicker extends StatefulWidget {
  StreamController<String> firebaseController;
  Map? userInfo;

  ProfileDatePicker(this.firebaseController, this.userInfo);

  @override
  _ProfileDatePickerState createState() => _ProfileDatePickerState();
}

class _ProfileDatePickerState extends State<ProfileDatePicker> {
  DateTime currentDate = DateTime.now();
  final dateController = TextEditingController();
  bool firstClick = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.firebaseController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == "finish") {
            updateFirebase();
          }
          if (widget.userInfo!.isNotEmpty && firstClick) {
            dateController.text = widget.userInfo!["birthDate"];
            firstClick = false;
          }
          return TextFormField(
            readOnly: true,
            showCursor: true,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return 'Text is empty';
              }
              return null;
            },
            controller: dateController,
            onTap: () => {
              _selectDate(context),
            },
            decoration: InputDecoration(
              filled: true,
              labelText: "birth date",
              labelStyle: TextStyle(color: Colors.grey),
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(10.0),
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
              hintText: 'Date of birth',
            ),
          );
        });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime pickedDate = (await showDatePicker(
        context: context,
        initialDate:
        DateTime(currentDate.year - 14, currentDate.month, currentDate.day),
        firstDate:
        DateTime(currentDate.year - 99, currentDate.month, currentDate.day),
        lastDate:
        DateTime(currentDate.year - 14, currentDate.month, currentDate.day),
        builder: (BuildContext context, Widget? child) {
          return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: Color(0xFFA66CB7),
                ),
              ),
              child: child == null ? SizedBox() : child);
        }))!;
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        // currentDate = pickedDate;
        dateController.text = pickedDate.day.toString() +
            '.' +
            pickedDate.month.toString() +
            '.' +
            pickedDate.year.toString();
      });
  }

  void updateFirebase() {
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({"birthDate": dateController.text});
  }
}
