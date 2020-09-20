import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media1/models/user.dart';
import 'package:social_media1/services/database.dart';
// import 'package:image_picker/image_picker.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //create user object based on firebase
  User1 _userFormFireBaseUser(User user) {
    return user != null ? User1(uid: user.uid) : null;
  }

//auth change user Stream
  Stream<User1> get user {
    // ignore: deprecated_member_use
    return _auth.onAuthStateChanged.map((_userFormFireBaseUser));
  }

//Anonymously Sign In

  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user;
      return _userFormFireBaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _userFormFireBaseUser(user);
    } catch (e) {
      print(e.toString());
    }
  }

//register with email & password

  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      await DatabaseService(uid: user.uid).updatedUserData(
          'uid', 'new member', 'gender', 'education', 'location');
      return _userFormFireBaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

// signout

  logoutUser() async {
    await _auth.signOut();
  }
}
