//Importing Required Modules
import 'package:letstalk/global_variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Class for Settings of User Account
class UserAccntSettings {
  static setAppSettings(var key, val) async {
    SharedPreferences appSettings = await SharedPreferences.getInstance();
    appSettings.setBool(key, val);
  }

  static setUserSettings(var key, val) async {
    SharedPreferences userSettings = await SharedPreferences.getInstance();
    userSettings.setString(key, val);
  }

  static signOut(var context) {
    setAppSettings('isAuthDone', false);
    setUserSettings('Email', null);
    Navigator.pushReplacementNamed(context, '/auth');
  }

  static deleteAccnt(var context) {
    Navigator.pushReplacementNamed(context, '/auth');
    setAppSettings('isAuthDone', false);
    setUserSettings('Email', null);
    letsChatFS.collection('/UsersData/').doc(email).delete();
  }
}
