import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_project_2023/Pages/createProfilePage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'login_page.dart'; // Required for the envelope icon

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _header(context),
                _message(context),
                _verifyButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

_header(context) {
    return Column(
      children: const [
        Text(
          "Email Verification",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          "A verification email has been sent to your email address",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 50),
        FaIcon(
          FontAwesomeIcons.envelopeOpenText,
          size: 100,
          color: Colors.grey,
        ),
        SizedBox(height: 50),
      ],
    );
  }

  _message(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Text(
          "Please check your email and follow the instructions to verify your account. After you've verified your email, press the button below to continue.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  _verifyButton(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () async {
            User? user = FirebaseAuth.instance.currentUser;

            await user?.reload();
            if (user != null && user.emailVerified) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateProfilePage(const {}),
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Verification Error"),
                    content: const Text("Email not verified"),
                    actions: [
                      TextButton(
                        child: const Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            "Verify Email",
            style: TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () async {
            User? user = FirebaseAuth.instance.currentUser;
            user?.sendEmailVerification(); // resend verification email
          },
          child: const Text("Resend Email Link"),
        ),
        TextButton(
          onPressed: () {
            // Redirect to login screen
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
          },
          child: const Text("Back to login"),
        )
      ],
    );
  }

}
