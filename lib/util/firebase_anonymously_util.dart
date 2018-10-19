import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_auth/util/firebase_listenter.dart';

class FirebaseAnonymouslyUtil {
  static final FirebaseAnonymouslyUtil _instance =
      new FirebaseAnonymouslyUtil.internal();

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseAuthListener _view;

  FirebaseAnonymouslyUtil.internal();

  factory FirebaseAnonymouslyUtil() {
    return _instance;
  }

  setScreenListener(FirebaseAuthListener view) {
    _view = view;
  }

  Future<FirebaseUser> signIn(String email, String password) async {

    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return user;
  }

  Future<String> createUser(String email, String password) async {

    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    return user.uid;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  void onLoginUserVerified(FirebaseUser currentUser) {
    _view.onLoginUserVerified(currentUser);
  }

  onTokenError(String string) {
    _view.onError(string);
  }
}
