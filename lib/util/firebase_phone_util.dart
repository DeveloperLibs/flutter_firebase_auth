import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_auth/util/firebase_listenter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebasePhoneUtil {
  static final FirebasePhoneUtil _instance = new FirebasePhoneUtil.internal();


  FirebasePhoneUtil.internal();

  factory FirebasePhoneUtil() {
    return _instance;
  }

  FirebaseAuthListener _view;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String verificationId;
  FirebaseUser user;

  setScreenListener(FirebaseAuthListener view) {
    _view = view;
  }

  Future<void> verifyPhoneNumber(String phoneNumber, String code) async {
    final PhoneVerificationCompleted verificationCompleted =
        (FirebaseUser user) {};

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      _view.onError(authException.message);
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this.verificationId = verificationId;
      _view.verificationCodeSent(forceResendingToken);
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _view.onError(verificationId);
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: code + phoneNumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  verifyOtp(String smsCode) async {
    final FirebaseUser user = await _auth.signInWithPhoneNumber(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final FirebaseUser currentUser = await _auth.currentUser();
    if (!identical(user.uid, currentUser.uid)) {
      onLoginUserVerified(currentUser);
    }
  }

  void onLoginUserVerified(FirebaseUser currentUser) {
    _view.onLoginUserVerified(currentUser);
  }

  onTokenError(String string) {
    print("libs "+string);
  }
}
