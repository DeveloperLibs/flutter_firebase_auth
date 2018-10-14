import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDashboardScreen extends StatelessWidget {
  FirebaseUser currentUser;

  UserDashboardScreen(this.currentUser);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primaryColor: const Color(0xFFF47C06),
        primaryColorDark: const Color(0xFFFFCA2B),
      ),
      home: UserDashboard(currentUser),
    );
  }
}

class UserDashboard extends StatefulWidget {
  FirebaseUser currentUser;

  UserDashboard(this.currentUser);

  @override
  _MyHomePageState createState() => new _MyHomePageState(currentUser);
}

class _MyHomePageState extends State<UserDashboard> {
  FirebaseUser currentUser;

  _MyHomePageState(this.currentUser);

  String lebel;

  @override
  void initState() {
    super.initState();
    if (currentUser.phoneNumber != null) {
      lebel = "Welcome\n" + currentUser.phoneNumber;
    } else if (currentUser.displayName != null) {
      lebel = "Welcome\n" + currentUser.displayName;
    } else {
      lebel = "Welcome\n" + currentUser.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Flutter Auth',
          style: new TextStyle(color: Colors.white),
        ),
      ),
      body: new Center(
        child: new Text(
          lebel,
          style: new TextStyle(fontSize: 30.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
