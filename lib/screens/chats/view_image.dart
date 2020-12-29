//Importing Required Modules
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:letstalk/global_variables.dart';
import 'package:letstalk/screens/chats/messanger.dart';
import 'package:photo_view/photo_view.dart';

//Globally Declared Variables
String crntImgToView;

//Class to Send Image Page
class SendImagePage extends StatelessWidget {
  Future sendImg() async {
    var docId;
    letsChatFS
        .collection('/UsersData/$email/UserChats/${CrntChat.usrMail}/chats')
        .add(
      {
        'isLiked': false,
        'isMe': true,
        'msg': 'Sending Photo...',
        'isRead': false,
        'time': DateTime.now().toUtc(),
        'type': 'ImgSend',
      },
    ).then((value) {
      docId = value.id;
    });
    Reference usrSentImgStorageRef = letsChatStorage.ref().child(
        'LetsChatUsrSentImgs/$email/${CrntChat.usrMail}/img_${DateTime.now().toUtc()}');
    await usrSentImgStorageRef.putFile(Messanger.imgToSend);
    usrSentImgStorageRef.getDownloadURL().then((imgURL) {
      letsChatFS
          .collection('/UsersData/$email/UserChats/${CrntChat.usrMail}/chats')
          .doc(docId)
          .delete();
      Messanger.messageSender('Image', imgURL);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Send Image'),
        actions: [
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 100),
              child: PhotoView(
                imageProvider: FileImage(Messanger.imgToSend),
              ),
            ),
            Positioned(
              bottom: 14,
              child: Container(
                padding: EdgeInsets.only(left: 20),
                alignment: Alignment.centerLeft,
                width: deviceWidth * 0.77,
                height: 64,
                child: Text(
                  'Sending to ${CrntChat.usrName}',
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 14,
        splashColor: Colors.green,
        child: Icon(
          Icons.send,
        ),
        onPressed: () {
          Navigator.pop(context);
          sendImg();
        },
      ),
    );
  }
}

//Class for View Recieved Image Page
class ViewRecievedImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: PhotoView(
                imageProvider: NetworkImage(crntImgToView),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
