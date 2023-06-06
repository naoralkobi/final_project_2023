import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../consts.dart';
import 'fireBaseDB.dart';


enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

enum IsNew { New, NotNew, Uninitialized }

class AuthRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User? _user;
  Status _status = Status.Uninitialized;
  bool _isSigningIn = false;
  final googleSignIn = GoogleSignIn();
  IsNew isNewStatus = IsNew.Uninitialized;


  AuthRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth.currentUser;
    _onAuthStateChanged(_user);
  }

  Status get status => _status;

  User? get user => _user;

  void setNotNew() {
    isNewStatus = IsNew.NotNew;
    notifyListeners();
  }

  void setNew() {
    isNewStatus = IsNew.New;
  }

  bool isNew() {
    if (isNewStatus == IsNew.New) {
      return true;
    }
    return false;
  }

  bool isNewInitialized() {
    if (isNewStatus == IsNew.Uninitialized) {
      return false;
    }
    return true;
  }

  bool get isAuthenticated => status == Status.Authenticated;

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e);
      _status = Status.Unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    // await googleSignIn.disconnect().catchError((onError) {
    //   print("Error $onError");
    // });
    String userID = user!.uid;
    _auth.signOut();
    _status = Status.Unauthenticated;
    isNewStatus = IsNew.Uninitialized;
    notifyListeners();
    FirebaseDB.Firebase_db.removeUserToken(userID);
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = Status.Unauthenticated;
      isNewStatus = IsNew.Uninitialized;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
      DocumentReference doc =
      FirebaseFirestore.instance.collection(USERS).doc(firebaseUser.uid);
      if (!(await doc.get()).exists) {
        isNewStatus = IsNew.New;
      } else {
        isNewStatus = IsNew.NotNew;
      }
    }
    notifyListeners();
  }

  bool get isSigningIn => _isSigningIn;

  set isSigningIn(bool isSigningIn) {
    _isSigningIn = isSigningIn;
    notifyListeners();
  }

  Future googleLogin() async {
    isSigningIn = true;
    final user = await googleSignIn.signIn().catchError((onError) {
      log("Error $onError");
    });
    if (user == null) {
      isSigningIn = false;
      return;
    } else {
      // _status = Status.Authenticated;
      // _isNew = false;
      final googleAuth = await user.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      isSigningIn = false;
    }
  }

}