import 'package:final_project_2023/Pages/home_page.dart';
import 'package:final_project_2023/Pages/login_page.dart';
import 'package:final_project_2023/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Widgets/reusable_widget.dart';
import 'createProfilePage.dart';
import 'email_varify.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _confirmPasswordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          margin: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _header(context),
              _inputField(context),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }

  _header(context) {
    return Column(
      children: [
        Text(
          "Welcome",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter your credentials to sign up"),
      ],
    );
  }

  _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailTextController,
          decoration: InputDecoration(
              hintText: "Enter Email address",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none
              ),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              prefixIcon: Icon(Icons.person)
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _passwordTextController,
          decoration: InputDecoration(
            hintText: "Enter Password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none
            ),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
        SizedBox(height: 10),
        TextField(
          controller: _confirmPasswordTextController,
          decoration: InputDecoration(
            hintText: "Confirm Password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none
            ),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
        SizedBox(height: 10),
        // ElevatedButton(
        //   onPressed: () {
        //     String password = _passwordTextController.text;
        //     String confirmPassword = _confirmPasswordTextController.text;
        //
        //     if (password != confirmPassword) {
        //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords do not match")));
        //     } else if (password.length < 4) {
        //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password must contain at least 4 characters")));
        //     } else {
        //       FirebaseAuth.instance
        //           .createUserWithEmailAndPassword(
        //         email: _emailTextController.text,
        //         password: _passwordTextController.text,
        //       )
        //           .then((value) {
        //         // Navigate to the CreateProfilePage upon successful sign up
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => CreateProfilePage({}),
        //           ),
        //         );
        //       }).onError((error, stackTrace) {
        //         // Print and handle any errors that occur during the sign-up process
        //         print("Error ${error.toString()}");
        //       });
        //     }
        //   },
        //   child: Text(
        //     "Register",
        //     style: TextStyle(fontSize: 20),
        //   ),
        //   style: ElevatedButton.styleFrom(
        //     shape: StadiumBorder(),
        //     padding: EdgeInsets.symmetric(vertical: 16),
        //   ),
        // )
        /// this version is with email verifaction:
        ElevatedButton(
          onPressed: () async {
            String password = _passwordTextController.text;
            String confirmPassword = _confirmPasswordTextController.text;

            if (password != confirmPassword) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Error"),
                  content: Text("Passwords do not match"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'OK'),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else if (password.length < 4) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Error"),
                  content: Text("Password must contain at least 4 characters"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'OK'),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else {
              try {
                UserCredential userCredential = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                  email: _emailTextController.text,
                  password: _passwordTextController.text,
                );

                User? user = FirebaseAuth.instance.currentUser;

                if (user != null && !user.emailVerified) {
                  await user.sendEmailVerification();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmailVerificationPage(),
                    ),
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Error"),
                      content: Text("The password provided is too weak."),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else if (e.code == 'email-already-in-use') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Error"),
                      content: Text("The account already exists for that email."),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                print(e);
              }
            }
          },
          child: Text(
            "Register",
            style: TextStyle(fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        )

      /// end of email verify version:
      ],
    );
  }


  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account? "),
        TextButton(
            onPressed: () {
              // Navigate to the sign-up page when the user taps on the "Sign Up" link
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text("Sign In"))
      ],
    );
  }



  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     extendBodyBehindAppBar: true,
  //     appBar: AppBar(
  //       backgroundColor: Colors.transparent,
  //       elevation: 0,
  //       title: const Text(
  //         "Sign Up",
  //         style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //       ),
  //     ),
  //     body: Container(
  //       width: MediaQuery.of(context).size.width,
  //       height: MediaQuery.of(context).size.height,
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [
  //             hexStringToColor("0077be"),
  //             hexStringToColor("00bfff"),
  //             hexStringToColor("40e0d0")
  //           ],
  //           begin: Alignment.topCenter,
  //           end: Alignment.bottomCenter,
  //         ),
  //       ),
  //       child: SingleChildScrollView(
  //         child: Padding(
  //           padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
  //           child: Column(
  //             children: <Widget>[
  //               const SizedBox(
  //                 height: 30,
  //               ),
  //               // Reusable text field for username input
  //               reusableTextField(
  //                 "Enter Username",
  //                 Icons.person_outline,
  //                 false,
  //                 _userNameTextController,
  //               ),
  //               SizedBox(
  //                 height: 20,
  //               ),
  //               // Reusable text field for email input
  //               reusableTextField(
  //                 "Enter Email",
  //                 Icons.person_outline,
  //                 false,
  //                 _emailTextController,
  //               ),
  //               SizedBox(
  //                 height: 20,
  //               ),
  //               // Reusable text field for password input
  //               reusableTextField(
  //                 "Enter Password",
  //                 Icons.lock_outline,
  //                 true,
  //                 _passwordTextController,
  //               ),
  //               SizedBox(
  //                 height: 20,
  //               ),
  //               // Sign Up button
  //               signInSignUpButton(context, false, () {
  //                 // Todo - perform validations on input fields!
  //
  //                 // Create a user with the provided email and password using FirebaseAuth
  //                 FirebaseAuth.instance
  //                     .createUserWithEmailAndPassword(
  //                   email: _emailTextController.text,
  //                   password: _passwordTextController.text,
  //                 )
  //                     .then((value) {
  //                   // Navigate to the CreateProfilePage upon successful sign up
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => CreateProfilePage({}),
  //                     ),
  //                   );
  //                 }).onError((error, stackTrace) {
  //                   // Print and handle any errors that occur during the sign-up process
  //                   print("Error ${error.toString()}");
  //                 });
  //               }),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
