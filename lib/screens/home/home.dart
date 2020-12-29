//Importing Required Modules
import 'package:letstalk/global_variables.dart';
import 'package:letstalk/screens/home/search.dart';
import 'package:letstalk/screens/drawer/user_drawer.dart';
import 'package:letstalk/screens/home/favourites.dart';
import 'package:letstalk/screens/home/recent.dart';
import 'package:letstalk/screens/other/user_accnt_stng.dart';
import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';

//Class for Menu at Home Page
class HomeMenu {
  static const String NewChat = 'New Chat';
  static const String MyProfile = 'My Profile';
  static const String Settings = 'Settings';
  static const String SignOut = 'Sign Out';

  static const List<String> choices = <String>[
    NewChat,
    MyProfile,
    Settings,
    SignOut
  ];
}

//Home Page Class
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _homeScaffoldKey =
      new GlobalKey<ScaffoldState>();

  TabController homeTab;

  //Get Profile Pic and Mob No. of Logged In User
  getOwnDetails() async {
    var profPic = (await letsChatFS
        .collection('/UsersData/')
        .doc(email)
        .get())['Profile'];

    var mobNo =
        (await letsChatFS.collection('/UsersData/').doc(email).get())['Mobile'];

    setState(() {
      TheUser.profPic = profPic;
      TheUser.mobNo = mobNo;
    });
  }

  //Function which return Profile Pic accordingly
  setOwnProfilePic() {
    if (TheUser.newProfPic != null) {
      return FileImage(TheUser.newProfPic);
    } else if (TheUser.profPic != null) {
      return NetworkImage(TheUser.profPic);
    } else {
      return AssetImage('assets/images/dummy_user.png');
    }
  }

  @override
  void initState() {
    getOwnDetails();
    homeTab = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent,
      key: _homeScaffoldKey,
      drawer: UserDrawer(),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Container(
                height: deviceHeight * 0.12,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        _homeScaffoldKey.currentState.openDrawer();
                      },
                      splashColor: Colors.deepOrange,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        height: deviceHeight * 0.39,
                        width: deviceWidth * 0.20,
                        child: CircleAvatar(
                          backgroundImage: setOwnProfilePic(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Text(
                          'Let\'s Talk',
                          textScaleFactor: 2.2,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          IconButton(
                            tooltip:
                                isSearching ? 'Search for User' : 'New Chat',
                            iconSize: 30,
                            splashColor: Colors.yellow,
                            splashRadius: 30,
                            icon: Icon(
                              isSearching ? Icons.search : Icons.add,
                            ),
                            onPressed: () {
                              setState(() {
                                isSearching = isSearching ? false : true;
                              });
                            },
                          ),
                          PopupMenuButton(
                            tooltip: 'Show Menu',
                            icon: Icon(
                              Icons.more_vert,
                              size: 28,
                            ),
                            onSelected: (value) {
                              if (value == HomeMenu.NewChat) {
                                setState(() {
                                  isSearching = true;
                                });
                              }
                              if (value == HomeMenu.MyProfile) {
                                _homeScaffoldKey.currentState.openDrawer();
                              } else if (value == HomeMenu.Settings) {
                                Navigator.pushNamed(context, '/settings');
                              } else if (value == HomeMenu.SignOut) {
                                UserAccntSettings.signOut(context);
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return HomeMenu.choices.map((String choice) {
                                return PopupMenuItem<String>(
                                  value: choice,
                                  child: Text(choice),
                                );
                              }).toList();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSizeAndFade.showHide(
                vsync: this,
                show: isSearching,
                child: SearchUser(),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(3, 5, 3, 0),
                height: deviceHeight * 0.09,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(200, 200, 255, 0.77),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: TabBar(
                  indicatorColor: Colors.deepOrange,
                  controller: homeTab,
                  tabs: [
                    Container(
                      alignment: Alignment.center,
                      height: deviceHeight * 0.09,
                      child: Text(
                        'Chats',
                        textScaleFactor: 1.5,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: deviceHeight * 0.09,
                      child: Text(
                        'Favourites   ',
                        textScaleFactor: 1.5,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
                  child: TabBarView(
                    controller: homeTab,
                    children: [
                      RecentChats(),
                      FavouriteChats(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
