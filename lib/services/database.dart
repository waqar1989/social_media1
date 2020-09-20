import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media1/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media1/models/brew.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference userDataCollection =
      // ignore: deprecated_member_use
      Firestore.instance.collection('userData');

  final CollectionReference postCollection =
      // ignore: deprecated_member_use
      Firestore.instance.collection('postsData');

  final StorageReference storageReference =
      FirebaseStorage.instance.ref().child("Posts Pictures");

  Future updatedUserData(String downloadUrl, String name, String gender,
      String education, String location) async {
    return await userDataCollection.doc(uid).set({
      'downloadUrl': downloadUrl,
      'name': name,
      'gender': gender,
      'education': education,
      'location': location
    });
  }

  Future updatePostData(String userId, String postUrl, String postDescription,
      String postLocation) async {
    return await postCollection.doc(uid).set({
      'userId': userId,
      'postUrl': postUrl,
      'postDescription': postDescription,
      'postLocation': postLocation,
    });
  }

//ProfileData(List) list from snapshot
  List<ProfileData> _brewListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return ProfileData(
          name: doc.data()['name'] ?? 'new user',
          gender: doc.data()['gender'] ?? 'gender',
          education: doc.data()['education'] ?? 'education',
          location: doc.data()['location'] ?? 'location');
    }).toList();
  }
//ProfileData from snapshot

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
        uid: uid,
        downloadUrl: snapshot.data()['downloadUrl'],
        name: snapshot.data()['name'],
        gender: snapshot.data()['gender'],
        education: snapshot.data()['education'],
        location: snapshot.data()['location']);
  }

  PostData _postDataFromSnapshot(DocumentSnapshot snapshot) {
    return PostData(
        uid: uid,
        postUrl: snapshot.data()['postUrl'],
        postDescription: snapshot.data()['postDescription'],
        postLocation: snapshot.data()['postLocation']);
  }

  //get brew stream

  Stream<List<ProfileData>> get profiles {
    return userDataCollection.snapshots().map(_brewListFromSnapshot);
  }

  Stream<UserData> get userData {
    return userDataCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  Stream<PostData> get postData {
    return postCollection.doc(uid).snapshots().map(_postDataFromSnapshot);
  }
}
