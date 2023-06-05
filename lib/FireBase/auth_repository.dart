import 'dart:async';
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


  bool isNew() {
    if (isNewStatus == IsNew.New) {
      return true;
    }
    return false;
  }

  Future signOut() async {
    String userID = user!.uid;
    _auth.signOut();
    _status = Status.Unauthenticated;
    isNewStatus = IsNew.Uninitialized;
    notifyListeners();
    FirebaseDB.firebaseDb.removeUserToken(userID);
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

}