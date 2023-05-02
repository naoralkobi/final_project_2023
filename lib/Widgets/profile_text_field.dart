import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/screen_size_config.dart';
import 'package:final_project_2023/firebase/auth_repository.dart';

/// This file contains the ProfileTextField widget, which is a custom text field used for profile information.
/// It allows the user to enter and update various profile fields, such as username and description.
/// The widget communicates with Firestore to update the user's profile information.

/// Custom text field widget used for profile information.
class ProfileTextField extends StatefulWidget {
  String hintText;
  final textController;
  StreamController<String> firebaseController;
  bool isUnique;
  Map? userInfo;

  ProfileTextField(this.hintText, this.textController, this.firebaseController,
      this.isUnique, this.userInfo);

  @override
  _ProfileTextFieldState createState() => _ProfileTextFieldState();
}

class _ProfileTextFieldState extends State<ProfileTextField> {
  bool firstClick = true;
  bool isUserNameUnique = true;

  @override
  Widget build(BuildContext context) {
    checkUserNameUnique(widget.textController.text); // Check if the username is unique
    return StreamBuilder(
        stream: widget.firebaseController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == "finish") {
            updateFirebase();
          }
          if (widget.userInfo!.isNotEmpty && firstClick) {
            widget.textController.text = widget.userInfo![widget.hintText];
            firstClick = false;
          }
          return TextFormField(
            maxLines: widget.hintText == "description" ? 15 : 1,
            minLines: widget.hintText == "description" ? 6 : 1,
            controller: widget.textController,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return 'Text is empty';
              } else if (widget.hintText == "username" && text.length > 10) {
                return "Username can't be longer than 10 characters";
              } else if (widget.hintText == "username" && !isUserNameUnique) {
                return "This username is taken";
              }
              return null;
            },
            decoration: InputDecoration(
              errorMaxLines: 2,
              alignLabelWithHint: true,
              filled: true,
              fillColor: Colors.white,
              labelText: widget.hintText,
              labelStyle: TextStyle(color: Colors.grey),
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
              hintText: widget.hintText == "description" ? "Tell us about yourself" : null,
            ),
          );
        });
  }

  /// Updates the corresponding field in Firestore for the current user.
  void updateFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({widget.hintText: widget.textController.text});

    if (widget.hintText == "username") {
      widget.firebaseController.add("done"); // Notify completion for the username field update
    }
  }

  /// Checks if the given username is unique.
  Future<void> checkUserNameUnique(String userName) async {
    setState(() {
      isUserNameUnique = true;
    });
    // Retrieve the collection of users from Firestore
    await FirebaseFirestore.instance.collection("users").get().then((value) {
      value.docs.forEach((element) {
        if (element.data()["username"] == userName) {
          setState(() {
            isUserNameUnique = false;
          });
        }
      });
    });
  }
}
