import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media1/Widgets/progressWidget.dart';
import 'package:social_media1/models/user.dart';
import 'package:social_media1/services/auth.dart';
import 'package:social_media1/services/database.dart';
import 'package:social_media1/shared/loading.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController profileNameTextEditingController =
      TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  TextEditingController genderTextEditingController = TextEditingController();
  TextEditingController locationEditingController = TextEditingController();
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;

  bool _profileNameValid = true;
  bool _bioValid = true;
  bool _genderValid = true;
  bool _locationValid = true;

  //Declare a GlobalKey
  // GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//Assing this key to the scaffold

  File _image;

  String _currentName;
  String _currentGender;
  String _currentEducation;
  String _currentLocation;

  @override
  Widget build(BuildContext context) {
    Future getImage() async {
      // ignore: deprecated_member_use
      var image = await ImagePicker.pickImage(
        source: ImageSource.camera,
      );

      setState(() {
        _image = image;
        print('Image Path $_image');
      });
    }

    Future<String> upload(BuildContext context) async {
      String fileName = basename(_image.path);
      StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
      print(downloadUrl);
    }

    final user = Provider.of<User1>(context);
    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            circularProgress();
          } else {
            UserData userData = snapshot.data;
            return Scaffold(
                key: _scaffoldGlobalKey,
                backgroundColor: Colors.black,
                appBar: AppBar(
                  centerTitle: true,
                  backgroundColor: Colors.black,
                  iconTheme: IconThemeData(color: Colors.white),
                  title: Text(
                    "Edit Profile",
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: [
                    IconButton(
                        icon: Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        onPressed: () => Navigator.pop(context))
                  ],
                ),
                body: loading
                    ? circularProgress()
                    : ListView(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 15.0, bottom: 7.0),
                            child: GestureDetector(
                              onTap: getImage,
                              child: CircleAvatar(
                                radius: 52.0,
                                backgroundColor: Colors.grey,
                                child: ClipOval(
                                    child: (_image != null)
                                        ? Image.file(_image, fit: BoxFit.fill)
                                        : Image.network(userData.downloadUrl)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: <Widget>[
                                createProfileNameTextFormField(userData),
                                createGenderTextFormField(userData),
                                createBioTextFormField(userData),
                                createLocationTextFormField(userData)
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 29, left: 130.0, right: 130.0),
                            child: RaisedButton(
                              color: Colors.grey[300],
                              onPressed: () {
                                setState(() async {
                                  String downloadUrl = await upload(context);
                                  print(downloadUrl);
                                  await DatabaseService(uid: user.uid)
                                      .updatedUserData(
                                          downloadUrl ?? "",
                                          _currentName ?? userData.name,
                                          _currentGender ?? userData.gender,
                                          _currentEducation ??
                                              userData.education,
                                          _currentLocation ??
                                              userData.location);
                                  Navigator.pop(context);
                                });
                              },
                              child: Text(
                                "Update",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16.0),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10, left: 170.0, right: 170.0),
                            child: RaisedButton(
                              color: Colors.red,
                              onPressed: logoutUser,
                              child: Text(
                                "Logout",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.0),
                              ),
                            ),
                          )
                        ],
                      ));
          }
        });
  }

  logoutUser() {
    AuthService authService = new AuthService();
    authService.logoutUser();
  }

  updateUserData(user) {
    setState(() {
      profileNameTextEditingController.text.trim().length < 3 ||
              profileNameTextEditingController.text.isEmpty
          ? _profileNameValid = false
          : _profileNameValid = true;
    });
    // if (_bioValid && _profileNameValid) {}

    // SnackBar snackBar = SnackBar(
    //   content: Text("Profile has been updated Successfully."),
    // );
    // _scaffoldGlobalKey.currentState.showSnackBar(snackbar)
  }

  Column createProfileNameTextFormField(userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Profile Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextFormField(
          style: TextStyle(color: Colors.white),
          onChanged: (val) => setState(() => _currentName = val),
          decoration: InputDecoration(
              hintText: "Write profile name here..",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              hintStyle: TextStyle(color: Colors.grey),
              errorText:
                  _profileNameValid ? null : "Profile name is very short"),
        )
      ],
    );
  }

  Column createGenderTextFormField(userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Gender",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextFormField(
          style: TextStyle(color: Colors.white),
          onChanged: (val) => setState(() => _currentGender = val),
          decoration: InputDecoration(
              hintText: "Write Gender here.",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              hintStyle: TextStyle(color: Colors.grey),
              errorText: _genderValid ? null : "write correct Gender"),
        )
      ],
    );
  }

  Column createBioTextFormField(userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextFormField(
          style: TextStyle(color: Colors.white),
          onChanged: (val) => setState(() => _currentEducation = val),
          decoration: InputDecoration(
              hintText: "Write Education & Brief Intro here..",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              hintStyle: TextStyle(color: Colors.grey),
              errorText: _bioValid ? null : "Profile name is very short"),
        )
      ],
    );
  }

  Column createLocationTextFormField(userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Location",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextFormField(
          style: TextStyle(color: Colors.white),
          onChanged: (val) => setState(() => _currentLocation = val),
          decoration: InputDecoration(
              hintText: "Write Location..",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              hintStyle: TextStyle(color: Colors.grey),
              errorText: _locationValid ? null : "write valid location"),
        )
      ],
    );
  }
}
