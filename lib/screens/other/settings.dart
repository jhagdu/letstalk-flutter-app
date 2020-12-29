//Importing Required Modules
import 'package:flutter/services.dart';
import 'package:letstalk/global_variables.dart';
import 'package:letstalk/screens/drawer/user_drawer.dart';
import 'package:letstalk/screens/other/user_accnt_stng.dart';
import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';

//Settings Page Class
class AppSettings extends StatefulWidget {
  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings>
    with TickerProviderStateMixin {
  bool acntDeleteConfirm = false,
      isUpdatingNo = false,
      isDelNo = false,
      isNewMobNoPublic = false;
  var newMobNo;

  //Snack Bar to Show when Mobile Number is Updated
  final mobUpdateSnackBar = SnackBar(
    content: Text('Mobile Number Updated!'),
    duration: Duration(seconds: 1),
  );

  //Snack Bar to Show when Mobile Number is Deleted
  final mobRmvSnackBar = SnackBar(
    content: Text('Mobile Number Removed!'),
    duration: Duration(seconds: 1),
  );

  //Widget for Mobile Settings
  Widget mobileSettings() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Text(
                'Mobile Number',
                textScaleFactor: 1.5,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              isUpdatingNo = true;
              isDelNo = false;
              acntDeleteConfirm = false;
            });
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 7),
            padding: EdgeInsets.fromLTRB(14, 10, 10, 7),
            child: Row(
              children: [
                Icon(
                  Icons.phone_android,
                  color: Colors.green,
                ),
                SizedBox(width: 10),
                Text(
                  'Update Mobile No.',
                  textScaleFactor: 1.5,
                ),
              ],
            ),
          ),
        ),
        AnimatedSizeAndFade.showHide(
          vsync: this,
          show: isUpdatingNo,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(7, 0, 7, 7),
                        child: TextField(
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "Enter New Mob No",
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
                            newMobNo = value;
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Switch(
                            value: isNewMobNoPublic,
                            onChanged: (value) {
                              setState(() {
                                isNewMobNoPublic
                                    ? isNewMobNoPublic = false
                                    : isNewMobNoPublic = true;
                              });
                            },
                          ),
                          isNewMobNoPublic ? Text('Public') : Text('Private'),
                          SizedBox(height: 7),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FlatButton(
                      child: Text('Update'),
                      splashColor: Colors.red,
                      onPressed: () {
                        letsChatFS.collection('/UsersData/').doc(email).update({
                          'Mobile.MNo': newMobNo,
                          'Mobile.Mode':
                              isNewMobNoPublic ? 'Public' : 'Private',
                        });
                        setState(() {
                          isUpdatingNo = false;
                          TheUser.mobNo['MNo'] = newMobNo;
                          TheUser.mobNo['Mode'] =
                              isNewMobNoPublic ? 'Public' : 'Private';
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(mobUpdateSnackBar);
                      },
                    ),
                    FlatButton(
                      child: Text('Cancel'),
                      splashColor: Colors.green,
                      onPressed: () {
                        setState(() {
                          isUpdatingNo = false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        TheUser.mobNo['MNo'] != null
            ? Container(
                margin: EdgeInsets.symmetric(vertical: 7),
                padding: EdgeInsets.fromLTRB(14, 10, 10, 0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isDelNo = true;
                      isUpdatingNo = false;
                      acntDeleteConfirm = false;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Remove Mobile No.',
                        textScaleFactor: 1.5,
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(),
        AnimatedSizeAndFade.showHide(
          vsync: this,
          show: isDelNo,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are You Sure?',
                  textScaleFactor: 1.4,
                ),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FlatButton(
                      child: Text('Remove'),
                      splashColor: Colors.red,
                      onPressed: () {
                        letsChatFS.collection('/UsersData/').doc(email).update(
                            {'Mobile.MNo': null, 'Mobile.Mode': 'Private'});
                        setState(() {
                          isDelNo = false;
                          TheUser.mobNo['MNo'] = null;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(mobRmvSnackBar);
                      },
                    ),
                    FlatButton(
                      child: Text('Cancel'),
                      splashColor: Colors.green,
                      onPressed: () {
                        setState(() {
                          isDelNo = false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(7, 30, 7, 7),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
        ),
      ],
    );
  }

  //Widget for Account Settings
  Widget accountSettings() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Text(
                'Account Settings',
                textScaleFactor: 1.5,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            UserAccntSettings.signOut(context);
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 7),
            padding: EdgeInsets.fromLTRB(14, 10, 10, 10),
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                SizedBox(width: 10),
                Text(
                  'Sign Out',
                  textScaleFactor: 1.5,
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 7),
          padding: EdgeInsets.fromLTRB(14, 10, 10, 0),
          child: InkWell(
            onTap: () {
              setState(() {
                acntDeleteConfirm = true;
                isDelNo = false;
                isUpdatingNo = false;
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                SizedBox(width: 10),
                Text(
                  'Delete Account',
                  textScaleFactor: 1.5,
                ),
              ],
            ),
          ),
        ),
        AnimatedSizeAndFade.showHide(
          vsync: this,
          show: acntDeleteConfirm,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm Delete',
                  textScaleFactor: 1.5,
                ),
                SizedBox(height: 10),
                Text('You can relogin to reactivate your account!'),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FlatButton(
                      child: Text('Confirm'),
                      splashColor: Colors.red,
                      onPressed: () {
                        UserAccntSettings.deleteAccnt(context);
                      },
                    ),
                    FlatButton(
                      child: Text('Cancel'),
                      splashColor: Colors.green,
                      onPressed: () {
                        setState(() {
                          acntDeleteConfirm = false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(7, 30, 7, 7),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    acntDeleteConfirm = false;
    isUpdatingNo = false;
    isDelNo = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 7, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                mobileSettings(),
                accountSettings(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
