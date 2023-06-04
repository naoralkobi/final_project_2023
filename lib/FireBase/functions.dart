import 'package:cloud_firestore/cloud_firestore.dart';

import '../consts.dart';

Future<void> addUser(String name, String email, String password) {
  return FirebaseFirestore.instance.collection(USERS).add({
    'name': name,
    EMAIL: email,
    'password': password,
  })
      .then((value) => print("User added"))
      .catchError((error) => print("Failed to add user: $error"));
}
