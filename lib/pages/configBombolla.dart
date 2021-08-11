import 'dart:convert';
//import 'dart:html';

import 'package:app/defaults/constants.dart';
import 'package:app/widgets/raw_input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:http/http.dart' as http;

import '../app_localizations.dart';

class ConfigBubble extends StatefulWidget {
  ConfigBubble({Key key, @required this.BubbleId, this.UserId})
      : super(key: key);
  final String BubbleId;
  final String UserId;
  @override
  _ConfigBubble createState() => _ConfigBubble(this.BubbleId, this.UserId);
}

class _ConfigBubble extends State<ConfigBubble> {
  _ConfigBubble(this.bubbleId, this.userId);
  final String bubbleId;
  final String userId;
  String adminId;
  List<String> MembersIDs = [];
  List<String> MembersNames = [];
  static String bubbleName;

  void getInfoBombolla() {
    MembersIDs.clear();
    var urlB = Uri.parse('https://safetyout.herokuapp.com/bubble/' + bubbleId);
    http.get(urlB).then((resName) {
      if (resName.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(resName.body);
        setState(() {
          bubbleName = body['name'];
          adminId = body['admin'];
          MembersIDs = body['members'];
        });
      }
    });
  }

  void outOfBubble() {
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
                        .translate("Segur_que_vols_sortir_de_la_bombolla"),
                    style: TextStyle(fontSize: Constants.m(context))),
              ],
            )),
            actions: <Widget>[
              TextButton(
                  child: Text(AppLocalizations.of(context).translate("Sortir"),
                      style: TextStyle(color: Constants.red(context))),
                  onPressed:
                      () {} /*{
                  var url = Uri.parse(
                      'https://safetyout.herokuapp.com/chat/' + chatId);
                  http.delete(url).then((res) {
                    if (res.statusCode == 200) {
                      print("OK");
                      Navigator.of(context).pop();
                      Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              Profile())); //Tornar a profile
                    } else {
                      print(res.statusCode);
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              contentPadding:
                                  EdgeInsets.fromLTRB(24, 20, 24, 0),
                              content: SingleChildScrollView(
                                  child: ListBody(
                                children: <Widget>[
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate("Error_de_xarxa"),
                                      style: TextStyle(
                                          fontSize: Constants.m(context))),
                                ],
                              )),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                      AppLocalizations.of(context)
                                          .translate("Acceptar"),
                                      style: TextStyle(
                                          color: Constants.black(context))),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                    }
                  }).catchError((err) {
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
                                    style: TextStyle(
                                        fontSize: Constants.m(context))),
                              ],
                            )),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                    AppLocalizations.of(context)
                                        .translate("Acceptar"),
                                    style: TextStyle(
                                        color: Constants.black(context))),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  });
                },*/
                  ),
              TextButton(
                child: Text(
                    AppLocalizations.of(context).translate("Cancel·lar"),
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
  void initState() {
    super.initState();
    getInfoBombolla();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: Constants.xs(context)),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: Constants.xxs(context)),
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.arrow_back_ios_rounded,
                          size: 32 /
                              (MediaQuery.of(context).size.width < 380
                                  ? 1.3
                                  : 1),
                          color: Constants.black(context)),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Visibility(
                    visible: MediaQuery.of(context).viewInsets.bottom == 0,
                    child: Text("Configurar Bombolla",
                        style: TextStyle(
                            color: Constants.darkGrey(context),
                            fontSize: Constants.xl(context),
                            fontWeight: Constants.bolder)),
                  ),
                ),
                Align(
                  // BotoCrearBombolla
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: Constants.xxs(context)),
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {},
                      child: Icon(Icons.check,
                          size: 32 /
                              (MediaQuery.of(context).size.width < 380
                                  ? 1.3
                                  : 1),
                          color: Constants.black(context)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.only(
                      top: Constants.v7(context), left: Constants.h7(context)),
                  child: Text(
                    AppLocalizations.of(context).translate('Nom_Bombolla'),
                    style: TextStyle(
                        color: Constants.black(context),
                        fontSize: Constants.m(context),
                        fontWeight: Constants.bold),
                  ))),
          Padding(
            padding: EdgeInsets.fromLTRB(Constants.h7(context),
                Constants.v1(context), Constants.h7(context), 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RawInput(
                  labelText:
                      AppLocalizations.of(context).translate("Nom_Bombolla"),
                  onChanged: (value) => setState(() {
                    bubbleName = value;
                  }),
                )
              ],
            ),
          ),
        ])),
        bottomSheet: (adminId != userId) == true
            ? SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: Constants.v7(context)),
                      child: InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          onTap: () => outOfBubble(),
                          child: Text("Sortir de la bombolla",
                              style: TextStyle(
                                  fontSize: Constants.m(context),
                                  fontWeight: Constants.bold,
                                  color: Constants.red(context)))),
                    ),
                  ],
                ),
              )
            : Container() //Boton eliminar bombolla
        );
  }
}
