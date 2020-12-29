//Importing Required Modules
import 'dart:io';

import 'package:letstalk/global_variables.dart';
import 'package:letstalk/screens/other/user_accnt_stng.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';

//Class for Profile Pic and Mobile No. of Logged In User
class TheUser {
  static var profPic;
  static File newProfPic;
  static var mobNo;
}

//Class for Drawer which Shows Profile of Logged In User
class UserDrawer extends StatefulWidget {
  @override
  _UserDrawerState createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  final imgPicker = ImagePicker();
  File _newProfilePic;
  bool isImgAction = false;

  //Function to pick Image from Gallery
  Future getImage() async {
    final pickedFile = await imgPicker.getImage(
        maxHeight: 777,
        maxWidth: 777,
        imageQuality: 77,
        source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _newProfilePic = File(pickedFile.path);
        TheUser.newProfPic = _newProfilePic;
      } else {
        _newProfilePic = null;
      }
    });
  }

  //Function to change Profile Pic of User
  Future uploadProfile(var imgName) async {
    Reference usrProfilePicsStorageRef =
        letsChatStorage.ref().child('LetsChatUserProfiles/$imgName');
    await usrProfilePicsStorageRef.putFile(_newProfilePic);
    usrProfilePicsStorageRef.getDownloadURL().then((fileURL) {
      letsChatFS.collection('/UsersData/').doc(email).update({
        'Profile': fileURL,
      });
    });
  }

  //Function to set Profile Pic accordingly
  getMyProfPic() {
    if (TheUser.newProfPic != null) {
      return FileImage(TheUser.newProfPic);
    } else {
      if (TheUser.profPic != null) {
        return NetworkImage(TheUser.profPic);
      } else {
        return AssetImage('assets/images/dummy_user.png');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Container(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: deviceHeight * 0.38,
                    width: deviceWidth,
                    child: GFAvatar(
                      shape: GFAvatarShape.square,
                      backgroundImage: getMyProfPic(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    child: IconButton(
                      tooltip: 'Change/Remove',
                      icon: Icon(
                        isImgAction ? Icons.close : Icons.edit,
                        color: Colors.black,
                      ),
                      iconSize: 30,
                      onPressed: () {
                        setState(() {
                          isImgAction
                              ? isImgAction = false
                              : isImgAction = true;
                        });
                      },
                    ),
                  ),
                  isImgAction
                      ? Positioned(
                          bottom: 5,
                          left: 5,
                          child: Container(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await getImage();
                                    _newProfilePic != null
                                        ? uploadProfile(email)
                                        : print('Canceled');
                                    setState(() {
                                      isImgAction = false;
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    width: deviceWidth * 0.5,
                                    color: Colors.green.withOpacity(0.46),
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.change_history,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Change Profile",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.1),
                                GestureDetector(
                                  onTap: () {
                                    _newProfilePic = null;
                                    TheUser.newProfPic = null;
                                    TheUser.profPic = null;
                                    letsChatFS
                                        .collection('/UsersData/')
                                        .doc(email)
                                        .update({
                                      'Profile': null,
                                    });
                                    setState(() {
                                      isImgAction = false;
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    width: deviceWidth * 0.5,
                                    color: Colors.red.withOpacity(0.46),
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Remove Profile",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox()
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.fromLTRB(15, 21, 10, 7),
                height: 50,
                width: deviceWidth,
                child: Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: Colors.green,
                    ),
                    SizedBox(
                      width: 14,
                    ),
                    Container(
                      width: deviceWidth * 0.49,
                      child: Text(
                        '$username',
                        textScaleFactor: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.fromLTRB(15, 7, 10, 7),
                height: 50,
                width: deviceWidth,
                child: Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 14,
                    ),
                    Container(
                      width: deviceWidth * 0.49,
                      child: Text(
                        '$email',
                        textScaleFactor: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.fromLTRB(15, 7, 10, 7),
                height: 50,
                width: deviceWidth,
                child: TheUser.mobNo['MNo'] != null
                    ? Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.cyan,
                          ),
                          SizedBox(
                            width: 14,
                          ),
                          Text(
                            '${TheUser.mobNo['MNo']}',
                            textScaleFactor: 1.5,
                          ),
                          Expanded(
                            child: SizedBox(),
                          ),
                          SizedBox(
                            width: 14,
                          ),
                          IconButton(
                              tooltip: TheUser.mobNo['Mode'] == 'Public'
                                  ? 'Make Private'
                                  : 'Make Public',
                              icon: Icon(
                                TheUser.mobNo['Mode'] == 'Public'
                                    ? Icons.public
                                    : Icons.public_off,
                                color: TheUser.mobNo['Mode'] == 'Public'
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              onPressed: () {
                                setState(() {
                                  TheUser.mobNo['Mode'] == 'Private'
                                      ? TheUser.mobNo['Mode'] = 'Public'
                                      : TheUser.mobNo['Mode'] = 'Private';
                                });
                                letsChatFS
                                    .collection('/UsersData/')
                                    .doc(email)
                                    .update({
                                  'Mobile.Mode': TheUser.mobNo['Mode'],
                                });
                              }),
                          SizedBox(
                            width: 14,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.cyan,
                          ),
                          SizedBox(
                            width: 14,
                          ),
                          Text(
                            'Not Updated',
                            textScaleFactor: 1.5,
                          ),
                        ],
                      ),
              ),
              Expanded(child: SizedBox()),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.fromLTRB(15, 5, 10, 5),
                  height: 50,
                  width: deviceWidth,
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(
                        width: 14,
                      ),
                      Text(
                        'Settings',
                        textScaleFactor: 1.5,
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  UserAccntSettings.signOut(context);
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.fromLTRB(15, 5, 10, 10),
                  height: 50,
                  width: deviceWidth,
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      SizedBox(
                        width: 14,
                      ),
                      Text(
                        'Sign Out',
                        textScaleFactor: 1.5,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
