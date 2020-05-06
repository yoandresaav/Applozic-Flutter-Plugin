import 'package:applozic_flutter_example/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:applozic_flutter/applozic_flutter.dart';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  void initState() {
    try {} catch (e) {}
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
            title: const Text('Welcome to Applozic!'),
          ),
          body: HomePageWidget()),
    );
  }
}

class HomePageWidget extends StatelessWidget {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  bool isGroupInProgress = false;

  String getPlatformName() {
    if (Platform.isAndroid) {
      return "Android";
    } else if (Platform.isIOS) {
      return "iOS";
    } else {
      return "NOP";
    }
  }

  String getCurrentTime() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  int getTimeStamp() {
    return new DateTime.now().millisecondsSinceEpoch;
  }

  void createGroup() {
    ApplozicFlutter.getLoggedInUserId().then((value) {
      if (!isGroupInProgress) {
        isGroupInProgress = true;
        List<String> groupMemberList = ['reytum7', 'reytum6', 'reytum9'];

        if (!groupMemberList.contains(value)) {
          groupMemberList.add(value);
        }

        dynamic groupInfo = {
          'groupName': "FGroup-" + getCurrentTime() + "-" + getPlatformName(),
          'groupMemberList': groupMemberList,
          'imageUrl': 'https://www.applozic.com/favicon.ico',
          'type': 2,
          'admin': value,
          'metadata': {
            'plugin': "Flutter",
            'platform': getPlatformName(),
            'createdAt': getCurrentTime()
          }
        };

        ApplozicFlutter.createGroup(groupInfo)
            .then((value) {
              print("Group created sucessfully: " + value);
              ApplozicFlutter.launchChatWithGroupId(value)
                  .then((value) => print("Launched successfully : " + value))
                  .catchError((error, stack) {
                print("Unable to launch group : " + error != null
                    ? error
                    : stack);
              });
            })
            .catchError((error, stack) =>
                print("Group created failed : " + error.toString()))
            .whenComplete(() => isGroupInProgress = false);
      }
    }).catchError((error, stack) {
      print("User get error : " + error);
    });
  }

  void addContacts() {
    dynamic user1 = {
      'userId': "u1" + getTimeStamp().toString(),
      'displayName': "FU1-" + getCurrentTime() + "-" + getPlatformName(),
      "metadata": {
        'plugin': "Flutter",
        'platform': getPlatformName(),
        'createdAt': getCurrentTime()
      }
    };

    dynamic user2 = {
      'userId': "u2" + getTimeStamp().toString(),
      'displayName': "FU2-" + getCurrentTime() + "-" + getPlatformName(),
      "metadata": {
        'plugin': "Flutter",
        'platform': getPlatformName(),
        'createdAt': getCurrentTime()
      }
    };

    dynamic userArray = [user1, user2];

    ApplozicFlutter.addContacts(userArray)
        .then((value) => print("Contact added successfully: " + value))
        .catchError((e, s) => print("Failed to add contacts: " + e.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff01A0C7),
                child: new MaterialButton(
                  onPressed: () {
                    ApplozicFlutter.launchChat();
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Launch chat",
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )),
            SizedBox(height: 10),
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff01A0C7),
                child: new MaterialButton(
                  onPressed: () {
                    ApplozicFlutter.launchChatWithUser("reytum7");
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Launch chat with user",
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )),
            SizedBox(height: 10),
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff01A0C7),
                child: new MaterialButton(
                  onPressed: () {
                    ApplozicFlutter.launchChatWithGroupId(30434431)
                        .then((value) =>
                            print("Launched successfully : " + value))
                        .catchError((error, stack) {
                      print("Unable to launch group : " + error.toString());
                    });
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Launch chat with group",
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )),
            SizedBox(height: 10),
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff01A0C7),
                child: new MaterialButton(
                  onPressed: () {
                    createGroup();
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Create group",
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )),
            SizedBox(height: 10),
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff01A0C7),
                child: new MaterialButton(
                  onPressed: () {
                    addContacts();
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Add contacts",
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )),
            SizedBox(height: 10),
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff01A0C7),
                child: new MaterialButton(
                  onPressed: () {
                    dynamic user = {
                      'displayName':
                          "FUser-" + getCurrentTime() + "-" + getPlatformName(),
                      'metadata': {
                        'plugin': "Flutter",
                        'paltform': getPlatformName(),
                        'userUpdateTime': getCurrentTime()
                      }
                    };

                    ApplozicFlutter.updateUserDetail(user)
                        .then(
                            (value) => print("User details updated : " + value))
                        .catchError((e, s) => print(
                            "Unable to update user details : " +
                                e.toString()));
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Update user",
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )),
            SizedBox(height: 10),
            new Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Color(0xff01A0C7),
                child: new MaterialButton(
                  onPressed: () {
                    ApplozicFlutter.logout()
                        .then((value) => {
                              print("Logout successfull"),
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyApp()))
                            })
                        .catchError((error, stack) =>
                            print("Logout failed : " + error.toString()));
                  },
                  minWidth: 400,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text("Logout",
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ))
          ],
        ),
      ),
    );
  }
}
