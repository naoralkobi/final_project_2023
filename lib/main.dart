import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Pages/home_page.dart';
import 'Pages/createProfilePage.dart';
import 'package:flutter/services.dart';
import 'firebase/auth_repository.dart';
import 'package:final_project_2023/Pages/login_page.dart';

/// This is the entry point of the Flutter application
void main() {
  // Ensure that the widgets framework is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  // Lock the app orientation to portrait mode
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // Create an instance of the authentication repository
  // using the ChangeNotifierProvider from the provider package
  // and pass it to the root widget of the app
  runApp(ChangeNotifierProvider(
    // The create callback returns an instance of the AuthRepository
    // which is a ChangeNotifier subclass that provides authentication-related functionality
  create: (context) => AuthRepository.instance(),
      builder: (context, snapshot) {
        return App();
      }));
}

class App extends StatelessWidget {
  // Initialize Firebase in the background before the app starts
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    // Uncomment the following line to sign out the user on app start
    // FirebaseAuth.instance.signOut();
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // If an error occurs during Firebase initialization, show an error message
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
                body: Center(
                    child: Text(snapshot.error.toString(),
                        textDirection: TextDirection.ltr))),
          );
        }
        // If Firebase initialization is complete, return the main app widget
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  bool isNew = true;

  @override
  Widget build(BuildContext context) {
    // Set the status bar color to blue
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF0077be), //or set color with: Color(0xFF0000FF)
    ));
    // Sign out the user from Firebase authentication
    AuthRepository.instance().signOut();
    // Disable Firestore persistence
    FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // primaryColor: Colors.deepPurpleAccent,
            appBarTheme: const AppBarTheme(
              color: Color(0xFF0077BE),
            ),
            // Set the scaffold background color to light gray
            scaffoldBackgroundColor: const Color(0xFFF8F5F5),
            // Set the default font family to Rockwell
            fontFamily: 'Rockwell',
            // Set the default text theme to black color
            textTheme: TextTheme(
                bodyMedium: TextStyle(color: Colors.black),
                labelLarge: TextStyle(color: Colors.black))),
        routes: {"/mainPage": (context) => MyApp() },
        // home: authRep.isAuthenticated ? CreateProfilePage() : loginPage()
        // Check the authentication state using a Consumer widget
        home:
        Consumer<AuthRepository>(builder: (context, authRep, snapshot) {
          if (authRep.isAuthenticated) {
            if (authRep.isNewInitialized()) {
              if (authRep.isNew()) {
                // If the user is new, show the create profile page
                return CreateProfilePage(const {});
              }
              return MyHomePage();
              // If the user is not new, show the home page
            }
          }
          return const LoginPage();
          // If the user is not authenticated, show the login page
        })
    );
  }

  /// Check if the user is a new user or not by searching the user's email in the users collection
  void isNewUser() async {
    // bool isNew = true;
    final user = FirebaseAuth.instance.currentUser;
    isNew = await FirebaseFirestore.instance
        .collection("users")
        .get()
        .then((value) {
      for (var element in value.docs) {
        if (element.data()["email"] == user!.email) {
          isNew = false;
        }
      }
      if (isNew) {
        // If the user is new, add the user to the users collection
        FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .set({"email": user.email, "UID": user.uid, "Languages": {}});
      }
      return isNew;
    });
  }

  /// Create a new user with the given email and password
  void createUser(String email, String password) async {
    AuthRepository authRep = AuthRepository.instance();
    UserCredential newUser = (await authRep.signUp(email, password))!;
    FirebaseFirestore.instance
        .collection("users")
        .doc(newUser.user!.uid)
        .set({"email": email, "UID": newUser.user!.uid, "Languages": {}});
  }
}