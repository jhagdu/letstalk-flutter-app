//Importing Required Modules
import 'package:letstalk/global_variables.dart';
import 'package:letstalk/screens/chats/messanger.dart';
import 'package:letstalk/screens/drawer/recent_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//Favourite Chats Class
class FavouriteChats extends StatefulWidget {
  @override
  _FavouriteChatsState createState() => _FavouriteChatsState();
}

class _FavouriteChatsState extends State<FavouriteChats> {
  final GlobalKey<ScaffoldState> _homeScaffoldKey =
      new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(200, 200, 255, 0.77),
      key: _homeScaffoldKey,
      endDrawer: RecentDrawer(),
      body: StreamBuilder(
        stream: letsChatFS
            .collection('/UsersData/$email/UserChats/')
            .where('isFavourited', isEqualTo: true)
            .snapshots(),
        builder: (context, favChatsSnapshot) {
          if (!favChatsSnapshot.hasData) {
            return NoFavChats();
          } else if (favChatsSnapshot.data.documents.length <= 0) {
            return NoFavChats();
          } else {
            return new ListView.builder(
              itemCount: favChatsSnapshot.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot usrFavouriteChats =
                    favChatsSnapshot.data.documents[index];
                var crrntFavChat = usrFavouriteChats.id;

                return StreamBuilder(
                  stream: letsChatFS
                      .collection(
                          '/UsersData/$email/UserChats/$crrntFavChat/chats/')
                      .orderBy('time')
                      .snapshots(),
                  builder: (context, crntChatSnapshot) {
                    if (!crntChatSnapshot.hasData) {
                      return Text(' ');
                    } else if (crntChatSnapshot.data.documents.length <= 0) {
                      return Text(' ');
                    } else {
                      DocumentSnapshot crrntUsrChatLastMsg =
                          crntChatSnapshot.data.documents.last;
                      var timestamp = DateTime.parse(
                        crrntUsrChatLastMsg.get('time').toDate().toString(),
                      );

                      return GestureDetector(
                        onTap: () async {
                          CrntChat.usrMail = usrFavouriteChats.id;
                          CrntChat.usrName = usrFavouriteChats.get('User');
                          CrntChat.lastMsgTime = usrFavouriteChats.get('time');
                          Navigator.pushNamed(context, '/home/chat');
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(5, 3, 5, 3),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 7.0),
                          decoration: BoxDecoration(
                            color: usrFavouriteChats.get('isNew')
                                ? Color.fromRGBO(0, 255, 0, 0.46)
                                : Color.fromRGBO(100, 200, 255, 0.64),
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  StreamBuilder(
                                    stream: letsChatFS
                                        .collection('/UsersData/')
                                        .where('Email',
                                            isEqualTo: usrFavouriteChats.id)
                                        .limit(1)
                                        .snapshots(),
                                    builder: (context, rcntUsrProfileSnapshot) {
                                      if (!rcntUsrProfileSnapshot.hasData) {
                                        return Text(' ');
                                      } else if (rcntUsrProfileSnapshot
                                              .data.documents.length <=
                                          0) {
                                        return Text(
                                          ' ',
                                        );
                                      } else {
                                        DocumentSnapshot rcntUsrProfile =
                                            rcntUsrProfileSnapshot
                                                .data.documents.last;

                                        var rcntUsrDP =
                                            rcntUsrProfile.get('Profile');

                                        return InkWell(
                                          onTap: () async {
                                            CrntChat.crntProfile =
                                                usrFavouriteChats.id;
                                            CrntChat.usrName =
                                                usrFavouriteChats.get('User');
                                            CrntRcntUsr.profPic =
                                                rcntUsrProfile.get('Profile');
                                            CrntRcntUsr.mobNo =
                                                rcntUsrProfile.get('Mobile');
                                            CrntChat.isFav = usrFavouriteChats
                                                .get('isFavourited');
                                            _homeScaffoldKey.currentState
                                                .openEndDrawer();
                                          },
                                          child: CircleAvatar(
                                            radius: 30.0,
                                            backgroundImage: rcntUsrDP != null
                                                ? NetworkImage(rcntUsrDP)
                                                : AssetImage(
                                                    'assets/images/dummy_user.png'),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  SizedBox(width: 10.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: deviceWidth * 0.49,
                                        child: Text(
                                          usrFavouriteChats.get('User'),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Container(
                                        width: deviceWidth * 0.45,
                                        height: 18,
                                        child: crrntUsrChatLastMsg
                                                    .get('type') ==
                                                'Text'
                                            ? Text(
                                                '${crrntUsrChatLastMsg.get('msg')}',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : Row(children: [
                                                Icon(
                                                  crrntUsrChatLastMsg
                                                              .get('type') ==
                                                          'Image'
                                                      ? Icons.image
                                                      : Icons.location_pin,
                                                  size: 20.0,
                                                  color: Colors.black54,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  crrntUsrChatLastMsg
                                                              .get('type') ==
                                                          'Image'
                                                      ? 'Photo'
                                                      : 'Location',
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    '${timestamp.hour}:${timestamp.minute}',
                                    style: TextStyle(
                                      color: Colors.purple,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  crrntUsrChatLastMsg.get('isMe')
                                      ? Stack(
                                          children: [
                                            Icon(
                                              Icons.check,
                                              color: crrntUsrChatLastMsg
                                                      .get('isRead')
                                                  ? Colors.blue
                                                  : Colors.blueGrey,
                                            ),
                                            Icon(
                                              Icons.check,
                                              size: 20,
                                              color: crrntUsrChatLastMsg
                                                      .get('isRead')
                                                  ? Colors.blue
                                                  : Colors.blueGrey,
                                            ),
                                          ],
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

//Widget Shown if there is no Favourite Chats of a User
class NoFavChats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.bottomCenter,
        width: deviceWidth,
        height: deviceHeight * 0.77,
        decoration: BoxDecoration(
          color: Colors.white70,
          image: DecorationImage(
            image: AssetImage('assets/gifs/stay_connected.gif'),
          ),
        ),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'First Start a Chat',
              textScaleFactor: 1.4,
              style: TextStyle(color: Colors.blueGrey),
            ),
            Text(
              'Then add them to Favourites',
              textScaleFactor: 1.2,
              style: TextStyle(color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }
}
