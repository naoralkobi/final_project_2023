import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addUser(String name, String email, String password) {
  return FirebaseFirestore.instance.collection('users').add({
    'name': name,
    'email': email,
    'password': password,
  })
      .then((value) => print("User added"))
      .catchError((error) => print("Failed to add user: $error"));
}
