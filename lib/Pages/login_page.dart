import 'package:final_project_2023/Pages/home_page.dart';
import 'package:final_project_2023/Pages/register_page.dart';
import 'package:final_project_2023/Pages/speech_recognition.dart';
import 'package:final_project_2023/Widgets/reusable_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/utils/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    // Scaffold widget provides the basic material design layout structure for the app
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              //use that "hexStringToColor" utils function to make a blend colors.
              hexStringToColor("0077be"),
              hexStringToColor("00bfff"),
              hexStringToColor("40e0d0")
            ], begin: Alignment.topCenter,end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
              child: Column(
                  children: <Widget>[
                    // Text widget to display the "Login" text
                    Text("Login"),
                    SizedBox(
                        height:30
                    ),
                    // reusableTextField is a custom widget for text input fields
                    // we will use them to keep the data for username and password.
                    reusableTextField("Enter UserName",Icons.person_outline,false,
                        _emailTextController),
                    SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Password", Icons.lock_outline, true,
                        _passwordTextController),
                    SizedBox(
                      height: 20,
                    ),
                    // signInSignUpButton is a custom widget for sign-in and sign-up buttons
                    signInSignUpButton(context, true, () {
                      // FirebaseAuth.instance is used for user authentication
                      FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text).then((value) {
                        // After successful login, navigate to the home page
                        Navigator.push(context,
                            //MaterialPageRoute(builder: (context) => MyHomePage()));
                            MaterialPageRoute(builder: (context) => SpeechRecognitionScreen()));
                      });
                    }),
                    signUpOption()
                  ]
              ),
            )
        ),
      ),
    );
  }

  // signUpOption is a custom widget for the "Don't have account?" text and sign-up link
  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account? ",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            // Navigate to the sign-up page when the user taps on the "Sign Up" link
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpPage()));
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
