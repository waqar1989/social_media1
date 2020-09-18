import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media1/pages/notificationPage.dart';
import 'package:social_media1/pages/profilePage.dart';
import 'package:social_media1/pages/searchPage.dart';
import 'package:social_media1/pages/timeLinePage.dart';
import 'package:social_media1/pages/uploadPage.dart';
import 'package:provider/provider.dart';
// import 'package:social_media1/screens/home/brewlist.dart';
import 'package:social_media1/services/database.dart';
import 'package:social_media1/models/brew.dart';
import 'package:social_media1/models/user.dart';

final _auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  final String userProfileId;
  HomePage({this.userProfileId});

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
    Navigator.pop(context, '/signin');
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

  StreamProvider buildHomeScreen(user) {
    return StreamProvider<List<ProfileData>>.value(
        value: DatabaseService().profiles,
        builder: (context, snapshot) {
          return Scaffold(
            // backgroundColor: Colors.black,
            // appBar: header(context,
            //     isAppTitle: true, strTitle: "Timeline", disappearBackButton: false),
            body: PageView(
              children: [
                // RaisedButton.icon(
                //     onPressed: logoutUser,
                //     icon: Icon(Icons.close),
                //     label: Text(
                //       "Signout",
                //     )),
                TimeLinePage(),
                SearchPage(),
                UploadPage(),
                NotificationPage(),
                ProfilePage(),
              ],
              controller: pageController,
              onPageChanged: whenPageChanges,
              physics: NeverScrollableScrollPhysics(),
            ),
            bottomNavigationBar: CupertinoTabBar(
              currentIndex: getPageIndex,
              onTap: onTapPageChange,
              backgroundColor: Colors.black,
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
        });
  }

  buildSignInScreen() {
    Navigator.pop(context, '/signin');
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User1>(context);

    if (isSignedIn) {
      return buildHomeScreen(user);
    } else {
      return buildSignInScreen();
    }
  }
}


