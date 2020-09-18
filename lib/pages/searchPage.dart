import 'package:flutter/material.dart';
import 'package:social_media1/Widgets/headerWidget.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: header(context,
          isAppTitle: false, strTitle: "Search", disappearBackButton: false),
    );
  }
}
