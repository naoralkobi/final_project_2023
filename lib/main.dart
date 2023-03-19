// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:final_project_2023/screen_size_config.dart';
// import 'Pages/home_page.dart';
// import 'Pages/createProfilePage.dart';
// import 'package:flutter/services.dart';
// import 'firebase/auth_repository.dart';
// import 'package:final_project_2023/Pages/login_page.dart';
// import 'package:flutter/services.dart';
//
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setPreferredOrientations(
//       [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
//   runApp(ChangeNotifierProvider(
//       create: (context) => AuthRepository.instance(),
//       builder: (context, snapshot) {
//         return App();
//       }));
// }
//
// class App extends StatelessWidget {
//   final Future<FirebaseApp> _initialization = Firebase.initializeApp();
//
//   @override
//   Widget build(BuildContext context) {
//     // FirebaseAuth.instance.signOut();
//     return FutureBuilder(
//       future: _initialization,
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return MaterialApp(
//             home: Scaffold(
//                 body: Center(
//                     child: Text(snapshot.error.toString(),
//                         textDirection: TextDirection.ltr))),
//           );
//         }
//         if (snapshot.connectionState == ConnectionState.done) {
//           return MyApp();
//         }
//         return Center(child: CircularProgressIndicator());
//       },
//     );
//   }
// }
//
// class MyApp extends StatelessWidget {
//   bool isNew = true;
//
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarColor: Color(0xFFA66CB7), //or set color with: Color(0xFF0000FF)
//     ));
//     // AuthRepository.instance().signOut();
//     FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);
//     return MaterialApp(
//         title: 'Flutter Demo',
//         theme: new ThemeData(
//           // primaryColor: Colors.deepPurpleAccent,
//             appBarTheme: AppBarTheme(
//               color: Color(0xFFA66CB7),
//             ),
//             scaffoldBackgroundColor: const Color(0xFFF8F5F5),
//             fontFamily: 'Rockwell',
//             textTheme: TextTheme(
//                 bodyText2: TextStyle(color: Colors.black),
//                 button: TextStyle(color: Colors.black))),
//         routes: {"/mainPage": (context) => MyApp() },
//         // home: authRep.isAuthenticated ? CreateProfilePage() : loginPage()
//         home:
//         Consumer<AuthRepository>(builder: (context, authRep, snapshot) {
//           if (authRep.isAuthenticated) {
//             if (authRep.isNewInitialized()) {
//               if (authRep.isNew()) {
//                 return CreateProfilePage({});
//               }
//               return MyHomePage();
//             }
//           }
//           return LoginPage();
//         })
//     );
//   }
//
//   void isNewUser() async {
//     // bool isNew = true;
//     final user = FirebaseAuth.instance.currentUser;
//     isNew = await FirebaseFirestore.instance
//         .collection("users")
//         .get()
//         .then((value) {
//       value.docs.forEach((element) {
//         if (element.data()["email"] == user!.email) {
//           isNew = false;
//         }
//       });
//       if (isNew) {
//         FirebaseFirestore.instance
//             .collection("users")
//             .doc(user!.uid)
//             .set({"email": user.email, "UID": user.uid, "Languages": {}});
//       }
//       return isNew;
//     });
//   }
//
//   void createUser(String email, String password) async {
//     AuthRepository authRep = AuthRepository.instance();
//     UserCredential newUser = (await authRep.signUp(email, password))!;
//     FirebaseFirestore.instance
//         .collection("users")
//         .doc(newUser.user!.uid)
//         .set({"email": email, "UID": newUser.user!.uid, "Languages": {}});
//   }
// }
//
//
//
//
//

import 'package:final_project_2023/Pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'FireBase/auth_repository.dart';
import 'Pages/home_page.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    //options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }

  void createUser(String email, String password) async {
    AuthRepository authRep = AuthRepository.instance();
    UserCredential newUser = (await authRep.signUp(email, password))!;
    FirebaseFirestore.instance
        .collection("users")
        .doc(newUser.user!.uid)
        .set({"email": email, "UID": newUser.user!.uid, "Languages": {}});
  }
}
