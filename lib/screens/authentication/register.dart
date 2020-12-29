//Importing Required Modules
import 'dart:io';

import 'package:letstalk/global_variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Register Page Class
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _regFormKey = GlobalKey<FormState>();
  File _profileImage;
  final picker = ImagePicker();

  String regPasswd, regEmail, errorMsg = ' ';
  bool isError = false, regStatus = false, isImgAction = false;
  var fireAuth = FirebaseAuth.instance;

  //Function to Pick Image from Gallery
  Future getImage() async {
    final pickedFile = await picker.getImage(
        maxHeight: 777,
        maxWidth: 777,
        imageQuality: 77,
        source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
      } else {
        _profileImage = null;
      }
    });
  }

  //Function to Upload Registering User Details in Firestore Database
  Future uploadDetails(var imgName) async {
    Reference usrProfilePicsStorageRef =
        letsChatStorage.ref().child('LetsChatUserProfiles/$imgName');
    await usrProfilePicsStorageRef.putFile(_profileImage);
    usrProfilePicsStorageRef.getDownloadURL().then(
      (fileURL) {
        letsChatFS.collection('/UsersData/').doc(email).set(
          {
            'Username': username,
            'Email': email,
            'Mobile': {'MNo': null, 'Mode': 'Private'},
            'BlockList': [],
            'Profile': fileURL,
          },
        );
      },
    );
  }

  //Function to store some App Settings in Shared Preferences
  setAppSettings(var key, val) async {
    SharedPreferences appSettings = await SharedPreferences.getInstance();
    appSettings.setBool(key, val);
  }

  //Function to store User Details in Shared Preferences
  setUserSettings(var key, val) async {
    SharedPreferences userSettings = await SharedPreferences.getInstance();
    userSettings.setString(key, val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            isImgAction = false;
          });
        },
        child: SingleChildScrollView(
          child: Container(
            child: Form(
              onChanged: () {
                setState(() {
                  isImgAction = false;
                });
              },
              key: _regFormKey,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(45),
                          child: CircleAvatar(
                            radius: 45,
                            child: _profileImage == null
                                ? GestureDetector(
                                    onTap: getImage,
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      color: Colors.black.withOpacity(0.46),
                                      child: Center(
                                        child: Text(
                                          'Upload',
                                        ),
                                      ),
                                    ),
                                  )
                                : isImgAction
                                    ? Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              getImage();
                                              setState(() {
                                                isImgAction = false;
                                              });
                                            },
                                            child: Container(
                                              width: 90,
                                              height: 45,
                                              decoration: BoxDecoration(
                                                color: Colors.green
                                                    .withOpacity(0.11),
                                                border: Border(
                                                  bottom: BorderSide(),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text('\nChange'),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _profileImage = null;
                                                isImgAction = false;
                                              });
                                            },
                                            child: Container(
                                              width: 90,
                                              height: 45,
                                              decoration: BoxDecoration(
                                                color: Colors.red
                                                    .withOpacity(0.11),
                                                border: Border(
                                                  top: BorderSide(),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text('Remove\n'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isImgAction = true;
                                          });
                                        },
                                        child: Container(
                                          height: 90,
                                          width: 90,
                                          color: Colors.transparent,
                                        ),
                                      ),
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage)
                                : AssetImage('assets/images/dummy_user.png'),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 10),
                            child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Enter Username';
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                labelText: "Username",
                                hintText: 'Can\'t be changed later',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                              ),
                              onChanged: (value) {
                                username = value;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Email Can\'t be Empty';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Email",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          isError = false;
                        });
                        regEmail = value;
                      },
                    ),
                  ),
                  isError
                      ? Container(
                          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                          alignment: Alignment.topLeft,
                          child: Text(
                            '$errorMsg',
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.start,
                          ),
                        )
                      : SizedBox(),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: TextFormField(
                      obscureText: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter Password';
                        } else if (value.length < 6) {
                          return 'Enter at least 6 Characters';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Password",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      onChanged: (value) {
                        regPasswd = value;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: !regStatus
                        ? RaisedButton(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Text(
                              "Sign In",
                              textScaleFactor: 2,
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () async {
                              if (_regFormKey.currentState.validate()) {
                                try {
                                  setState(() {
                                    regStatus = true;
                                  });

                                  var userSignin = await fireAuth
                                      .createUserWithEmailAndPassword(
                                    email: regEmail,
                                    password: regPasswd,
                                  );
                                  if (userSignin.additionalUserInfo.isNewUser) {
                                    setAppSettings('isAuthDone', true);
                                    email = regEmail;
                                    setUserSettings('Email', email);

                                    _profileImage != null
                                        ? await uploadDetails(email)
                                        : letsChatFS
                                            .collection('/UsersData/')
                                            .doc(email)
                                            .set({
                                            'Username': username,
                                            'Email': email,
                                            'Mobile': {
                                              'MNo': null,
                                              'Mode': 'Private'
                                            },
                                            'BlockList': [],
                                            'Profile': null,
                                          });

                                    Navigator.pushReplacementNamed(
                                        context, "/home");
                                    setState(() {
                                      regStatus = false;
                                    });
                                  }
                                } catch (err) {
                                  var error = err.toString();
                                  setState(() {
                                    isError = true;
                                    if (error.contains('already') &&
                                        error.contains('another')) {
                                      errorMsg = 'Email Already taken';
                                    } else if (error.contains('badly') &&
                                        error.contains('formatted')) {
                                      errorMsg = 'Enter a valid Email';
                                    }
                                  });
                                  setState(() {
                                    regStatus = false;
                                  });
                                }
                              }
                            },
                          )
                        : CircularProgressIndicator(
                            strokeWidth: 5,
                            backgroundColor: Colors.amber,
                            valueColor: AlwaysStoppedAnimation(
                              Colors.green,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
