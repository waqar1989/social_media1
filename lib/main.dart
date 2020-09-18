import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media1/models/user.dart';
import 'package:social_media1/screens/wrapper.dart';
import 'package:social_media1/services/auth.dart';
import 'screens/authenticate/signin.dart';
import 'screens/authenticate/signup.dart';
import 'screens/home/Homepage.dart';
import 'services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User1>.value(
        value: AuthService().user,
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              fontFamily: 'Raleway',
              // scaffoldBackgroundColor: Color(0xff1F1F1F),
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: Wrapper(),
            routes: {
              '/signup': (_) => SignUp(),
              '/homepage': (_) => HomePage(),
              '/signin': (_) => SignIn(),
            },
          );
        });
  }
}
