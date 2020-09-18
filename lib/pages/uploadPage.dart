import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:image/image.dart' as ImD;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:social_media1/services/database.dart';
import 'package:provider/provider.dart';
import 'package:social_media1/models/user.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File _image;
  bool uploading = false;
  String downloadUrl;
  final picker = ImagePicker();

  TextEditingController desciptionTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

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

  // savePostInfoToFireStore(String url, String location, String descripton) {
  //   _firestore.collection("user posts").add({
  //     "postId": {},
  //     "ownerId": {},
  //     "timestamp": {},
  //     "Likes": {},
  //     "username": {},
  //     "desciption": descripton,
  //     "location": location,
  //     "url": url
  //   }).then((value) => null);
  // }

  controlUploadAndSave(user) async {
    uploading = true;

    await compressingPhoto();
    String downloadUrl = await uploadPhoto(_image);

    DatabaseService(uid: user.uid).updatePostData(
      user.toString(),
      desciptionTextEditingController.text,
      downloadUrl,
      locationTextEditingController.text,
    );
  }

  Future<String> uploadPhoto(mImageFile) async {
    try {
      DatabaseService databaseService = DatabaseService();
      StorageUploadTask mstorageUploadTask = databaseService.storageReference
          .child("post_&postId.jpg")
          .putFile(mImageFile);
      StorageTaskSnapshot storageTaskSnapshot =
          await mstorageUploadTask.onComplete;
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

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
    return StreamBuilder<PostData>(
        stream: DatabaseService(uid: user.uid).postData,
        builder: (context, snapshot) {
          PostData postData = snapshot.data;
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
                      // backgroundImage:
                      //     AssetImage('assets/images/background.jpg'),
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
