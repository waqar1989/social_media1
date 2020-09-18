import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_media1/services/auth.dart';
import 'package:social_media1/shared/constant.dart';
import 'package:social_media1/shared/loading.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String email = '';
  String password = '';
  String error = '';

  final _auth = AuthService();
  var currentUser;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final _formkey = GlobalKey<FormState>();
  bool loading = false;
  void signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Signed Out");
  }

  // signInWithGoogle() async {
  //   final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  //   final GoogleSignInAuthentication googleSignInAuthentication =
  //       await googleSignInAccount.authentication;

  //   final AuthCredential credential = GoogleAuthProvider.credential(
  //     accessToken: googleSignInAuthentication.accessToken,
  //     idToken: googleSignInAuthentication.idToken,
  //   );
  // }

  // signInFun() {
  //   currentUser = _auth
  //       .signInWithEmailAndPassword(email: email, password: password)
  //       .then((firebaseUser) {
  //     Navigator.pushNamed(context, '/homepage');
  //   }).catchError((e) {
  //     print(e);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: loading
          ? Loading()
          : Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                title: Text(
                  "SIGN IN",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              body: SingleChildScrollView(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration:
                              textInputBorder.copyWith(hintText: 'Email'),
                          validator: (value) =>
                              value.length < 6 ? 'Enter an email' : null,
                          onChanged: (value) => {email = value},
                        ),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration:
                              textInputBorder.copyWith(hintText: 'Password'),
                          validator: (value) => value.length < 6
                              ? 'Enter a password 6+ char long'
                              : null,
                          onChanged: (value) => {password = value},
                          obscureText: true,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        new GestureDetector(
                          onTap: () async {
                            if (_formkey.currentState.validate()) {
                              dynamic result = await _auth
                                  .signInWithEmailAndPassword(email, password);
                              if (result == null) {
                                setState(() => error =
                                    'could not sign in with those credentials');
                              }
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            decoration: new BoxDecoration(
                                gradient: new LinearGradient(
                                  colors: [
                                    Color(0xff007EF4),
                                    Color(0xff2A75BC)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30)),
                            child: Text(
                              "Sign IN ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.0),
                        Text(
                          error,
                          style: TextStyle(color: Colors.red, fontSize: 14.0),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        new GestureDetector(
                          onTap: () {
                            print("i am not programmed yet!");
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            decoration: new BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30)),
                            child: Text(
                              "Sign In with Google ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new GestureDetector(
                              onTap: () {
                                widget.toggleView();
                              },
                              child: new Text(
                                "Don't have account?",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 15),
                              ),
                            ),
                            new GestureDetector(
                              onTap: () {
                                widget.toggleView();
                              },
                              child: new Text(
                                "Register now",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 15),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
