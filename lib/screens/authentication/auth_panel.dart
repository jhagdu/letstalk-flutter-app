//Importing Required Modules
import 'package:letstalk/global_variables.dart';
import 'package:letstalk/screens/authentication/login.dart';
import 'package:letstalk/screens/authentication/main_animation.dart';
import 'package:letstalk/screens/authentication/register.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

//Authentication Screen Class
class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  TabController authTab;
  PanelController regPanel = new PanelController();

  @override
  void initState() {
    authTab = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 195, 0, 1),
      body: SafeArea(
        child: SlidingUpPanel(
          controller: regPanel,
          backdropTapClosesPanel: true,
          backdropEnabled: true,
          maxHeight: deviceHeight * 0.75,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          onPanelClosed: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          body: MainAnimationScreen(),
          collapsed: GestureDetector(
            onTap: () {
              regPanel.open();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "   Login",
                    textScaleFactor: 2,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "|",
                    textScaleFactor: 2,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Register",
                    textScaleFactor: 2,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          panel: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  width: deviceWidth,
                  height: deviceHeight * 0.125,
                  child: TabBar(
                    indicatorWeight: 3.11,
                    indicatorColor: Colors.red,
                    controller: authTab,
                    tabs: [
                      Container(
                        color: Colors.blueAccent,
                        child: Text(
                          'Login',
                          textScaleFactor: 2,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.blueAccent,
                        child: Text(
                          'Register',
                          textScaleFactor: 2,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    child: TabBarView(
                      controller: authTab,
                      children: [
                        LoginPage(),
                        RegisterPage(),
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
