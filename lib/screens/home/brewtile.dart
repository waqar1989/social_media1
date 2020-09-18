import 'package:flutter/material.dart';
import 'package:social_media1/models/brew.dart';

class BrewTile extends StatelessWidget {
  final ProfileData profile;

  BrewTile({this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage("assets/images/coffee_icon.png"),
            radius: 25.0,
          ),
          title: Text(profile.gender),
          subtitle: Text('Takes ${profile.education}'),
        ),
      ),
    );
  }
}
