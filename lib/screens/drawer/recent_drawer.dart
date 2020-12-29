//Importing Required Modules
import 'package:letstalk/global_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:letstalk/screens/chats/messanger.dart';

//Class for Profile Pic and Mobile No. of Selected Recent User
class CrntRcntUsr {
  static var profPic;
  static var mobNo;
}

//Class for Drawer of Recent Chats
class RecentDrawer extends StatefulWidget {
  @override
  _RecentDrawerState createState() => _RecentDrawerState();
}

class _RecentDrawerState extends State<RecentDrawer> {
  bool isThisUsrBlkd = false;

  //Function to get Block/Unblock Status
  getBlkStatus() async {
    var isBlkd = (await letsChatFS
            .collection('/UsersData/')
            .doc(email)
            .get())['BlockList']
        .contains(CrntChat.crntProfile);
    setState(() {
      isThisUsrBlkd = isBlkd;
    });
  }

  @override
  void initState() {
    getBlkStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: deviceWidth * 0.7,
      child: Drawer(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                  width: deviceWidth * 0.7,
                  height: deviceHeight * 0.35,
                  child: GFAvatar(
                    shape: GFAvatarShape.square,
                    backgroundImage: CrntRcntUsr.profPic != null
                        ? NetworkImage(CrntRcntUsr.profPic)
                        : AssetImage('assets/images/dummy_user.png'),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.fromLTRB(15, 10, 10, 0),
                  height: 50,
                  width: deviceWidth,
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_people,
                        color: Colors.green,
                      ),
                      SizedBox(
                        width: 14,
                      ),
                      Container(
                        width: deviceWidth * 0.46,
                        child: Text(
                          '${CrntChat.usrName}',
                          overflow: TextOverflow.ellipsis,
                          textScaleFactor: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                CrntRcntUsr.mobNo['MNo'] != null &&
                        CrntRcntUsr.mobNo['Mode'] == 'Public'
                    ? Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(15, 10, 10, 0),
                        height: 50,
                        width: deviceWidth,
                        child: Row(
                          children: [
                            Icon(
                              Icons.phone,
                              color: Colors.cyan,
                            ),
                            SizedBox(
                              width: 14,
                            ),
                            Text(
                              '${CrntRcntUsr.mobNo['MNo']}',
                              textScaleFactor: 1.5,
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                GestureDetector(
                  onTap: () {
                    letsChatFS
                        .collection('/UsersData/$email/UserChats/')
                        .doc(CrntChat.crntProfile)
                        .update({
                      'isFavourited': CrntChat.isFav ? false : true,
                    });
                    setState(() {
                      CrntChat.isFav = CrntChat.isFav ? false : true;
                    });
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.fromLTRB(15, 10, 10, 0),
                    height: 50,
                    width: deviceWidth,
                    child: Row(
                      children: [
                        CrntChat.isFav
                            ? Icon(Icons.star_border)
                            : Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                        SizedBox(
                          width: 14,
                        ),
                        CrntChat.isFav
                            ? Container(
                                width: deviceWidth * 0.5,
                                child: Text(
                                  'Remove from Favourites',
                                  textScaleFactor: 1.4,
                                  overflow: TextOverflow.clip,
                                ))
                            : Container(
                                child: Text(
                                  'Add to Favourites',
                                  textScaleFactor: 1.4,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (CrntChat.isBlocked) {
                        isThisUsrBlkd = false;
                        CrntChat.isBlocked = false;
                        letsChatFS.collection('/UsersData/').doc(email).update(
                          {
                            'BlockList':
                                FieldValue.arrayRemove([CrntChat.crntProfile])
                          },
                        );
                      } else {
                        isThisUsrBlkd = true;
                        CrntChat.isBlocked = true;
                        letsChatFS.collection('/UsersData/').doc(email).update(
                          {
                            'BlockList':
                                FieldValue.arrayUnion([CrntChat.crntProfile])
                          },
                        );
                      }
                    });
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.fromLTRB(15, 10, 10, 0),
                    height: 50,
                    width: deviceWidth,
                    child: Row(
                      children: [
                        Icon(
                          Icons.block,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 14,
                        ),
                        Text(
                          '${isThisUsrBlkd ? 'Unblock User' : 'Block User'}',
                          textScaleFactor: 1.5,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    letsChatFS
                        .collection(
                            '/UsersData/$email/UserChats/${CrntChat.crntProfile}/chats')
                        .get()
                        .then(
                      (snapshot) {
                        for (DocumentSnapshot ds in snapshot.docs) {
                          ds.reference.delete();
                        }
                        letsChatFS
                            .collection('/UsersData/$email/UserChats/')
                            .doc(CrntChat.crntProfile)
                            .delete();
                      },
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.fromLTRB(15, 10, 10, 0),
                    height: 50,
                    width: deviceWidth,
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 14,
                        ),
                        Text(
                          'Delete Chat',
                          textScaleFactor: 1.5,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
