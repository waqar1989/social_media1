import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media1/Widgets/headerWidget.dart';
import 'package:provider/provider.dart';
import 'package:social_media1/Widgets/postTileWIdget.dart';
import 'package:social_media1/Widgets/postWidget.dart';
import 'package:social_media1/Widgets/progressWidget.dart';
import 'package:social_media1/models/user.dart';
import 'package:social_media1/pages/editProfilePage.dart';
import 'package:social_media1/screens/home/Homepage.dart';
import 'package:social_media1/services/database.dart';
import 'package:social_media1/shared/loading.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String currentOnLineUserId = '';
  bool loading = false;
  int countPost = 0;
  List<Post> postsList = [];
  String postOrientation = "grid";

  void iniState() {
    getAllProfilePosts();
  }

  createProfileView(userData) {
    return Padding(
      padding: EdgeInsets.all(17.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 45.0,
                  backgroundImage: NetworkImage(
                      'https://i.pinimg.com/originals/2e/2f/ac/2e2fac9d4a392456e511345021592dd2.jpg')),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        createColumns('Posts', 0),
                        createColumns('followers', 0),
                        createColumns('following', 0),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        createButtons(userData),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 13),
            child: Text(
              userData.name,
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 5.0),
            child: Text(
              userData.education,
              style: TextStyle(fontSize: 15.0, color: Colors.white),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 3.0),
            child: Text(
              userData.gender,
              style: TextStyle(fontSize: 15.0, color: Colors.white70),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 3.0),
            child: Text(
              userData.location,
              style: TextStyle(fontSize: 15.0, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  createButtons(user) {
    bool ownProfile = true;

    if (ownProfile) {
      return createButtonTitleAndFunction(
        "Edit Profile",
        editUserProfile,
      );
    }
  }

  Container createButtonTitleAndFunction(
      String title, Function performFunction) {
    return Container(
      padding: EdgeInsets.only(top: 3.0),
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          width: 245.0,
          height: 26.0,
          child: Text(title,
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6.0)),
        ),
      ),
    );
  }

  editUserProfile() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => EditProfilePage()));
  }

  Column createColumns(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
                fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User1>(context);
    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            circularProgress();
          } else {
            UserData userData = snapshot.data;
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: header(context,
                  strTitle: userData.downloadUrl.toString(),
                  disappearBackButton: false),
              body: ListView(
                children: [
                  createProfileView(userData),
                  Divider(),
                  createListAndGridPostOrientation(),
                  Divider(height: 0.0),
                  displayProfilePost(),
                ],
              ),
            );
          }
        });
  }

  displayProfilePost() {
    if (loading) {
      return circularProgress();
    } else if (postsList.isEmpty) {
      return Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(30.0),
            child: Icon(Icons.photo_library, color: Colors.grey, size: 200.0),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              "No Posts",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ));
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      postsList.forEach((eachPost) {
        gridTiles.add(GridTile(child: PostTile(eachPost)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: <Widget>[],
      );
    }
  }

  getAllProfilePosts() async {
    setState(() {
      loading = true;
    });
    QuerySnapshot querySnapshot = await postsReference
        .doc(User1().uid)
        .collection("usersPosts")
        .orderBy("timestamp", descending: true)
        .get();
    setState(() {
      loading = false;
      countPost = querySnapshot.docs.length;
      postsList = querySnapshot.docs
          .map((documentSnapshot) => Post.fromDocument(documentSnapshot))
          .toList();
    });
  }

  createListAndGridPostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
          onPressed: () => setOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == "list"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        )
      ],
    );
  }

  setOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }
}
