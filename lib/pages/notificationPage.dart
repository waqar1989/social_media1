import 'package:flutter/material.dart';
import 'package:social_media1/Widgets/headerWidget.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
          header(context, strTitle: "Notification", disappearBackButton: false),
    );
  }
}
