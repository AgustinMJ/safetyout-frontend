import 'dart:convert';
import 'dart:io';

import 'package:app/app_localizations.dart';
import 'package:app/defaults/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Restrictions extends StatefulWidget {
  Restrictions({Key key}) : super(key: key);

  @override
  _Restrictions createState() => _Restrictions();
}

class _Restrictions extends State<Restrictions> {
  Map<String, List<Widget>> restrictions = {};
  bool viewMovility = false;
  bool viewCurfew = false;
  bool viewGroups = false;
  bool viewRestaurants = false;
  bool viewCommerce = false;
  bool viewPublicTransport = false;
  bool viewCulture = false;
  bool viewPlaygrounds = false;

  void getRestrictions() async {
    String langCode = 'ca';
    var prefs = await SharedPreferences.getInstance();

    if (prefs.getString('language_code') != null) {
      langCode = prefs.getString('language_code');
    }

    Uri url =
        Uri.parse('https://restrictions-esp.herokuapp.com/cat/' + langCode);
    var response =
        await http.get(url, headers: {HttpHeaders.contentTypeHeader: "utf8"});

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          List<Widget> m = [];
          body["movility"].forEach((val) {
            m.add(Text(
                val != ""
                    ? val
                    : AppLocalizations.of(context)
                        .translate("No_hi_ha_restriccions_daquest_aspecte"),
                style: TextStyle(
                    fontSize: Constants.xs(context),
                    color: Constants.black(context))));
          });
          restrictions["movility"] = m;

          List<Widget> c = [];
          body["curfew"].forEach((val) {
            c.add(Text(
                val != ""
                    ? val
                    : AppLocalizations.of(context)
                        .translate("No_hi_ha_restriccions_daquest_aspecte"),
                style: TextStyle(
                    fontSize: Constants.xs(context),
                    color: Constants.black(context))));
          });
          restrictions["curfew"] = c;
          ;

          List<Widget> g = [];
          body["groups"].forEach((val) {
            g.add(Text(
                val != ""
                    ? val
                    : AppLocalizations.of(context)
                        .translate("No_hi_ha_restriccions_daquest_aspecte"),
                style: TextStyle(
                    fontSize: Constants.xs(context),
                    color: Constants.black(context))));
          });
          restrictions["groups"] = g;
          ;

          List<Widget> r = [];
          body["restaurants"].forEach((key, val) {
            r.add(Text(key,
                style: TextStyle(
                    fontSize: Constants.s(context),
                    color: Constants.black(context),
                    fontWeight: Constants.bold)));
            val.forEach((val) {
              r.add(Text(
                  val != ""
                      ? val
                      : AppLocalizations.of(context)
                          .translate("No_hi_ha_restriccions_daquest_aspecte"),
                  style: TextStyle(
                      fontSize: Constants.xs(context),
                      color: Constants.black(context))));
            });
          });
          restrictions["restaurants"] = r;

          List<Widget> e = [];
          body["commerce"].forEach((key, val) {
            e.add(Padding(
              padding: EdgeInsets.only(top: Constants.v1(context)),
              child: Text(key,
                  style: TextStyle(
                      fontSize: Constants.s(context),
                      color: Constants.black(context),
                      fontWeight: Constants.bold)),
            ));
            if (val.runtimeType.toString() ==
                '_InternalLinkedHashMap<String, dynamic>') {
              val.forEach((key, val) {
                e.add(Text(key,
                    style: TextStyle(
                        fontSize: Constants.xs(context),
                        color: Constants.black(context),
                        fontWeight: Constants.bold)));
                val.forEach((val) {
                  e.add(Text(
                      val != ""
                          ? val
                          : AppLocalizations.of(context).translate(
                              "No_hi_ha_restriccions_daquest_aspecte"),
                      style: TextStyle(
                          fontSize: Constants.xs(context),
                          color: Constants.black(context))));
                });
              });
            } else if (val.runtimeType.toString() == 'List<dynamic>') {
              val.forEach((val) {
                e.add(Text(
                    val != ""
                        ? val
                        : AppLocalizations.of(context)
                            .translate("No_hi_ha_restriccions_daquest_aspecte"),
                    style: TextStyle(
                        fontSize: Constants.xs(context),
                        color: Constants.black(context))));
              });
            }
          });
          restrictions["commerce"] = e;
          List<Widget> p = [];
          body["public transport"].forEach((val) {
            p.add(Text(
                val != ""
                    ? val
                    : AppLocalizations.of(context)
                        .translate("No_hi_ha_restriccions_daquest_aspecte"),
                style: TextStyle(
                    fontSize: Constants.xs(context),
                    color: Constants.black(context))));
          });
          restrictions["public transport"] = p;

          List<Widget> t = [];
          body["culture"].forEach((key, val) {
            t.add(Text(key,
                style: TextStyle(
                    fontSize: Constants.s(context),
                    color: Constants.black(context),
                    fontWeight: Constants.bold)));
            val.forEach((val) {
              t.add(Text(
                  val != ""
                      ? val
                      : AppLocalizations.of(context)
                          .translate("No_hi_ha_restriccions_daquest_aspecte"),
                  style: TextStyle(
                      fontSize: Constants.xs(context),
                      color: Constants.black(context))));
            });
          });
          restrictions["culture"] = t;
        });
      }
    } else {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: SingleChildScrollView(
                  child: ListBody(
                children: <Widget>[
                  Text(AppLocalizations.of(context).translate("Error_de_xarxa"),
                      style: TextStyle(
                          fontSize: Constants.m(context),
                          color: Constants.black(context))),
                ],
              )),
              actions: <Widget>[
                TextButton(
                  child: Text(
                      AppLocalizations.of(context).translate("Acceptar"),
                      style: TextStyle(color: Constants.black(context))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    getRestrictions();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          Container(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(Constants.h6(context),
                      Constants.v1(context), 0, Constants.v1(context)),
                  child: Container(
                    height: Constants.a8(context),
                    width: Constants.a8(context),
                    decoration: BoxDecoration(
                      color: Constants.green(context),
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      boxShadow: [
                        BoxShadow(
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/icons/barrier.svg',
                            color: Color(0xFF242424),
                            height: 28 /
                                (MediaQuery.of(context).size.width < 380
                                    ? 1.3
                                    : 1)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: Constants.h3(context)),
                  child: Text(
                    AppLocalizations.of(context).translate("Entrada_i_sortida"),
                    style: TextStyle(
                        color: Constants.black(context),
                        fontSize: Constants.m(context),
                        fontWeight: Constants.bold),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: Constants.h6(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              viewMovility = !viewMovility;
                            });
                          },
                          child: Icon(
                              viewMovility
                                  ? FontAwesomeIcons.chevronUp
                                  : FontAwesomeIcons.chevronRight,
                              color: Constants.black(context),
                              size: 30.0 /
                                  (MediaQuery.of(context).size.height < 700
                                      ? 1.3
                                      : MediaQuery.of(context).size.height < 800
                                          ? 1.15
                                          : 1)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: viewMovility ? Constants.a13(context) : 0,
            ),
            width: Constants.wFull(context),
            child: Padding(
              padding: EdgeInsets.fromLTRB(Constants.h6(context), 0,
                  Constants.h6(context), Constants.v6(context)),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: restrictions["movility"] != null &&
                              restrictions["movility"].isNotEmpty
                          ? restrictions["movility"]
                          : [
                              Text(
                                AppLocalizations.of(context).translate(
                                    "No_hi_ha_restriccions_daquest_aspecte"),
                                style: TextStyle(
                                    color: Constants.black(context),
                                    fontSize: Constants.xs(context)),
                              )
                            ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(Constants.h6(context),
                      Constants.v1(context), 0, Constants.v1(context)),
                  child: Container(
                    height: Constants.a8(context),
                    width: Constants.a8(context),
                    decoration: BoxDecoration(
                      color: Constants.green(context),
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      boxShadow: [
                        BoxShadow(
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/icons/clock.svg',
                            color: Color(0xFF242424),
                            height: 35 /
                                (MediaQuery.of(context).size.width < 380
                                    ? 1.3
                                    : 1)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: Constants.h3(context)),
                  child: Text(
                    AppLocalizations.of(context).translate("Toc_de_queda"),
                    style: TextStyle(
                        color: Constants.black(context),
                        fontSize: Constants.m(context),
                        fontWeight: Constants.bold),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: Constants.h6(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              viewCurfew = !viewCurfew;
                            });
                          },
                          child: Icon(
                              viewCurfew
                                  ? FontAwesomeIcons.chevronUp
                                  : FontAwesomeIcons.chevronRight,
                              color: Constants.black(context),
                              size: 30.0 /
                                  (MediaQuery.of(context).size.height < 700
                                      ? 1.3
                                      : MediaQuery.of(context).size.height < 800
                                          ? 1.15
                                          : 1)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: viewCurfew ? Constants.a13(context) : 0,
            ),
            width: Constants.wFull(context),
            child: Padding(
              padding: EdgeInsets.fromLTRB(Constants.h6(context), 0,
                  Constants.h6(context), Constants.v6(context)),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: restrictions["curfew"] != null &&
                              restrictions["curfew"].isNotEmpty
                          ? restrictions["curfew"]
                          : [
                              Text(
                                AppLocalizations.of(context).translate(
                                    "No_hi_ha_restriccions_daquest_aspecte"),
                                style: TextStyle(
                                    color: Constants.black(context),
                                    fontSize: Constants.xs(context)),
                              )
                            ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(Constants.h6(context),
                      Constants.v1(context), 0, Constants.v1(context)),
                  child: Container(
                    height: Constants.a8(context),
                    width: Constants.a8(context),
                    decoration: BoxDecoration(
                      color: Constants.green(context),
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      boxShadow: [
                        BoxShadow(
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/icons/group.svg',
                            color: Color(0xFF242424),
                            height: 35 /
                                (MediaQuery.of(context).size.width < 380
                                    ? 1.3
                                    : 1)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: Constants.h3(context)),
                  child: Text(
                    AppLocalizations.of(context).translate("Trobades_socials"),
                    style: TextStyle(
                        color: Constants.black(context),
                        fontSize: Constants.m(context),
                        fontWeight: Constants.bold),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: Constants.h6(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              viewGroups = !viewGroups;
                            });
                          },
                          child: Icon(
                              viewGroups
                                  ? FontAwesomeIcons.chevronUp
                                  : FontAwesomeIcons.chevronRight,
                              color: Constants.black(context),
                              size: 30.0 /
                                  (MediaQuery.of(context).size.height < 700
                                      ? 1.3
                                      : MediaQuery.of(context).size.height < 800
                                          ? 1.15
                                          : 1)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: viewGroups ? Constants.a13(context) : 0,
            ),
            width: Constants.wFull(context),
            child: Padding(
              padding: EdgeInsets.fromLTRB(Constants.h6(context), 0,
                  Constants.h6(context), Constants.v6(context)),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: restrictions["groups"] != null &&
                              restrictions["groups"].isNotEmpty
                          ? restrictions["groups"]
                          : [
                              Text(
                                AppLocalizations.of(context).translate(
                                    "No_hi_ha_restriccions_daquest_aspecte"),
                                style: TextStyle(
                                    color: Constants.black(context),
                                    fontSize: Constants.xs(context)),
                              )
                            ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(Constants.h6(context),
                      Constants.v1(context), 0, Constants.v1(context)),
                  child: Container(
                    height: Constants.a8(context),
                    width: Constants.a8(context),
                    decoration: BoxDecoration(
                      color: Constants.green(context),
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      boxShadow: [
                        BoxShadow(
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/icons/restaurant.svg',
                            color: Color(0xFF242424),
                            height: 35 /
                                (MediaQuery.of(context).size.width < 380
                                    ? 1.3
                                    : 1)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: Constants.h3(context)),
                  child: Text(
                    AppLocalizations.of(context)
                        .translate("Hosteleria_i_restauracio"),
                    style: TextStyle(
                        color: Constants.black(context),
                        fontSize: Constants.m(context),
                        fontWeight: Constants.bold),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: Constants.h6(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              viewRestaurants = !viewRestaurants;
                            });
                          },
                          child: Icon(
                              viewRestaurants
                                  ? FontAwesomeIcons.chevronUp
                                  : FontAwesomeIcons.chevronRight,
                              color: Constants.black(context),
                              size: 30.0 /
                                  (MediaQuery.of(context).size.height < 700
                                      ? 1.3
                                      : MediaQuery.of(context).size.height < 800
                                          ? 1.15
                                          : 1)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: viewRestaurants ? Constants.a13(context) : 0,
            ),
            width: Constants.wFull(context),
            child: Padding(
              padding: EdgeInsets.fromLTRB(Constants.h6(context), 0,
                  Constants.h6(context), Constants.v6(context)),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: restrictions["restaurants"] != null &&
                              restrictions["restaurants"].isNotEmpty
                          ? restrictions["restaurants"]
                          : [
                              Text(
                                AppLocalizations.of(context).translate(
                                    "No_hi_ha_restriccions_daquest_aspecte"),
                                style: TextStyle(
                                    color: Constants.black(context),
                                    fontSize: Constants.xs(context)),
                              )
                            ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(Constants.h6(context),
                      Constants.v1(context), 0, Constants.v1(context)),
                  child: Container(
                    height: Constants.a8(context),
                    width: Constants.a8(context),
                    decoration: BoxDecoration(
                      color: Constants.green(context),
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      boxShadow: [
                        BoxShadow(
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/icons/shop.svg',
                            color: Color(0xFF242424),
                            height: 34 /
                                (MediaQuery.of(context).size.width < 380
                                    ? 1.3
                                    : 1)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: Constants.h3(context)),
                  child: Text(
                    AppLocalizations.of(context).translate("Comerç_i_consum"),
                    style: TextStyle(
                        color: Constants.black(context),
                        fontSize: Constants.m(context),
                        fontWeight: Constants.bold),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: Constants.h6(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              viewCommerce = !viewCommerce;
                            });
                          },
                          child: Icon(
                              viewCommerce
                                  ? FontAwesomeIcons.chevronUp
                                  : FontAwesomeIcons.chevronRight,
                              color: Constants.black(context),
                              size: 30.0 /
                                  (MediaQuery.of(context).size.height < 700
                                      ? 1.3
                                      : MediaQuery.of(context).size.height < 800
                                          ? 1.15
                                          : 1)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: viewCommerce ? Constants.a13(context) : 0,
            ),
            width: Constants.wFull(context),
            child: Padding(
              padding: EdgeInsets.fromLTRB(Constants.h6(context), 0,
                  Constants.h6(context), Constants.v6(context)),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: restrictions["commerce"] != null &&
                              restrictions["commerce"].isNotEmpty
                          ? restrictions["commerce"]
                          : [
                              Text(
                                AppLocalizations.of(context).translate(
                                    "No_hi_ha_restriccions_daquest_aspecte"),
                                style: TextStyle(
                                    color: Constants.black(context),
                                    fontSize: Constants.xs(context)),
                              )
                            ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(Constants.h6(context),
                      Constants.v1(context), 0, Constants.v1(context)),
                  child: Container(
                    height: Constants.a8(context),
                    width: Constants.a8(context),
                    decoration: BoxDecoration(
                      color: Constants.green(context),
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      boxShadow: [
                        BoxShadow(
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/icons/bus.svg',
                            color: Color(0xFF242424),
                            height: 32 /
                                (MediaQuery.of(context).size.width < 380
                                    ? 1.3
                                    : 1)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: Constants.h3(context)),
                  child: Text(
                    AppLocalizations.of(context).translate("Transport_public"),
                    style: TextStyle(
                        color: Constants.black(context),
                        fontSize: Constants.m(context),
                        fontWeight: Constants.bold),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: Constants.h6(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              viewPublicTransport = !viewPublicTransport;
                            });
                          },
                          child: Icon(
                              viewPublicTransport
                                  ? FontAwesomeIcons.chevronUp
                                  : FontAwesomeIcons.chevronRight,
                              color: Constants.black(context),
                              size: 30.0 /
                                  (MediaQuery.of(context).size.height < 700
                                      ? 1.3
                                      : MediaQuery.of(context).size.height < 800
                                          ? 1.15
                                          : 1)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: viewPublicTransport ? Constants.a13(context) : 0,
            ),
            width: Constants.wFull(context),
            child: Padding(
              padding: EdgeInsets.fromLTRB(Constants.h6(context), 0,
                  Constants.h6(context), Constants.v6(context)),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: restrictions["public transport"] != null &&
                              restrictions["public transport"].isNotEmpty
                          ? restrictions["public transport"]
                          : [
                              Text(
                                AppLocalizations.of(context).translate(
                                    "No_hi_ha_restriccions_daquest_aspecte"),
                                style: TextStyle(
                                    color: Constants.black(context),
                                    fontSize: Constants.xs(context)),
                              )
                            ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(Constants.h6(context),
                      Constants.v1(context), 0, Constants.v1(context)),
                  child: Container(
                    height: Constants.a8(context),
                    width: Constants.a8(context),
                    decoration: BoxDecoration(
                      color: Constants.green(context),
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      boxShadow: [
                        BoxShadow(
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/icons/comedy.svg',
                            color: Color(0xFF242424),
                            height: 33 /
                                (MediaQuery.of(context).size.width < 380
                                    ? 1.3
                                    : 1)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: Constants.h3(context)),
                  child: Text(
                    AppLocalizations.of(context)
                        .translate("Activitats_culturals"),
                    style: TextStyle(
                        color: Constants.black(context),
                        fontSize: Constants.m(context),
                        fontWeight: Constants.bold),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: Constants.h6(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              viewCulture = !viewCulture;
                            });
                          },
                          child: Icon(
                              viewCulture
                                  ? FontAwesomeIcons.chevronUp
                                  : FontAwesomeIcons.chevronRight,
                              color: Constants.black(context),
                              size: 30.0 /
                                  (MediaQuery.of(context).size.height < 700
                                      ? 1.3
                                      : MediaQuery.of(context).size.height < 800
                                          ? 1.15
                                          : 1)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: viewCulture ? Constants.a13(context) : 0,
            ),
            width: Constants.wFull(context),
            child: Padding(
              padding: EdgeInsets.fromLTRB(Constants.h6(context), 0,
                  Constants.h6(context), Constants.v6(context)),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: restrictions["culture"] != null &&
                              restrictions["culture"].isNotEmpty
                          ? restrictions["culture"]
                          : [
                              Text(
                                AppLocalizations.of(context).translate(
                                    "No_hi_ha_restriccions_daquest_aspecte"),
                                style: TextStyle(
                                    color: Constants.black(context),
                                    fontSize: Constants.xs(context)),
                              )
                            ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(Constants.h6(context),
                      Constants.v1(context), 0, Constants.v1(context)),
                  child: Container(
                    height: Constants.a8(context),
                    width: Constants.a8(context),
                    decoration: BoxDecoration(
                      color: Constants.green(context),
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      boxShadow: [
                        BoxShadow(
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/icons/slide.svg',
                            color: Color(0xFF242424),
                            height: 33 /
                                (MediaQuery.of(context).size.width < 380
                                    ? 1.3
                                    : 1)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: Constants.h3(context)),
                  child: Text(
                    AppLocalizations.of(context)
                        .translate("Zones_de_joc_infantils"),
                    style: TextStyle(
                        color: Constants.black(context),
                        fontSize: Constants.m(context),
                        fontWeight: Constants.bold),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: Constants.h6(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              viewPlaygrounds = !viewPlaygrounds;
                            });
                          },
                          child: Icon(
                              viewPlaygrounds
                                  ? FontAwesomeIcons.chevronUp
                                  : FontAwesomeIcons.chevronRight,
                              color: Constants.black(context),
                              size: 30.0 /
                                  (MediaQuery.of(context).size.height < 700
                                      ? 1.3
                                      : MediaQuery.of(context).size.height < 800
                                          ? 1.15
                                          : 1)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: viewPlaygrounds ? Constants.a13(context) : 0,
            ),
            width: Constants.wFull(context),
            child: Padding(
              padding: EdgeInsets.fromLTRB(Constants.h6(context), 0,
                  Constants.h6(context), Constants.v6(context)),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: restrictions["playgrounds"] != null &&
                              restrictions["playgrounds"].isNotEmpty
                          ? restrictions["playgrounds"]
                          : [
                              Text(
                                AppLocalizations.of(context).translate(
                                    "No_hi_ha_restriccions_daquest_aspecte"),
                                style: TextStyle(
                                    color: Constants.black(context),
                                    fontSize: Constants.xs(context)),
                              )
                            ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
