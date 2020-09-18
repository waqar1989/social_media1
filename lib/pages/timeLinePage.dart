import 'package:flutter/material.dart';
import 'package:social_media1/Widgets/headerWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _auth = FirebaseAuth.instance;

class TimeLinePage extends StatefulWidget {
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  logoutUser() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: header(context,
          isAppTitle: true, strTitle: "Timeline", disappearBackButton: false),
      body: PageView(children: [
        RaisedButton.icon(
            onPressed: logoutUser,
            icon: Icon(Icons.close),
            label: Text(
              "Signout",
            )),
      ]),
    );
  }
}
