import 'package:final_project_2023/Pages/home_page.dart';
import 'package:final_project_2023/Pages/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'forget_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {


  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();


  Future<UserCredential?> signInWithGoogle() async {
    // Create an instance of the firebase auth and google sign in
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    //Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    //Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
    await googleUser!.authentication;
    //Create a new credentials
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    //Sign in the user with the credentials
    final UserCredential userCredential =  await auth.signInWithCredential(credential);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _header(context),
                      _inputField(context),
                      _forgotPassword(context),
                      _signup(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  _header(context) {
    return Column(
      children: [
        Image.asset(
          "assets/app_logo.png",
        ),
        const SizedBox(height: 10),
        const Text("Enter your credential to login"),
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
                  borderSide: BorderSide.none),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.person)),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _passwordTextController,
          decoration: InputDecoration(
            hintText: "Enter Password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        ///This version of code supports email verify:
        ElevatedButton(
          onPressed: () async {
            try {
              UserCredential userCredential = await FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                  email: _emailTextController.text,
                  password: _passwordTextController.text
              );
              // check email is not verified.
              if (!userCredential.user!.emailVerified) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Email not verified'),
                      content: const Text('Please verify your email address.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                // After successful login and email verification, navigate to the home page
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyHomePage()));
              }
            } on FirebaseAuthException catch (e) {
              if (e.code == 'user-not-found') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('User not found'),
                      content: const Text('User does not exist.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            "Login",
            style: TextStyle(fontSize: 20),
          ),
        ),
        /// end of email verify version
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () async {
            await signInWithGoogle();
            if (mounted) {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => MyHomePage(),),);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Login with '),
              ),
              Image.asset(
                'fonts/google-logo.png',
                height: 24.0,
              )
            ],
          ),
        )
      ],
    );
  }

  _forgotPassword(context) {
    return TextButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ForgetPasswordPage()));
      },
      child: const Text("Forgot password?"),
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
                  onPressed: () {
                    // Navigate to the sign-up page when the user taps on the "Sign Up" link
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()));
                  },
            child: const Text("Sign Up"))
      ],
    );
  }
}
