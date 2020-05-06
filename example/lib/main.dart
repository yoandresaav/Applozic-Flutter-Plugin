import 'home.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:applozic_flutter/applozic_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Applozic sample app'),
        ),
        body: LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  TextEditingController userId = new TextEditingController();
  TextEditingController displayName = new TextEditingController();
  TextEditingController password = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    try {
      ApplozicFlutter.isLoggedIn().then((value) {
        print("Logged in : " + value.toString());
        if (value) {
          print("Logged in after check");
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        }
      });
    } on Exception catch (e) {
      print("isLogged in error : " + e.toString());
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 155.0,
              child: Image.asset(
                "assets/ic_launcher.png",
                fit: BoxFit.contain,
              ),
            ),
            new TextField(
              controller: userId,
              decoration: new InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  hintText: "UserId *",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0))),
            ),
            SizedBox(height: 10),
            new TextField(
              controller: displayName,
              decoration: new InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  hintText: "Display name",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0))),
            ),
            SizedBox(height: 10),
            new TextField(
              controller: password,
              obscureText: true,
              decoration: new InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  hintText: "Password *",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0))),
            ),
            SizedBox(height: 10),
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff01A0C7),
                child: new MaterialButton(
                  onPressed: () {
                    loginUser(context);
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Login",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0)
                          .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ))
          ],
        ),
      ),
    );
  }

  void loginUser(context) {
    dynamic user = {
      'applicationId': "applozic-sample-app",
      'userId': userId.text,
      'displayName': displayName.text,
      'password': password.text
    };

    ApplozicFlutter.login(user).then((value) {
      if (value != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    }).catchError((error, stack) =>
        print("Error while logging in : " + error.toString()));
    /*try {
      dynamic user = {
        'applicationId': "applozic-sample-app",
        'userId': userId.text,
        'displayName': displayName.text,
        'password': password.text
      };

      ApplozicFlutter.login(user).then((value) {
        if (value != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        }
      });
    } on Exception catch (e) {
      print("Error while logging in : " + e.toString());
    }*/
  }
}
