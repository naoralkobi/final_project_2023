import 'package:final_project_2023/Pages/home_page.dart';
import 'package:final_project_2023/Pages/register_page.dart';
import 'package:final_project_2023/Pages/select_lang_screen.dart';
import 'package:final_project_2023/Pages/speech_recognition.dart';
import 'package:final_project_2023/Pages/videoLearningPage.dart';
import 'package:final_project_2023/Widgets/reusable_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/utils/colors.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();


  Future<UserCredential?> signInWithGoogle() async {
    // Create an instance of the firebase auth and google signin
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    //Triger the authentication flow
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
    final UserCredential userCredential =
    await auth.signInWithCredential(credential);
    return null;
  }

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
              _forgotPassword(context),
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
          "Welcome Back",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter your credential to login"),
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
              prefixIcon: Icon(Icons.person)),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _passwordTextController,
          decoration: InputDecoration(
            hintText: "Enter Password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            FirebaseAuth.instance.signInWithEmailAndPassword(
                email: _emailTextController.text,
                password: _passwordTextController.text).then((value) {
              // After successful login, navigate to the home page
              Navigator.push(context,
                  //MaterialPageRoute(builder: (context) => YouTubeVideoListPage(searchQuery: 'learning arabic for beginners')));
                  MaterialPageRoute(builder: (context) => MyHomePage()));
              //MaterialPageRoute(builder: (context) => ChooseLanguageSpeech()));
            });
          },
          child: Text(
            "Login",
            style: TextStyle(fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            padding: EdgeInsets.symmetric(vertical: 16),
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
              Padding(
                padding: const EdgeInsets.only(left: 10),
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
            MaterialPageRoute(builder: (context) => ForgetPasswordPage()));
      },
      child: Text("Forgot password?"),
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Dont have an account? "),
        TextButton(
                  onPressed: () {
                    // Navigate to the sign-up page when the user taps on the "Sign Up" link
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUpPage()));
                  },
            child: Text("Sign Up"))
      ],
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   // Scaffold widget provides the basic material design layout structure for the app
  //   return Scaffold(
  //     body: Container(
  //       width: MediaQuery.of(context).size.width,
  //       height: MediaQuery.of(context).size.height,
  //       decoration: BoxDecoration(
  //           gradient: LinearGradient(colors: [
  //             //use that "hexStringToColor" utils function to make a blend colors.
  //             hexStringToColor("0077be"),
  //             hexStringToColor("00bfff"),
  //             hexStringToColor("40e0d0")
  //           ], begin: Alignment.topCenter,end: Alignment.bottomCenter)),
  //       child: SingleChildScrollView(
  //           child: Padding(
  //             padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
  //             child: Column(
  //                 children: <Widget>[
  //                   // Text widget to display the "Login" text
  //                   Text("Login"),
  //                   SizedBox(
  //                       height:30
  //                   ),
  //                   // reusableTextField is a custom widget for text input fields
  //                   // we will use them to keep the data for username and password.
  //                   reusableTextField("Enter UserName",Icons.person_outline,false,
  //                       _emailTextController),
  //                   SizedBox(
  //                     height: 20,
  //                   ),
  //                   reusableTextField("Enter Password", Icons.lock_outline, true,
  //                       _passwordTextController),
  //                   SizedBox(
  //                     height: 20,
  //                   ),
  //                   // signInSignUpButton is a custom widget for sign-in and sign-up buttons
  //                   signInSignUpButton(context, true, () {
  //                     // FirebaseAuth.instance is used for user authentication
  //                     FirebaseAuth.instance.signInWithEmailAndPassword(
  //                         email: _emailTextController.text,
  //                         password: _passwordTextController.text).then((value) {
  //                       // After successful login, navigate to the home page
  //                       Navigator.push(context,
  //                           //MaterialPageRoute(builder: (context) => YouTubeVideoListPage(searchQuery: 'learning arabic for beginners')));
  //                           MaterialPageRoute(builder: (context) => MyHomePage()));
  //                           //MaterialPageRoute(builder: (context) => ChooseLanguageSpeech()));
  //                     });
  //                   }),
  //                   signUpOption()
  //                 ]
  //             ),
  //           )
  //       ),
  //     ),
  //   );
  // }
  //
  // // signUpOption is a custom widget for the "Don't have account?" text and sign-up link
  // Row signUpOption() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       const Text("Don't have account? ",
  //           style: TextStyle(color: Colors.white70)),
  //       GestureDetector(
  //         onTap: () {
  //           // Navigate to the sign-up page when the user taps on the "Sign Up" link
  //           Navigator.push(context,
  //               MaterialPageRoute(builder: (context) => SignUpPage()));
  //         },
  //         child: const Text(
  //           "Sign Up",
  //           style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold),
  //         ),
  //       )
  //     ],
  //   );
  // }
}


class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
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
          "Reset Password",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter your email address to reset password"),
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
              prefixIcon: Icon(Icons.person)),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            FirebaseAuth.instance
                .sendPasswordResetEmail(email: _emailTextController.text)
                .then((value) {
              // After the reset link is sent, navigate back to the login page
              Navigator.pop(context);
            });
          },
          child: Text(
            "Send Reset Link",
            style: TextStyle(fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

}
