import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: Center(
       child:ElevatedButton(
         child: Text("Log out"),
         onPressed: () {
           FirebaseAuth.instance.signOut().then((value) {
             Navigator.push(context,
                 MaterialPageRoute(builder: (context) => LoginPage()));
           });
         },
       )
     ),
    );
  }
}
