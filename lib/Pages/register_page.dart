
import 'package:final_project_2023/Pages/home_page.dart';
import 'package:final_project_2023/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Widgets/reusable_widget.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height:  MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            hexStringToColor("0077be"),
            hexStringToColor("00bfff"),
            hexStringToColor("40e0d0")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: SingleChildScrollView(
            child: Padding(
            padding: EdgeInsets.fromLTRB(20,120, 20, 0),
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height:30
                   ),
                  reusableTextField("Enter Username",Icons.person_outline,false,
                    _userNameTextController),
                  SizedBox(
                      height: 20,
                  ),
                  reusableTextField("Enter Email",Icons.person_outline,false,
                  _emailTextController),
                  SizedBox(
                  height: 20,
                  ),
                reusableTextField("Enter Password", Icons.lock_outline, true,
                  _passwordTextController),
                  SizedBox(
                    height: 20,
                  ),
                  signInSignUpButton(context, false, () {
                    //todo - validations!
                    FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: _emailTextController.text,
                        password: _passwordTextController.text).then((value) {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => MyHomePage()));
                    }).onError((error, stackTrace) { print("Error ${error.toString()}");});
                  })
                ],
      ),
    ))),
    );
  }
}