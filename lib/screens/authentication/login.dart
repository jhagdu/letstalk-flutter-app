//Importing Required Modules
import 'package:firebase_auth/firebase_auth.dart';
import 'package:letstalk/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Login Page Class
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _regFormKey = GlobalKey<FormState>();

  String logPasswd, logEmail;
  bool loginStatus = false, errorMsg = false;
  var fireAuth = FirebaseAuth.instance;

  //Function to set Authentication done or not Flag in Shared Preferences
  setAuthCheckFlag(var key, val) async {
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
      body: SingleChildScrollView(
        child: Container(
          child: Form(
            key: _regFormKey,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(20, 30, 20, 10),
                  child: TextFormField(
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
                      setState(
                        () {
                          errorMsg = false;
                        },
                      );
                      logEmail = value;
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    obscureText: true,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Password';
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
                      setState(
                        () {
                          errorMsg = false;
                        },
                      );
                      logPasswd = value;
                    },
                  ),
                ),
                errorMsg
                    ? Container(
                        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Email or Password is incorrect',
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.start,
                        ),
                      )
                    : SizedBox(),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: !loginStatus
                      ? RaisedButton(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          splashColor: Colors.green,
                          child: Text(
                            "Log In",
                            textScaleFactor: 2,
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () async {
                            if (_regFormKey.currentState.validate()) {
                              setAuthCheckFlag('isAuthDone', true);
                              try {
                                setState(
                                  () {
                                    loginStatus = true;
                                  },
                                );
                                var userLogin =
                                    await fireAuth.signInWithEmailAndPassword(
                                  email: logEmail,
                                  password: logPasswd,
                                );
                                if (userLogin != null) {
                                  setAuthCheckFlag('isAuthDone', true);
                                  email = logEmail;
                                  setUserSettings('Email', email);
                                  username = (await letsChatFS
                                      .collection('/UsersData/')
                                      .doc(email)
                                      .get())['Username'];
                                  Navigator.pushReplacementNamed(
                                      context, "/home");
                                  setState(
                                    () {
                                      loginStatus = false;
                                    },
                                  );
                                }
                              } catch (err) {
                                setState(
                                  () {
                                    errorMsg = true;
                                    loginStatus = false;
                                  },
                                );
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
    );
  }
}
