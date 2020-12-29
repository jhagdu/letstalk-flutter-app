//Import Required Modules
import 'dart:io';

import 'package:letstalk/global_variables.dart';

//Class for Current Chat Details
class CrntChat {
  static String usrMail;
  static String usrName;
  static var crntProfile;
  static var lastMsgTime;
  static bool isFav = false;
  static bool isBlocked = false;
}

//Class for Menu in Chat Screen
class ChatMenu {
  static String favourite = 'Favourite/Unfavourite';
  static String delete = 'Delete Chat';

  static List<String> choices = <String>[
    favourite,
    delete,
  ];
}

//Messanger Class - Class which Send/Update Message to both Chatting Users
class Messanger {
  static File imgToSend;

  static messageSender(String msgType, String theMsg) {
    letsChatFS
        .collection('/UsersData/$email/UserChats/${CrntChat.usrMail}/chats')
        .add(
      {
        'isLiked': false,
        'isMe': true,
        'msg': theMsg,
        'isRead': false,
        'time': DateTime.now().toUtc(),
        'type': msgType,
      },
    ).then(
      (value) {
        letsChatFS
            .collection('/UsersData/${CrntChat.usrMail}/UserChats/$email/chats')
            .doc(value.id)
            .set(
          {
            'isLiked': false,
            'isMe': false,
            'msg': theMsg,
            'isRead': true,
            'time': DateTime.now().toUtc(),
            'type': msgType,
          },
        );
        letsChatFS
            .collection('/UsersData/$email/UserChats/')
            .doc(CrntChat.usrMail)
            .update(
          {
            'isNew': false,
            'time': DateTime.now().toUtc(),
          },
        );
        letsChatFS
            .collection('/UsersData/${CrntChat.usrMail}/UserChats/')
            .doc(email)
            .update(
          {
            'isNew': true,
            'time': DateTime.now().toUtc(),
          },
        );
        theMsg = '';
      },
    );
  }
}
