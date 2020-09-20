import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:image/image.dart' as ImD;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:social_media1/Widgets/progressWidget.dart';
import 'package:social_media1/screens/home/Homepage.dart';
import 'package:social_media1/services/database.dart';
import 'package:provider/provider.dart';
import 'package:social_media1/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UploadPage extends StatefulWidget {
  final User1 user;
  UploadPage({this.user});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File _image;
  bool uploading = false;
  String postId = User1().uid;

  String downloadUrl;
  final picker = ImagePicker();

  TextEditingController desciptionTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  get _platform => null;
  Future addImageFromGallery() async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, maxHeight: 680, maxWidth: 970);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future addImageFromCamera() async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
        source: ImageSource.camera, maxHeight: 680, maxWidth: 970);

    setState(() {
      this._image = File(pickedFile.path);
    });
  }

  takeImage(mContext) {
    return showDialog(
      context: mContext,
      builder: (context) {
        return SimpleDialog(
            backgroundColor: Colors.black,
            title: Text(
              "New Post",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            children: [
              SimpleDialogOption(
                child: Text(
                  "Capture Image with Camera",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: addImageFromCamera,
              ),
              SimpleDialogOption(
                child: Text(
                  "Capture Image from Gallery",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: addImageFromGallery,
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ]);
      },
    );
  }

  displayScreen(user) {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, color: Colors.grey, size: 200),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
                onPressed: () => takeImage(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.0),
                ),
                child: Text(
                  'Upload Image',
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
                color: Colors.green),
          ),
        ],
      ),
    );
  }

  removePage() {
    locationTextEditingController.clear();
    desciptionTextEditingController.clear();
    setState(() {
      _image = null;
    });
  }

  Future<Directory> getTemporaryDirectory() async {
    final String path = await _platform.getTemporaryPath();
    if (path == null) {
      return null;
    }
    return Directory(path);
  }

  compressingPhoto() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(_image.readAsBytesSync());
    final compressedImageFile = File('$path/image.jpg')
      ..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 90));
    setState(() {
      _image = compressedImageFile;
    });
  }

  dynamic currentTime = DateTime.now();

  savePostInfoToFireStore(String url, String location, String descripton) {
    postsReference
        .doc(widget.user.uid)
        .collection("usersPosts")
        .doc(postId)
        .set({
      "postId": 'postId',
      "ownerId": widget.user.uid,
      "timestamp": currentTime,
      "likes": {},
      "username": {},
      "desciption": descripton,
      "location": location,
      "url": url
    });
  }

  controlUploadAndSave(user) async {
    setState(() {
      uploading = true;
    });

    // await compressingPhoto();
    String downloadUrl = await uploadPhoto(_image);
    print(user.uid);

    savePostInfoToFireStore(downloadUrl, locationTextEditingController.text,
        desciptionTextEditingController.text);

    locationTextEditingController.clear();
    desciptionTextEditingController.clear();

    setState(() {
      _image = null;
      uploading = false;
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    StorageUploadTask mstorageUploadTask =
        storageReference.child("post_$postId.jpg").putFile(_image);
    StorageTaskSnapshot storageTaskSnapshot =
        await mstorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Future upload(BuildContext context) async {
  //   StorageReference firebaseStorageRef =
  //       FirebaseStorage.instance.ref().child(_image.path);
  //   StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
  //   StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  //   String downloadUrl = await taskSnapshot.ref.getDownloadURL();
  //   return downloadUrl;
  //   setState(() {
  //     print("Profile Picture Uploaded");
  //   });
  // }

  getUserCurrentLocation() async {
    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mPlaceMark = placemarks[0];
    String completeAddressinfo =
        '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, ${mPlaceMark.subLocality} ${mPlaceMark.locality}, ${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, ${mPlaceMark.postalCode} ${mPlaceMark.country}';
    String speceficAddress = '${mPlaceMark.locality}, ${mPlaceMark.country}';
    locationTextEditingController.text = speceficAddress;
  }

  displayUploadFormScreen(user) {
    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          UserData userData = snapshot.data;
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: removePage),
              title: Text(
                "New Post",
                style: TextStyle(
                    fontSize: 24.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              actions: [
                FlatButton(
                  onPressed: () async {
                    uploading ? null : controlUploadAndSave(user);
                  },
                  child: Text(
                    "Share",
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                )
              ],
            ),
            body: ListView(
              children: [
                uploading ? linearProgress() : Text(""),
                Container(
                  height: 230.0,
                  width: 230.0,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(_image), fit: BoxFit.cover)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12.0),
                ),
                ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(userData.downloadUrl),
                    ),
                    title: Container(
                        width: 250.0,
                        child: TextField(
                            style: TextStyle(color: Colors.white),
                            controller: desciptionTextEditingController,
                            decoration: InputDecoration(
                                hintText: "share your ideas here",
                                hintStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none)))),
                Divider(),
                ListTile(
                    leading: Icon(Icons.person_pin_circle,
                        color: Colors.white, size: 36),
                    title: Container(
                        width: 250.0,
                        child: TextField(
                            style: TextStyle(color: Colors.white),
                            controller: locationTextEditingController,
                            decoration: InputDecoration(
                                hintText: "share your location here",
                                hintStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none)))),
                Container(
                  alignment: Alignment.center,
                  height: 110,
                  width: 220,
                  child: RaisedButton.icon(
                    color: Colors.green,
                    onPressed: getUserCurrentLocation,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.0)),
                    icon: Icon(
                      Icons.location_on,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Set my current location",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User1>(context);
    return _image == null ? displayScreen(user) : displayUploadFormScreen(user);
  }
}
