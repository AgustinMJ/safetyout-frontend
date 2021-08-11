import 'dart:convert';

import 'package:app/app_localizations.dart';
import 'package:app/defaults/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class AssolimentsContacte extends StatefulWidget {
  AssolimentsContacte(this.userId, {Key key /*, this.title*/})
      : super(key: key);
  String userId;
  //final String title;

  @override
  _AssolimentsContacte createState() => _AssolimentsContacte(this.userId);
}

enum Appearence { light, dark, system }

class _AssolimentsContacte extends State<AssolimentsContacte> {
  _AssolimentsContacte(this.userId);
  String userId;
  int idAssoliment;
  List<dynamic> assolimentsUsuari = [];
  List<String> iconesAssoliments = [
    "camera master",
    "edit master",
    "welcome master",
    "edit assistance master",
    "delete master",
    "friends bronze",
    "friends silver",
    "friends gold",
    "friends platinum",
    "friends diamond",
    "xat bronze",
    "xat silver",
    "xat golden",
    "xat platinum",
    "xat diamond",
    "place bronze",
    "place silver",
    "place golden",
    "place platinum",
    "place diamond",
    "place advanced",
    "place master",
    "free bronze",
    "free silver",
    "free golden",
    "free platinum",
    "free diamond",
    "bubble master",
    "bubble chat master",
  ];

  List<String> textAssoliments = [
    "Afegeix una foto",
    "Canvia el nom",
    "Benvingut!",
    "Edita una assistència",
    "Elimina una assistència",
    "Agrega 1 contacte",
    "Agrega 5 contactes",
    "Agrega 25 contactes",
    "Agrega 50 contactes",
    "Agrega 100 contactes",
    "Comença 1 xat",
    "Comença 5 xats",
    "Comença 25 xats",
    "Comença 50 xats",
    "Comença 100 xats",
    "Notifica 1 assistència",
    "Notifica 5 assistències",
    "Notifica 25 assistències",
    "Notifica 50 assistències",
    "Notifica 100 assistències",
    "Notifica 500 assistències",
    "Notifica 1000 assistències",
    "1 mes a l'aire lliure",
    "3 messos a l'aire lliure",
    "6 messos a l'aire lliure",
    "9 messos a l'aire lliure",
    "1 any a l'aire lliure",
    "Entra en una bombolla",
    "Envia un missatge en un xat bombolla",
  ];

  @override
  void initState() {
    super.initState();
    if (mounted) {
      var uri = Uri.parse(
          'https://safetyout.herokuapp.com/user/' + userId + '/trophies');
      http.get(uri).then((res) {
        print(res.statusCode);
        if (res.statusCode == 200) {
          Map<String, dynamic> body = jsonDecode(res.body);
          setState(() {
            assolimentsUsuari = body["trophies"];
          });
        } else {
          print(res.statusCode);
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                  content: SingleChildScrollView(
                      child: ListBody(
                    children: <Widget>[
                      Text(
                          AppLocalizations.of(context)
                              .translate("Error_de_xarxa"),
                          style: TextStyle(fontSize: Constants.m(context))),
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
      }).catchError((err) {
        print(err);
        //Sale error por pantalla
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                content: SingleChildScrollView(
                    child: ListBody(
                  children: <Widget>[
                    Text(
                        AppLocalizations.of(context)
                            .translate("Error_de_xarxa"),
                        style: TextStyle(fontSize: Constants.m(context))),
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
      });
    }
  }

  void showAssoliment() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
            content: SingleChildScrollView(
                child: Column(
              children: [
                Image(
                    height: Constants.xxl(context) +
                        Constants.xxl(context) +
                        Constants.xxl(context) +
                        Constants.xs(context),
                    image: AssetImage("assets/icons/achievements/" +
                        iconesAssoliments[idAssoliment] +
                        ".png")),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      Constants.h1(context),
                      Constants.v1(context),
                      Constants.h1(context),
                      Constants.v1(context)),
                  child: Text(AppLocalizations.of(context)
                      .translate(textAssoliments[idAssoliment])),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      Constants.h1(context),
                      Constants.v1(context),
                      Constants.h1(context),
                      Constants.v1(context)),
                  child: Text(
                      assolimentsUsuari.contains(idAssoliment + 1)
                          ? AppLocalizations.of(context).translate("Aconseguit")
                          : AppLocalizations.of(context).translate("Pendent"),
                      style: TextStyle(
                          color: assolimentsUsuari.contains(idAssoliment + 1)
                              ? Constants.black(context)
                              : Constants.grey(context),
                          fontWeight: Constants.bold)),
                )
              ],
            )),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context).translate("Acceptar"),
                    style: TextStyle(color: Constants.black(context))),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(Constants.h4(context),
                        Constants.v7(context), Constants.h4(context), 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 0;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(1) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[0] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 27;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(28) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[27] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 2;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(3) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[2] +
                                          ".png")),
                            )),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(Constants.h4(context),
                        Constants.v3(context), Constants.h4(context), 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 3;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(4) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[3] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 4;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(5) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[4] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 5;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(6) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[5] +
                                          ".png")),
                            )),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(Constants.h4(context),
                        Constants.v3(context), Constants.h4(context), 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 6;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(7) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[6] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 7;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(8) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[7] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 8;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(9) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[8] +
                                          ".png")),
                            )),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(Constants.h4(context),
                        Constants.v3(context), Constants.h4(context), 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 9;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(10) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[9] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 10;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(11) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[10] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 11;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(12) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[11] +
                                          ".png")),
                            )),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(Constants.h4(context),
                        Constants.v3(context), Constants.h4(context), 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 12;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(13) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[12] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 13;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(14) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[13] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 14;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(15) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[14] +
                                          ".png")),
                            )),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(Constants.h4(context),
                        Constants.v3(context), Constants.h4(context), 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 15;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(16) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[15] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 16;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(17) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[16] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 17;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(18) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[17] +
                                          ".png")),
                            )),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(Constants.h4(context),
                        Constants.v3(context), Constants.h4(context), 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 18;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(19) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[18] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 19;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(20) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[19] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 20;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(21) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[20] +
                                          ".png")),
                            )),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(Constants.h4(context),
                        Constants.v3(context), Constants.h4(context), 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 21;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(22) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[21] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 22;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(23) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[22] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 23;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(24) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[23] +
                                          ".png")),
                            )),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(Constants.h4(context),
                        Constants.v3(context), Constants.h4(context), 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 24;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(25) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[24] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 25;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(26) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[25] +
                                          ".png")),
                            )),
                        InkWell(
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              idAssoliment = 26;
                              showAssoliment();
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(
                                      assolimentsUsuari.contains(27) ? 1 : 0.5),
                                  BlendMode.dstIn),
                              child: Image(
                                  height: Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xxl(context) +
                                      Constants.xs(context),
                                  image: AssetImage(
                                      "assets/icons/achievements/" +
                                          iconesAssoliments[26] +
                                          ".png")),
                            )),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
