import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../consts.dart';

/// A widget for selecting and updating a user's birth date.
class ProfileDatePicker extends StatefulWidget {
  final StreamController<String> firebaseController; // Controller for managing the stream
  final Map? userInfo; // User information

  /// Constructs a [ProfileDatePicker] widget.
  ///
  /// The [firebaseController] parameter is the stream controller for Firebase updates.
  /// The [userInfo] parameter is the user information (optional).
  ProfileDatePicker(this.firebaseController, this.userInfo);

  @override
  _ProfileDatePickerState createState() => _ProfileDatePickerState();
}

/// The state for the [ProfileDatePicker] widget.
class _ProfileDatePickerState extends State<ProfileDatePicker> {
  DateTime currentDate = DateTime.now(); // The current date
  final dateController = TextEditingController(); // Controller for the text field
  bool firstClick = true; // Indicates if it's the first click on the date field

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
              return EMPTY_TEXT;
            }
            return null;
          },
          controller: dateController,
          onTap: () =>
          {
            _selectDate(context),
          },
          decoration: const InputDecoration(
            filled: true,
            labelText: "birth date",
            labelStyle: TextStyle(color: Colors.grey),
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 2.0,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            hintText: 'Date of birth',
          ),
        );
      },
    );
  }

  /// Displays a date picker dialog and updates the selected date.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime pickedDate = (await showDatePicker(
      context: context,
      initialDate: DateTime(
          currentDate.year - 14, currentDate.month, currentDate.day),
      firstDate:
      DateTime(currentDate.year - 99, currentDate.month, currentDate.day),
      lastDate:
      DateTime(currentDate.year - 14, currentDate.month, currentDate.day),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    ))!;
    // If a date is picked and it is different from the current date
    if (pickedDate != currentDate) {
      setState(() {
        // Update the text in the dateController to display the selected date
        dateController.text = '${pickedDate.day}.${pickedDate.month}.${pickedDate.year}';
      });
    }
  }

  /// Updates the birth date in Firebase for the current user.
  void updateFirebase() {
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    FirebaseFirestore.instance // Access the Firestore instance
        .collection(USERS) // Access the USERS collection
        .doc(user!.uid) // Access the document corresponding to the user's UID
        .update({
      "birthDate": dateController.text
    }); // Update the 'birthDate' field with the value from dateController
  }
}
