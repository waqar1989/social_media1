import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media1/Widgets/progressWidget.dart';
import 'package:social_media1/models/user.dart';
import 'package:social_media1/services/database.dart';
import 'package:provider/provider.dart';

class Post extends StatefulWidget {
  final User1 user;
  final String postId;
  final String ownerId;
  // final String timestamp;
  final dynamic likes;
  final String username;
  final String desciption;
  final String location;
  final String url;

  Post(
      {this.user,
      this.postId,
      this.ownerId,
      // this.timestamp,
      this.likes,
      this.username,
      this.desciption,
      this.location,
      this.url});

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postId: documentSnapshot.data()["postId"],
      ownerId: documentSnapshot.data()["ownerId"],
      // timestamp: documentSnapshot.data()["timestamp"],
      likes: documentSnapshot.data()["likes"],
      username: documentSnapshot.data()["username"],
      desciption: documentSnapshot.data()["desciption"],
      location: documentSnapshot.data()["location"],
      url: documentSnapshot.data()["url"],
    );
  }
  int getTotalNumberOfLikes(likes) {
    if (likes == null) {
      return 0;
    }
    int counter = 0;
    likes.values.forEach((eachValue) {
      if (eachValue == true) {
        counter = counter + 1;
      }
    });
    return counter;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      likes: this.likes,
      username: this.username,
      desciption: this.desciption,
      location: this.location,
      url: this.url,
      likeCount: getTotalNumberOfLikes(this.likes));
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  Map likes;
  final String username;
  final String desciption;
  final String location;
  final String url;
  int likeCount;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserId = User1().uid;

  _PostState({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.desciption,
    this.location,
    this.url,
    this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User1>(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          createPostHead(user),
          createPostPicture(),
          createPostFooter(),
        ],
      ),
    );
  }

  createPostHead(user) {
    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: widget.user.uid).userData,
        builder: (context, snapshot) {
          UserData userData = snapshot.data;
          if (!snapshot.hasData) {
            return circularProgress();
          }
          bool isPostOwner = widget.user.uid == ownerId;

          return ListTile(
            leading: CircleAvatar(
                backgroundImage: NetworkImage(userData.downloadUrl)),
            title: GestureDetector(
              onTap: () => print("Show Profile"),
              child: Text(
                "username",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(
              location,
              style: TextStyle(color: Colors.white),
            ),
            trailing: isPostOwner
                ? IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () => print("deleted"))
                : Text(""),
          );
        });
  }

  createPostPicture() {
    return GestureDetector(
      onDoubleTap: () => print("post Liked"),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(url),
        ],
      ),
    );
  }

  createPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: () => print("liked post"),
              child: Icon(
                Icons.favorite, color: Colors.grey,
                // isLiked ? Icons.favorite : Icons.favorite_border,
                // size: 28.0,
                // color: Colors.pink,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "username",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(desciption,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        )
      ],
    );
  }
}
