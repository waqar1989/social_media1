import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media1/screens/home/brewtile.dart';
import 'package:social_media1/models/brew.dart';

class BrewList extends StatefulWidget {
  @override
  _BrewListState createState() => _BrewListState();
}

class _BrewListState extends State<BrewList> {
  @override
  Widget build(BuildContext context) {
    final brews = Provider.of<List<ProfileData>>(context) ?? [];

    return ListView.builder(
        itemCount: brews.length,
        itemBuilder: (context, index) {
          return BrewTile(profile: brews[index]);
        });
  }
}
