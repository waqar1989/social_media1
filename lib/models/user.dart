class User1 {
  final String uid;

  User1({this.uid});
}

class UserData {
  final String uid;
  final String name;
  final String gender;
  final String education;
  final String location;

  UserData({this.uid, this.name, this.gender, this.education, this.location});
}

class PostData {
  final String uid;
  final String postUrl;
  final String postDescription;
  final String postLocation;

  PostData({this.uid, this.postUrl, this.postDescription, this.postLocation});
}
