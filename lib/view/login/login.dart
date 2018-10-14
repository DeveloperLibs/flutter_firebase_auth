import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/util/app_util.dart';
import 'package:flutter_firebase_auth/util/firebase_anonymously_util.dart';
import 'package:flutter_firebase_auth/util/firebase_google_util.dart';
import 'package:flutter_firebase_auth/util/firebase_listenter.dart';
import 'package:flutter_firebase_auth/util/firebase_phone_util.dart';
import 'package:flutter_firebase_auth/view/otp_verification/otp_verification_screen.dart';
import 'package:flutter_firebase_auth/view/user_dashboard/user_dashboard.dart';
import 'package:flutter_firebase_auth/widget/progress_hud.dart';
import 'package:flutter_svg/flutter_svg.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage>
    implements FirebaseAuthListener {
  bool _isPhoneAuthEnable = true;
  bool _isGoogleAuthEnable = false;
  bool _isEmailAuthEnable = false;
  bool _isLoading = false;

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _teMobileEmail = TextEditingController();
  final _teCountryCode = TextEditingController();
  final _tePassword = TextEditingController();

  FocusNode _focusNodeMobileEmail = new FocusNode();
  FocusNode _focusNodeCountryCode = new FocusNode();
  FocusNode _focusNodePassword = new FocusNode();

  FirebasePhoneUtil firebasePhoneUtil;
  FirebaseGoogleUtil firebaseGoogleUtil;
  FirebaseAnonymouslyUtil firebaseAnonymouslyUtil;

  @override
  void initState() {
    super.initState();
    firebasePhoneUtil = FirebasePhoneUtil();
    firebasePhoneUtil.setScreenListener(this);

    firebaseGoogleUtil = FirebaseGoogleUtil();
    firebaseGoogleUtil.setScreenListener(this);

    firebaseAnonymouslyUtil = FirebaseAnonymouslyUtil();
    firebaseAnonymouslyUtil.setScreenListener(this);
  }

  void _submit() {
    {
      setState(() {
        if (_isPhoneAuthEnable) {
          if (_teMobileEmail.text.isEmpty) {
            showAlert("Enter valid mobile number");
          } else {
            _isLoading = true;
            firebasePhoneUtil.verifyPhoneNumber(
                _teMobileEmail.text.trim(), _teCountryCode.text.trim());
          }
        } else if (_isEmailAuthEnable &&
            validateEmail(_teMobileEmail.text) == null) {
          _isLoading = true;
          login(_teMobileEmail.text, _tePassword.text);
        }
      });
    }
  }

  String validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      AppUtil().showAlert("Email is Required");
      return "Email is Required";
    } else if (!regExp.hasMatch(value)) {
      AppUtil().showAlert("Invalid Email");
      return "Invalid Email";
    } else {
      return null;
    }
  }

  @override
  void moveUserDashboardScreen(FirebaseUser currentUser) {
    phoneTabEnable();
    closeLoader();
    Navigator.of(context).push<String>(
      new MaterialPageRoute(
        settings: RouteSettings(name: '/home_screen'),
        builder: (context) => UserDashboardScreen(currentUser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var tabs = new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new GestureDetector(
          onTap: () {
            phoneTabEnable();
          },
          child: new SvgPicture.asset(
            "assets/smartphone.svg",
            height: 30.0,
            width: 30.0,
            color: _isPhoneAuthEnable
                ? new Color(0xFF2CB044)
                : new Color(0xFF626262),
            allowDrawingOutsideViewBox: true,
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new GestureDetector(
          onTap: () {
            gMailTabEnable();
          },
          child: new SvgPicture.asset(
            "assets/gmail.svg",
            height: 38.0,
            width: 38.0,
            color: _isGoogleAuthEnable
                ? new Color(0xFF2CB044)
                : new Color(0xFF626262),
            allowDrawingOutsideViewBox: true,
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new GestureDetector(
          onTap: () {
            eMailTabEnable();
          },
          child: new SvgPicture.asset(
            "assets/email.svg",
            height: 30.0,
            width: 30.0,
            color: _isEmailAuthEnable
                ? new Color(0xFF2CB044)
                : new Color(0xFF626262),
            allowDrawingOutsideViewBox: true,
          ),
        ),
      ],
    );

    var phoneAuthForm = new Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Expanded(
              child: new TextFormField(
                controller: _teCountryCode,
                focusNode: _focusNodeCountryCode,
                decoration: InputDecoration(
                  labelText: "Code",
                  hintText: "Country code",
                  fillColor: new Color(0xFF2CB044),
                ),
              ),
              flex: 1,
            ),
            new SizedBox(
              width: 10.0,
            ),
            new Expanded(
              child: new TextFormField(
                controller: _teMobileEmail,
                focusNode: _focusNodeMobileEmail,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  hintText: "Mobile number",
                  fillColor: new Color(0xFF2CB044),
                  prefixIcon: new Icon(Icons.mobile_screen_share),
                ),
              ),
              flex: 5,
            ),
          ],
        ),
        new SizedBox(
          height: 10.0,
        ),
        tabs
      ],
    );

    var anonymouslyForm = new Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new TextFormField(
          controller: _teMobileEmail,
          focusNode: _focusNodeMobileEmail,
          decoration: InputDecoration(
            labelText: "Please enter email",
            hintText: "Email",
            fillColor: new Color(0xFF2CB044),
            prefixIcon: new Icon(Icons.email),
          ),
        ),
        new SizedBox(
          height: 10.0,
        ),
        new TextFormField(
          controller: _tePassword,
          focusNode: _focusNodePassword,
          decoration: InputDecoration(
            labelText: "Password",
            hintText: "Passwrod",
            fillColor: new Color(0xFF2CB044),
            prefixIcon: new Icon(Icons.keyboard_hide),
          ),
        ),
        new SizedBox(
          height: 10.0,
        ),
        tabs
      ],
    );

    var googleForm = new Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new SizedBox(
          height: 20.0,
        ),
        new Center(
          child: new CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
        new SizedBox(
          height: 40.0,
        ),
        tabs
      ],
    );

    var loginForm = new Column(
      children: <Widget>[
        new Container(
          alignment: FractionalOffset.center,
          margin: EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 0.0),
          padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
          decoration: new BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 1.0),
            border: Border.all(color: const Color(0x33A6A6A6)),
            borderRadius: new BorderRadius.all(const Radius.circular(6.0)),
          ),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              _isPhoneAuthEnable
                  ? phoneAuthForm
                  : _isEmailAuthEnable ? anonymouslyForm : googleForm,
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _isEmailAuthEnable
                      ? new GestureDetector(
                          onTap: () {
                            _signUp();
                          },
                          child: new Container(
                            margin: EdgeInsets.only(top: 20.0,right: 20.0),
                            padding: EdgeInsets.all(15.0),
                            alignment: FractionalOffset.center,
                            decoration: new BoxDecoration(
                              color: new Color(0xFF2CB044),
                              borderRadius: new BorderRadius.all(
                                  const Radius.circular(6.0)),
                            ),
                            child: Text(
                              _isEmailAuthEnable ? "SIGN-UP" : "",
                              style: new TextStyle(
                                  color: const Color(0xFFFFFFFF),
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : new SizedBox(
                          width: 0.0,
                          height: 0.0,
                        ),
                  new GestureDetector(
                    onTap: () {
                      _submit();
                    },
                    child: new Container(
                      margin: EdgeInsets.only(top: 20.0),
                      padding: EdgeInsets.all(15.0),
                      alignment: FractionalOffset.center,
                      decoration: new BoxDecoration(
                        color: new Color(0xFF2CB044),
                        borderRadius:
                            new BorderRadius.all(const Radius.circular(6.0)),
                      ),
                      child: Text(
                        _isEmailAuthEnable ? "LOGIN" : "SUBMIT",
                        style: new TextStyle(
                            color: const Color(0xFFFFFFFF),
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    var screenRoot = new Container(
      height: double.maxFinite,
      alignment: FractionalOffset.center,
      child: new SingleChildScrollView(
        child: new Center(
          child: loginForm,
        ),
      ),
    );

    return new Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      appBar: null,
      key: _scaffoldKey,
      body: ProgressHUD(
        child: screenRoot,
        inAsyncCall: _isLoading,
        opacity: 0.0,
      ),
    );
  }

  @override
  void onLoginError(String errorTxt) {
    setState(() => _isLoading = false);
  }

  @override
  void closeLoader() {
    setState(() => _isLoading = false);
  }

  @override
  void showAlert(String msg) {
    setState(() {
      AppUtil().showAlert(msg);
    });
  }

  @override
  void showLoader() {
    setState(() => _isLoading = true);
  }

  @override
  verificationCodeSent(int forceResendingToken) {
    moveOtpVerificationScreen();
  }

  @override
  onLoginUserVerified(FirebaseUser currentUser) {
    moveUserDashboardScreen(currentUser);
  }

  @override
  onError(String msg) {
    showAlert(msg);
    setState(() {
      _isLoading = false;
    });
  }

  void phoneTabEnable() {
    setState(() {
      _isPhoneAuthEnable = true;
      _isEmailAuthEnable = false;
      _isGoogleAuthEnable = false;
      _teMobileEmail.text="";
    });
  }

  void gMailTabEnable() {
    setState(() {
      _isPhoneAuthEnable = false;
      _isEmailAuthEnable = false;
      _isGoogleAuthEnable = true;
      _teMobileEmail.text="";
      firebaseGoogleUtil.signInWithGoogle();
    });
  }

  void eMailTabEnable() {
    setState(() {
      _teMobileEmail.text="";
      _isPhoneAuthEnable = false;
      _isEmailAuthEnable = true;
      _isGoogleAuthEnable = false;
    });
  }

  loginError(e) {
    setState(() {
      AppUtil().showAlert(e.message);
      _isLoading = false;
    });
  }

  void moveOtpVerificationScreen() {
    closeLoader();
    Navigator.of(context).push<String>(
      new MaterialPageRoute(
        settings: RouteSettings(name: '/otp_verification'),
        builder: (context) => OtpVerificationScreen(),
      ),
    );
  }

  void _signUp() {
    setState(() {
      if (_isEmailAuthEnable && validateEmail(_teMobileEmail.text) == null) {
        _isLoading = true;
        firebaseAnonymouslyUtil
            .createUser(_teMobileEmail.text, _tePassword.text)
            .then((String user) => login(_teMobileEmail.text, _tePassword.text))
            .catchError((e) => loginError(e));
      }
    });
  }

  login(String email, String pass) {
    firebaseAnonymouslyUtil
        .signIn(_teMobileEmail.text, _tePassword.text)
        .then((FirebaseUser user) => moveUserDashboardScreen(user))
        .catchError((e) => loginError(e));
  }
}
