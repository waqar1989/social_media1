import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media1/pages/notificationPage.dart';
import 'package:social_media1/pages/profilePage.dart';
import 'package:social_media1/pages/searchPage.dart';
import 'package:social_media1/pages/timeLinePage.dart';
import 'package:social_media1/pages/uploadPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSignedIn = true;
  PageController pageController;
  int getPageIndex = 0;

  void initState() {
    super.initState();
    pageController = PageController();
  }

  logoutUser() {
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.pushNamed(context, '/signin');
    }).catchError((e) {
      print(e);
    });
  }

  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  onTapPageChange(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  Scaffold buildHomeScreen() {
    return Scaffold(
      body: PageView(
        children: [
          RaisedButton.icon(
              onPressed: logoutUser,
              icon: Icon(Icons.close),
              label: Text("Signout")),
          TimeLinePage(),
          SearchPage(),
          UploadPage(),
          NotificationPage(),
          ProfilePage()
        ],
        controller: pageController,
        onPageChanged: whenPageChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapPageChange,
        backgroundColor: Theme.of(context).accentColor,
        activeColor: Colors.white,
        inactiveColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 37.0,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  buildSignInScreen() {
    Navigator.pushNamed(context, '/signin');
  }

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return buildHomeScreen();
    } else {
      return buildSignInScreen();
    }
  }
}
