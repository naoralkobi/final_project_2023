// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:final_project_2023/Pages/register_page.dart';
// import 'package:final_project_2023/screen_size_config.dart';
// import 'package:final_project_2023/firebase/auth_repository.dart';
//
// class loginPage extends StatefulWidget {
//   @override
//   _loginPageState createState() => _loginPageState();
// }
//
// class _loginPageState extends State<loginPage> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   AuthRepository authRep = AuthRepository.instance();
//
//   final snackBar = SnackBar(
//     content: Text('There was an error logging into the app'),
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     return Scaffold(
//         resizeToAvoidBottomInset: false,
//         body: Column(
//           // mainAxisAlignment: MainAxisAlignment.center,
//           // crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(
//               height: SizeConfig.blockSizeVertical * 10,
//             ),
//             Text("SociaLang",
//                 style: TextStyle(
//                   fontSize: SizeConfig.screenWidth * 0.15,
//                 )),
//             SizedBox(
//               height: SizeConfig.blockSizeVertical * 10,
//             ),
//             Container(
//               margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal_30, 0,
//                   SizeConfig.blockSizeHorizontal_30, 0),
//               decoration: BoxDecoration(
//                 // border: Border.all(
//                 // ),
//                   borderRadius: BorderRadius.all(Radius.circular(20))),
//               // width: 40,
//               // height: 80,
//               child: TextField(
//                 controller: emailController,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: const BorderRadius.all(
//                       const Radius.circular(10.0),
//                     ),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey, width: 2.0),
//                     borderRadius: const BorderRadius.all(
//                       const Radius.circular(10.0),
//                     ),
//                   ),
//                   hintText: 'Email',
//                   prefixIcon: Icon(Icons.mail_outline),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: SizeConfig.blockSizeVertical * 4, //30
//             ),
//             Container(
//               margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal_30, 0,
//                   SizeConfig.blockSizeHorizontal_30, 0),
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.all(Radius.circular(20))),
//               child: TextField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: const BorderRadius.all(
//                       const Radius.circular(10.0),
//                     ),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey, width: 2.0),
//                     borderRadius: const BorderRadius.all(
//                       const Radius.circular(10.0),
//                     ),
//                   ),
//                   hintText: 'Password',
//                   prefixIcon: Icon(Icons.vpn_key),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: SizeConfig.blockSizeVertical * 4,
//             ),
//             Consumer<AuthRepository>(
//               builder: (context, authRep, snapshot) {
//                 if (authRep.status == Status.Authenticating) {
//                   return CircularProgressIndicator(
//                     valueColor:
//                     AlwaysStoppedAnimation<Color>(Color(0xFFA66CB7)),
//                   );
//                 } else {
//                   return ElevatedButton(
//                     onPressed: () async {
//                       await authRep
//                           .signIn(emailController.text, passwordController.text)
//                           .then((value) {
//                         // if (value) {
//                         //   Navigator.of(context).pushReplacement(
//                         //       MaterialPageRoute<void>(
//                         //           builder: (BuildContext context) {
//                         //     print(
//                         //         (authRep.isNewInitialized() && authRep.isNew())
//                         //             .toString());
//                         //     if (authRep.isNewInitialized() && authRep.isNew()) {
//                         //       return CreateProfilePage({});
//                         //     } else {
//                         //       return MyHomePage();
//                         //     }
//                         //     return Scaffold(body: CircularProgressIndicator());
//                         //   }));
//                         // } else {
//                         //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                         // }
//                       });
//                     },
//                     child: Text(
//                       "Log in",
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontFamily: 'Rockwell',
//                           fontSize: SizeConfig.blockSizeHorizontal * 5.5),
//                     ),
//                     style: ButtonStyle(
//                         minimumSize: MaterialStateProperty.all<Size>(Size(
//                             SizeConfig.blockSizeHorizontal * 55,
//                             SizeConfig.blockSizeVertical * 6.5)),
//                         backgroundColor:
//                         MaterialStateProperty.all<Color>(Color(0xFFA66CB7)),
//                         shape:
//                         MaterialStateProperty.all<RoundedRectangleBorder>(
//                             RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                               side: BorderSide(color: Colors.black, width: 0.5),
//                             ))),
//                   );
//                 }
//               },
//             ),
//             SizedBox(
//               height: SizeConfig.blockSizeVertical * 4.5,
//             ),
//             Text(
//               "Don't have an account?",
//               style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 3.5),
//             ),
//             SizedBox(
//               height: SizeConfig.blockSizeVertical * 1.5,
//             ),
//             ElevatedButton(
//               onPressed: () => {
//                 Navigator.of(context).push(
//                     MaterialPageRoute<void>(builder: (BuildContext context) {
//                       return SignUpPage();
//                     }))
//               },
//               child: Text(
//                 "Sign up",
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: SizeConfig.blockSizeHorizontal * 5.5),
//               ),
//               style: ButtonStyle(
//                   minimumSize: MaterialStateProperty.all<Size>(Size(
//                       SizeConfig.blockSizeHorizontal * 55,
//                       SizeConfig.blockSizeVertical * 5.5)),
//                   backgroundColor:
//                   MaterialStateProperty.all<Color>(Color(0xFF6D94BE)),
//                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                         side: BorderSide(color: Colors.black, width: 0.5),
//                       ))),
//             ),
//             SizedBox(
//               height: SizeConfig.blockSizeVertical * 4,
//             ),
//             Row(children: <Widget>[
//               Expanded(child: Divider(
//                 indent: 15,
//                 endIndent: 10,
//                 thickness: 0.8,
//               )),
//               Text("OR", style: TextStyle(color: Colors.grey),),
//               Expanded(child: Divider(
//                 indent: 10,
//                 endIndent: 15,
//                 thickness: 0.8,
//               )),
//             ]),
//             SizedBox(
//               height: SizeConfig.blockSizeVertical * 4,
//             ),
//             ElevatedButton.icon(
//               icon: Image.asset(
//                 'fonts/google-logo.png',
//                 height: SizeConfig.blockSizeVertical * 5,
//               ),
//               onPressed: () =>
//               { //authRep.googleLogin()},
//               },
//               label: Text(
//                 "Continue With Google",
//                 style: TextStyle(
//                     color: Colors.black,
//                     fontFamily: 'Rockwell',
//                     fontSize: SizeConfig.blockSizeHorizontal * 5.5),
//               ),
//               style: ButtonStyle(
//                   minimumSize: MaterialStateProperty.all<Size>(Size(
//                       SizeConfig.blockSizeHorizontal * 40,
//                       SizeConfig.blockSizeVertical * 6.5)),
//                   backgroundColor:
//                   MaterialStateProperty.all<Color>(Colors.white),
//                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                         side: BorderSide(color: Colors.black, width: 0.5),
//                       ))),
//             ),
//           ],
//         ));
//   }
//
// // void authenticated(AuthRepository authRep) {
// //   if (authRep.isAuthenticated) {
// //     final user = FirebaseAuth.instance.currentUser;
// //     if (user != null) {
// //       var currUserDoc =
// //           FirebaseFirestore.instance.collection('users').doc(user.uid);
// //     }
// //   }
// //   // Navigator.of(context).pop();
// // }
//
// }






import 'package:final_project_2023/Pages/home_page.dart';
import 'package:final_project_2023/Pages/register_page.dart';
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
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              hexStringToColor("0077be"),
              hexStringToColor("00bfff"),
              hexStringToColor("40e0d0")
            ], begin: Alignment.topCenter,end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
              child: Column(
                  children: <Widget>[
                    Text("Login"),
                    SizedBox(
                        height:30
                    ),
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
                    signInSignUpButton(context, true, () {
                      FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text).then((value) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => MyHomePage()));
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

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account? ",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
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