/* import 'package:app/app_localizations.dart'; */
import 'package:app/defaults/constants.dart';
import 'package:app/pages/calendar.dart';
import 'package:app/pages/discover.dart';
import 'package:app/pages/home.dart';
import 'package:app/pages/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class App extends StatefulWidget {
  App({Key key /*, this.title*/}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  //final String title;

  @override
  _App createState() => _App();
}

class _App extends State<App> {
  Function settings = () {};

  static Function mapPressed;

  static int index = 0;

  static List<Widget> pantalles = <Widget>[
    Home(mapPressed: mapPressed),
    Discover(),
    Calendar(),
    Profile()
  ];

  void onItemTapped(int newIndex) {
    setState(() {
      index = newIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    mapPressed = () {
      setState(() {
        index = 1;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: pantalles.elementAt(index)),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 10,
                ),
              ],
            ),
            child: BottomNavigationBar(
              iconSize:
                  45 / (MediaQuery.of(context).size.width < 380 ? 1.3 : 1),
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/home.svg',
                    color: Constants.black(context),
                    height: 40 /
                        (MediaQuery.of(context).size.width < 380 ? 1.3 : 1),
                  ),
                  label: "Home",
                  activeIcon: SvgPicture.asset('assets/icons/home_fill.svg',
                      color: Constants.black(context),
                      height: 40 /
                          (MediaQuery.of(context).size.width < 380 ? 1.3 : 1)),
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset('assets/icons/compass.svg',
                      color: Constants.black(context),
                      height: 40 /
                          (MediaQuery.of(context).size.width < 380 ? 1.3 : 1)),
                  label: "Discover",
                  activeIcon: SvgPicture.asset('assets/icons/compass_fill.svg',
                      color: Constants.black(context),
                      height: 40 /
                          (MediaQuery.of(context).size.width < 380 ? 1.3 : 1)),
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset('assets/icons/calendar.svg',
                      color: Constants.black(context),
                      height: 38 /
                          (MediaQuery.of(context).size.width < 380 ? 1.3 : 1)),
                  label: "Calendar",
                  activeIcon: SvgPicture.asset('assets/icons/calendar_fill.svg',
                      color: Constants.black(context),
                      height: 38 /
                          (MediaQuery.of(context).size.width < 380 ? 1.3 : 1)),
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesomeIcons.user,
                    color: Constants.black(context),
                    size: 40 /
                        (MediaQuery.of(context).size.width < 380 ? 1.3 : 1),
                  ),
                  label: "Profile",
                  activeIcon: Icon(
                    FontAwesomeIcons.solidUser,
                    color: Constants.black(context),
                    size: 40 /
                        (MediaQuery.of(context).size.width < 380 ? 1.3 : 1),
                  ),
                ),
              ],
              currentIndex: index,
              onTap: onItemTapped,
            ),
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
