//Importing Required Modules
import 'package:letstalk/global_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letstalk/screens/chats/messanger.dart';

//Globally Declared Variables
bool isSearching = false;

//Class for User Search Widget
class SearchUser extends StatefulWidget {
  @override
  _SearchUserState createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  String searchFor;
  double numOfUsersFound = 1.0;
  var srhBoxlnth;

  @override
  void initState() {
    setState(() {
      searchFor = ' ';
    });
    super.initState();
  }

  @override
  void setState(fn) {
    srhBoxlnth = numOfUsersFound;
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white38,
              border: Border.all(width: 1.5, color: Colors.blue),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            margin: EdgeInsets.fromLTRB(10, 10, 10, 3),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration.collapsed(
                hintText: 'Search by Username',
              ),
              onChanged: (value) {
                setState(() {
                  searchFor = value;
                });
              },
              onSubmitted: (value) {
                setState(() {
                  searchFor = value;
                });
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: deviceWidth * 0.9,
            decoration: BoxDecoration(
              color: Colors.white38,
              border: Border.all(width: 1.5, color: Colors.blue),
            ),
            margin: EdgeInsets.fromLTRB(10, 3, 10, 0),
            height: 60 * srhBoxlnth,
            child: StreamBuilder(
              stream: letsChatFS
                  .collection('/UsersData/')
                  .where('Username', isEqualTo: '$searchFor')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    child: Text(
                      'No User Found',
                      textScaleFactor: 1.7,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (snapshot.data.documents.length <= 0) {
                  return Container(
                    child: Text(
                      'No User Found',
                      textScaleFactor: 1.7,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot allUsrsData =
                          snapshot.data.documents[index];
                      numOfUsersFound = snapshot.data.documents.length + 0.1;
                      return GestureDetector(
                        onTap: () async {
                          CrntChat.usrMail = allUsrsData.get('Email');
                          CrntChat.usrName = allUsrsData.get('Username');
                          letsChatFS
                              .collection('/UsersData/$email/UserChats/')
                              .doc(CrntChat.usrMail)
                              .set({
                            'isNew': false,
                            'isFavourited': false,
                            'time': DateTime.now().toUtc(),
                            'User': (await letsChatFS
                                .collection('/UsersData/')
                                .doc(CrntChat.usrMail)
                                .get())['Username'],
                          });
                          letsChatFS
                              .collection(
                                  '/UsersData/${CrntChat.usrMail}/UserChats/')
                              .doc(email)
                              .set({
                            'isNew': false,
                            'isFavourited': false,
                            'time': DateTime.now().toUtc(),
                            'User': username,
                          });
                          Navigator.pushNamed(context, '/home/chat');
                          isSearching = false;
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              top: 5.0, bottom: 5.0, right: 15.0, left: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 25.0,
                                    backgroundImage:
                                        allUsrsData.get('Profile') != null
                                            ? NetworkImage(
                                                allUsrsData.get('Profile'),
                                              )
                                            : AssetImage(
                                                'assets/images/dummy_user.png'),
                                  ),
                                  SizedBox(width: 10.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: deviceWidth * 0.49,
                                        child: Text(
                                          allUsrsData.get('Username'),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Container(
                                        width: deviceWidth * 0.49,
                                        height: 18,
                                        child: Text(
                                          '${allUsrsData.get('Email')}',
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
