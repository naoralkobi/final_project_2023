// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:final_project_2023/Pages/createProfilePage.dart';
// import 'package:final_project_2023/screen_size_config.dart';
// import 'package:final_project_2023/firebase/auth_repository.dart';
//
// class SignUpPage extends StatefulWidget {
//   @override
//   _SignUpPageState createState() => _SignUpPageState();
// }
//
// class _SignUpPageState extends State<SignUpPage> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final repeatPasswordController = TextEditingController();
//   final snackBar = SnackBar(content: Text('No image selected'));
//   final _formKey = GlobalKey<FormState>();
//   bool isEmailUnique = true;
//
//   bool isLoading = false;
//
//
//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     return Scaffold(
//         resizeToAvoidBottomInset: false,
//         appBar: PreferredSize(
//           preferredSize: Size.fromHeight(70),
//           child: AppBar(
//             automaticallyImplyLeading: false,
//             flexibleSpace: Container(
//               padding: EdgeInsets.fromLTRB(10, 35, 0, 0),
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     icon: Icon(
//                       Icons.arrow_back,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     "Join SociaLang",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: SizeConfig.blockSizeHorizontal * 7),
//                   )
//                 ],
//               ),
//             ),
//             iconTheme: IconThemeData(color: Colors.black),
//             centerTitle: true,
//             shape: RoundedRectangleBorder(
//                 borderRadius:
//                 BorderRadius.vertical(bottom: Radius.circular(20))),
//           ),
//         ),
//         body: Form(
//             key: _formKey,
//             child: Column(children: [
//               Container(
//                   margin: EdgeInsets.fromLTRB(35, 0, 35, 0),
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         height: SizeConfig.blockSizeVertical * 8,
//                       ),
//                       TextFormField(
//                         controller: emailController,
//                         validator: (text) {
//                           if (text == null || text.isEmpty) {
//                             return 'Text is empty';
//                           } else if (!isEmailUnique) {
//                             return "A user already exists with this email";
//                           } else if (!RegExp(
//                               r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
//                               .hasMatch(text)) {
//                             return "Email is not valid";
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: const BorderRadius.all(
//                               const Radius.circular(10.0),
//                             ),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide:
//                             BorderSide(color: Colors.grey, width: 2.0),
//                             borderRadius: const BorderRadius.all(
//                               const Radius.circular(10.0),
//                             ),
//                           ),
//                           hintText: 'Email',
//                           prefixIcon: Icon(Icons.mail_outline),
//                         ),
//                       ),
//                       SizedBox(
//                         height: SizeConfig.blockSizeVertical * 4,
//                       ),
//                       TextFormField(
//                         controller: passwordController,
//                         obscureText: true,
//                         validator: (text) {
//                           if (text == null || text.isEmpty) {
//                             return 'Text is empty';
//                           } else if (text.length < 6) {
//                             return "Passwords must be longer than 6 characters";
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: const BorderRadius.all(
//                               const Radius.circular(10.0),
//                             ),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide:
//                             BorderSide(color: Colors.grey, width: 2.0),
//                             borderRadius: const BorderRadius.all(
//                               const Radius.circular(10.0),
//                             ),
//                           ),
//                           hintText: 'Password',
//                           prefixIcon: Icon(Icons.vpn_key),
//                         ),
//                       ),
//                       SizedBox(
//                         height: SizeConfig.blockSizeVertical * 4,
//                       ),
//                       TextFormField(
//                         controller: repeatPasswordController,
//                         obscureText: true,
//                         validator: (text) {
//                           if (text == null || text.isEmpty) {
//                             return 'Text is empty';
//                           } else if (repeatPasswordController.text !=
//                               passwordController.text) {
//                             return "Passwords must match";
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: const BorderRadius.all(
//                               const Radius.circular(10.0),
//                             ),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide:
//                             BorderSide(color: Colors.grey, width: 2.0),
//                             borderRadius: const BorderRadius.all(
//                               const Radius.circular(10.0),
//                             ),
//                           ),
//                           hintText: 'Repeat Password',
//                           prefixIcon: Icon(Icons.vpn_key),
//                         ),
//                       ),
//                       SizedBox(
//                         height: SizeConfig.blockSizeVertical * 4,
//                       ),
//                       SizedBox(
//                         height: SizeConfig.blockSizeVertical * 4,
//                       ),
//                       isLoading ?
//                       CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA66CB7))
//                       )
//                           :
//                       ElevatedButton(
//                         onPressed: () async {
//                           await checkEmailUnique(emailController.text);
//                           if (_formKey.currentState!.validate()) {
//                             goToCreateUser(emailController.text,
//                                 passwordController.text, context);
//                           }
//                         },
//                         child:
//                         Text(
//                           "Continue",
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontFamily: 'Rockwell',
//                               fontSize: 20),
//                         ),
//                         style: ButtonStyle(
//                             minimumSize:
//                             MaterialStateProperty.all<Size>(Size(200, 60)),
//                             backgroundColor: MaterialStateProperty.all<Color>(
//                                 Color(0xFFA66CB7)),
//                             shape: MaterialStateProperty.all<
//                                 RoundedRectangleBorder>(RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                               side: BorderSide(color: Colors.black, width: 0.5),
//                             ))),
//                       ),
//                     ],
//                   ))
//             ])));
//   }
//
//   Future<void> goToCreateUser(
//       String email, String password, var context) async {
//     AuthRepository authRep = AuthRepository.instance();
//     setState(() {
//       isLoading = true;
//     });
//     await authRep.signUp(email, password);
//     setState(() {
//       isLoading = false;
//     });
//     if (!authRep.isAuthenticated) {
//       final snackBar = SnackBar(
//         content: Text('Error in sign-up'),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     } else {
//       Navigator.of(context)
//           .pushReplacement(MaterialPageRoute<void>(builder: (BuildContext context) {
//         return CreateProfilePage({});
//       }));
//     }
//   }
//
//   Future<void> checkEmailUnique(String email) async {
//     isEmailUnique = true;
//     await FirebaseFirestore.instance.collection("users").get().then((value) {
//       print(value.size);
//       print("yesssssssssssssssssssssssssssss");
//       value.docs.forEach((element) {
//         if (element.data()["email"] == email) {
//           isEmailUnique = false;
//         }
//       });
//       // isUnique = true;
//     });
//     // return isEmailUnique;
//   }
//
// }
//
//
//







import 'package:final_project_2023/Pages/home_page.dart';
import 'package:final_project_2023/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Widgets/reusable_widget.dart';
import 'createProfilePage.dart';

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
                          builder: (context) => CreateProfilePage({})));
                    }).onError((error, stackTrace) { print("Error ${error.toString()}");});
                  })
                ],
      ),
    ))),
    );
  }
}