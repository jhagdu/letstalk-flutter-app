//Importing Required Modules
import 'package:letstalk/global_variables.dart';
import 'package:letstalk/screens/authentication/auth_panel.dart';
import 'package:letstalk/screens/authentication/main_animation.dart';
import 'package:letstalk/screens/chats/chat_screen.dart';
import 'package:letstalk/screens/chats/view_image.dart';
import 'package:letstalk/screens/chats/view_locn.dart';
import 'package:letstalk/screens/home/home.dart';
import 'package:letstalk/screens/other/settings.dart';
import 'package:after_layout/after_layout.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

//Main Function
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(LetsTalk());
}

//Lets Talk App Class
class LetsTalk extends StatefulWidget {
  @override
  _LetsTalkState createState() => _LetsTalkState();
}

class _LetsTalkState extends State<LetsTalk> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      routes: {
        '/': (context) => CheckAuth(),
        '/auth': (context) => AuthScreen(),
        '/home': (context) => HomeScreen(),
        '/settings': (context) => AppSettings(),
        '/home/chat': (context) => ChatScreen(),
        '/home/chat/sendimage': (context) => SendImagePage(),
        '/home/chat/viewrecievedimg': (context) => ViewRecievedImage(),
        '/home/chat/sendlocn': (context) => SendLocation(),
        '/home/chat/viewrcvdlocn': (context) => ViewRcvdLocn(),
      },
    );
  }
}

//Class for Checking if Authentication already done or not
class CheckAuth extends StatefulWidget {
  @override
  CheckAuthState createState() => new CheckAuthState();
}

class CheckAuthState extends State<CheckAuth> with AfterLayoutMixin<CheckAuth> {
  Future checkForAuth() async {
    SharedPreferences userSettings = await SharedPreferences.getInstance();
    email = userSettings.getString('Email');

    SharedPreferences appSettings = await SharedPreferences.getInstance();
    bool _done = (appSettings.getBool('isAuthDone') ?? false);

    //Redirect to Home Page if Auth done already, Otherwise to Auth Page
    if (_done && email != null) {
      username = (await letsChatFS
          .collection('/UsersData/')
          .doc(email)
          .get())['Username'];
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkForAuth();

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return new Scaffold(
      backgroundColor: Color.fromRGBO(255, 195, 0, 1),
      body: SafeArea(
        child: Column(
          children: [
            MainAnimationScreen(),
            SizedBox(height: 70),
            Container(
              child: SleekCircularSlider(
                appearance: CircularSliderAppearance(
                  size: 80,
                  spinnerMode: true,
                  customColors: CustomSliderColors(
                    trackColor: Colors.white,
                    dotColor: Colors.transparent,
                    progressBarColors: [
                      Colors.deepOrange,
                      Colors.lightBlueAccent,
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
