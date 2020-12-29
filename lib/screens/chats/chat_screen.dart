//Importing Required Modules
import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letstalk/global_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letstalk/screens/chats/messanger.dart';
import 'package:letstalk/screens/chats/view_image.dart';
import 'package:letstalk/screens/chats/view_locn.dart';

//Chat Screen Class
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _sendMsgField = TextEditingController();
  FocusNode sendMsgFocus;
  bool isAttachPanelOpen = false;

  final imgPicker = ImagePicker();
  Set<Marker> _marker = HashSet<Marker>();
  StreamSubscription<QuerySnapshot> seenStream;

  //Function to Check Weather Current user is Blocked or Not
  _chkBlkd() async {
    var blked = ((await letsChatFS
                .collection('/UsersData/')
                .doc(CrntChat.usrMail)
                .get())['BlockList']
            .contains(email) ||
        (await letsChatFS
                .collection('/UsersData/')
                .doc(email)
                .get())['BlockList']
            .contains(CrntChat.usrMail));
    setState(
      () {
        CrntChat.isBlocked = blked;
      },
    );
  }

  //Function to Set Seen/Read mark on Recieved Messages
  void _setSeen() {
    letsChatFS
        .collection('/UsersData/$email/UserChats/')
        .doc(CrntChat.usrMail)
        .update(
      {
        'isNew': false,
      },
    );

    seenStream = letsChatFS
        .collection('/UsersData/${CrntChat.usrMail}/UserChats/$email/chats/')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen(
      (event) {
        event.docs.every(
          (element) {
            letsChatFS
                .collection(
                    '/UsersData/${CrntChat.usrMail}/UserChats/$email/chats/')
                .doc(element.id)
                .update(
              {
                'isRead': true,
              },
            );
            return true;
          },
        );
      },
    );
  }

  //Function to Pick Image from Gallery or Camera according to user selection
  Future getImage({bool isCam = false}) async {
    final pickedFile = await imgPicker.getImage(
        maxHeight: 777,
        maxWidth: 777,
        imageQuality: 77,
        source: isCam ? ImageSource.camera : ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        Messanger.imgToSend = File(pickedFile.path);
      } else {
        Messanger.imgToSend = null;
      }
    });
  }

  //Function to set markers in Recieved Maps
  void _setMarkers(LatLng point) {
    final String markerIdVal = 'locn_$point';
    setState(() {
      _marker.add(
        Marker(
          markerId: MarkerId(markerIdVal),
          position: point,
        ),
      );
    });
  }

  //Function which return Message Widget according to Message type
  Widget _buildMsg(String theMsg, String msgType, BuildContext context) {
    if (msgType == 'Image') {
      return Expanded(
        child: InkWell(
          onTap: () {
            crntImgToView = theMsg;
            Navigator.of(context).pushNamed('/home/chat/viewrecievedimg');
          },
          child: Container(
            height: deviceWidth * 0.507,
            width: deviceWidth * 0.507,
            color: Colors.black,
            alignment: Alignment.center,
            child: Image(
              image: NetworkImage(theMsg),
            ),
          ),
        ),
      );
    } else if (msgType == 'ImgSend') {
      return Expanded(
        child: Row(
          children: [
            Expanded(
              child: Container(
                //width: deviceWidth * 0.449,
                height: 70,
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Icon(
                      Icons.image,
                      color: Colors.pink,
                      size: 40,
                    ),
                    SizedBox(width: 2),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 70,
                          child: Text(
                            'Photo',
                            style: TextStyle(color: Colors.black),
                            textScaleFactor: 1.4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 70,
                          child: Text(
                            'Sending...',
                            style: TextStyle(color: Colors.black),
                            textScaleFactor: 0.9,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: Container()),
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Icon(
                        Icons.file_upload,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (msgType == 'Location') {
      var reFormatLocn =
          theMsg.replaceAll('[', '').replaceAll(']', '').split(',');
      var locnToMark = [
        double.parse(reFormatLocn[0]),
        double.parse(reFormatLocn[1])
      ];
      return Expanded(
        child: Container(
          height: 143,
          width: deviceWidth * 0.527,
          alignment: Alignment.center,
          child: GoogleMap(
            markers: _marker,
            mapToolbarEnabled: false,
            scrollGesturesEnabled: false,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: false,
            onTap: (point) {
              rcvdLocationPoint = [locnToMark[0], locnToMark[1]];
              Navigator.of(context).pushNamed('/home/chat/viewrcvdlocn');
            },
            onMapCreated: (point) {
              _setMarkers(LatLng(locnToMark[0], locnToMark[1]));
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(locnToMark[0], locnToMark[1]),
              zoom: 14,
            ),
          ),
        ),
      );
    } else {
      return Expanded(
        child: Text(
          theMsg,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }

  //Function to create complete Message Box in Chat
  Widget _buildMessageBox(String theMsg, String date, String time, bool isMe,
      bool isLiked, bool isRead, String msgType, String msgid) {
    final Stack msgBox = Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          margin: isMe
              ? EdgeInsets.only(
                  top: 7.0,
                  bottom: 7.0,
                  left: 111.0,
                )
              : EdgeInsets.only(
                  top: 7.0,
                  bottom: 7.0,
                ),
          padding: EdgeInsets.fromLTRB(14, 10, 14, 10),
          width: deviceWidth * 0.75,
          decoration: BoxDecoration(
            color: isMe ? Colors.amber.withOpacity(0.77) : Colors.white70,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildMsg(theMsg, msgType, context),
              SizedBox(
                width: 14,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  isMe
                      ? Stack(
                          children: [
                            Icon(
                              Icons.check,
                              color: isRead ? Colors.green : Colors.blueGrey,
                            ),
                            Icon(
                              Icons.check,
                              size: 20,
                              color: isRead ? Colors.green : Colors.blueGrey,
                            ),
                          ],
                        )
                      : SizedBox(
                          height: 20,
                        ),
                ],
              ),
            ],
          ),
        ),
        isMe && isLiked
            ? Container(
                margin: EdgeInsets.only(left: 111),
                height: 21,
                width: 40,
                child: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
              )
            : SizedBox(),
      ],
    );

    if (isMe) {
      return msgBox;
    }

    return Row(
      children: <Widget>[
        msgBox,
        IconButton(
          icon: isLiked
              ? Icon(
                  Icons.favorite,
                  color: Colors.red,
                )
              : Icon(Icons.favorite_border),
          iconSize: 30.0,
          color: isLiked ? Theme.of(context).primaryColor : Colors.blueGrey,
          onPressed: () {
            isLiked = isLiked ? false : true;
            letsChatFS
                .collection(
                    '/UsersData/$email/UserChats/${CrntChat.usrMail}/chats/')
                .doc(msgid)
                .update(
              {
                'isLiked': isLiked,
              },
            );
            letsChatFS
                .collection(
                    '/UsersData/${CrntChat.usrMail}/UserChats/$email/chats/')
                .doc(msgid)
                .update(
              {
                'isLiked': isLiked,
              },
            );
          },
        )
      ],
    );
  }

  //Function which returns the Message Composer Widget
  Widget _buildMessageComposer() {
    var msgString;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.0),
      color: Theme.of(context).primaryColor,
      child: !CrntChat.isBlocked
          ? Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.attachment),
                  iconSize: 25.0,
                  onPressed: () {
                    setState(() {
                      isAttachPanelOpen
                          ? isAttachPanelOpen = false
                          : isAttachPanelOpen = true;
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    showCursor: true,
                    focusNode: sendMsgFocus,
                    maxLines: null,
                    minLines: 1,
                    autofocus: false,
                    controller: _sendMsgField,
                    textCapitalization: TextCapitalization.sentences,
                    onTap: () {
                      if (isAttachPanelOpen) {
                        setState(() {
                          isAttachPanelOpen = false;
                        });
                      }
                    },
                    onChanged: (value) {
                      if (isAttachPanelOpen) {
                        setState(() {
                          isAttachPanelOpen = false;
                        });
                      }
                      msgString = value;
                    },
                    decoration: InputDecoration.collapsed(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  iconSize: 25.0,
                  onPressed: () {
                    if (isAttachPanelOpen) {
                      setState(() {
                        isAttachPanelOpen = false;
                      });
                    }
                    if (_sendMsgField.text.isNotEmpty) {
                      _sendMsgField.clear();
                      Messanger.messageSender('Text', msgString);
                      msgString = '';
                    }
                  },
                ),
              ],
            )
          : Container(
              alignment: Alignment.center,
              height: 46,
              child: Text(
                'You are Blocked!',
                textScaleFactor: 1.4,
              ),
            ),
    );
  }

  Widget _attachmentPanel() {
    return Positioned(
      left: 5,
      right: 5,
      bottom: 50,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        height: 111,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () async {
                setState(() {
                  isAttachPanelOpen = false;
                });
                await getImage(isCam: false);
                Messanger.imgToSend != null
                    ? Navigator.pushNamed(context, '/home/chat/sendimage')
                    : print('Canceled');
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.all(Radius.circular(70)),
                    ),
                    child: Icon(
                      Icons.image,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Gallery')
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  isAttachPanelOpen = false;
                });
                await getImage(isCam: true);
                Messanger.imgToSend != null
                    ? Navigator.pushNamed(context, '/home/chat/sendimage')
                    : print('Canceled');
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(70)),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Camera')
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  isAttachPanelOpen = false;
                });
                Navigator.of(context).pushNamed('/home/chat/sendlocn');
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: Colors.lightGreen,
                      borderRadius: BorderRadius.all(Radius.circular(70)),
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Location')
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _chkBlkd();
    _setSeen();
    sendMsgFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    seenStream.cancel();
    sendMsgFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        title: Text(
          '${CrntChat.usrName}',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
        actions: <Widget>[
          PopupMenuButton(
            tooltip: 'Show Menu',
            icon: Icon(
              Icons.more_horiz,
              size: 28,
            ),
            onSelected: (value) {
              if (value == ChatMenu.delete) {
                Navigator.pop(context);
                letsChatFS
                    .collection(
                        '/UsersData/$email/UserChats/${CrntChat.usrMail}/chats')
                    .get()
                    .then(
                  (snapshot) {
                    for (DocumentSnapshot ds in snapshot.docs) {
                      ds.reference.delete();
                    }
                    letsChatFS
                        .collection('/UsersData/$email/UserChats/')
                        .doc(CrntChat.usrMail)
                        .delete();
                  },
                );
              } else if (value == ChatMenu.favourite) {
                letsChatFS
                    .collection('/UsersData/$email/UserChats/')
                    .doc(CrntChat.crntProfile)
                    .update({
                  'isFavourited': CrntChat.isFav ? false : true,
                });
                setState(() {
                  CrntChat.isFav = CrntChat.isFav ? false : true;
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return ChatMenu.choices.map(
                (String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                },
              ).toList();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (isAttachPanelOpen) {
                setState(() {
                  isAttachPanelOpen = false;
                });
              }
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            },
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(bottom: 7),
                    decoration: BoxDecoration(
                      color: Colors.white60,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                      ),
                      child: StreamBuilder(
                        stream: letsChatFS
                            .collection(
                                '/UsersData/$email/UserChats/${CrntChat.usrMail}/chats')
                            .orderBy('time', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container(
                              alignment: Alignment.center,
                              child: CrntChat.isBlocked
                                  ? RaisedButton(
                                      onPressed: () {
                                        letsChatFS
                                            .collection('/UsersData/')
                                            .doc(email)
                                            .update(
                                          {
                                            'BlockList': FieldValue.arrayRemove(
                                                [CrntChat.crntProfile])
                                          },
                                        ).whenComplete(
                                          () async {
                                            await _chkBlkd();
                                          },
                                        );
                                      },
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Start Chatting',
                                          textScaleFactor: 2.1,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Send a Message',
                                          textScaleFactor: 1.1,
                                        )
                                      ],
                                    ),
                            );
                          } else if (snapshot.data.documents.length <= 0) {
                            return Container(
                              alignment: Alignment.center,
                              child: CrntChat.isBlocked
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FlatButton(
                                          splashColor: Colors.green,
                                          color: Colors.redAccent,
                                          onPressed: () {
                                            letsChatFS
                                                .collection('/UsersData/')
                                                .doc(email)
                                                .update(
                                              {
                                                'BlockList':
                                                    FieldValue.arrayRemove(
                                                        [CrntChat.crntProfile])
                                              },
                                            ).whenComplete(
                                              () async {
                                                await _chkBlkd();
                                              },
                                            );
                                          },
                                          child: Text('Unblock'),
                                        ),
                                        Text(
                                            'If you have blocked the user you can unblock him!')
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Start Chatting',
                                          textScaleFactor: 2.1,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Send a Message',
                                          textScaleFactor: 1.1,
                                        )
                                      ],
                                    ),
                            );
                          } else {
                            return new ListView.builder(
                              itemCount: snapshot.data.documents.length,
                              reverse: true,
                              padding: EdgeInsets.only(top: 15.0),
                              itemBuilder: (context, index) {
                                DocumentSnapshot ds =
                                    snapshot.data.documents[index];
                                var timestamp = DateTime.parse(
                                    ds.get('time').toDate().toString());
                                return _buildMessageBox(
                                  '${ds.get('msg')}',
                                  '${timestamp.day}/${timestamp.month}',
                                  '${timestamp.hour}:${timestamp.minute}',
                                  ds.get('isMe'),
                                  ds.get('isLiked'),
                                  ds.get('isRead'),
                                  ds.get('type'),
                                  ds.id,
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
                _buildMessageComposer(),
              ],
            ),
          ),
          isAttachPanelOpen ? _attachmentPanel() : SizedBox(),
        ],
      ),
    );
  }
}
