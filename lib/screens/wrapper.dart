import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:social_media1/screens/home/Homepage.dart';
import 'package:social_media1/screens/authenticate/authenticate.dart';
import 'package:social_media1/models/user.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User1>(context);

    if (user == null) {
      return Authenticate();
    } else
      return HomePage();
  }
}
