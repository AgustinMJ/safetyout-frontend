import 'dart:convert';

import 'package:app/defaults/constants.dart';
import 'package:app/storage/secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/novabombolla.dart';

import '../app_localizations.dart';
import 'package:http/http.dart' as http;
import 'configBombolla.dart';
import 'conversaBombolla.dart';

class Bubbles extends StatefulWidget {
  Bubbles({Key key}) : super(key: key);

  @override
  _Bubbles createState() => _Bubbles();
}

class _Bubbles extends State<Bubbles> {
  List<String> PompNames = [];
  List<String> PompIDs = [];
  List<String> SolPompIDs = [];
  List<String> SolPompNames = [];
  String userid;

  void getSolicituds() {
    SolPompNames.clear();
    SolPompIDs.clear();
    SecureStorage.readSecureStorage('SafetyOUT_UserId').then((id) {
      var url2 = Uri.parse(
          'https://safetyout.herokuapp.com/user/' + id + '/bubbleInvitations');
      http.get(url2).then((res) {
        if (res.statusCode == 200) {
          Map<String, dynamic> body = jsonDecode(res.body);
          setState(() {
            body["bubbleInvitations"].forEach((bI) {
              Map<String, dynamic> bInvitantion = bI;
              var urlName = Uri.parse(
                  'https://safetyout.herokuapp.com/bubble/' +
                      bInvitantion['bubble_id']);
              http.get(urlName).then((resName) {
                if (resName.statusCode == 200) {
                  Map<String, dynamic> bodyName = jsonDecode(resName.body);
                  Map<String, dynamic> binfo = bodyName["bubble"];
                  setState(() {
                    SolPompNames.add(binfo['name']);
                    SolPompIDs.add(bInvitantion['_id']);
                  });
                }
              });
            });
          });
        }
      });
    });
  }

  void getBombolles() {
    PompNames.clear();
    PompIDs.clear();
    SecureStorage.readSecureStorage('SafetyOUT_UserId').then((id) {
      userid = id;
      var url2 =
          Uri.parse('https://safetyout.herokuapp.com/user/' + id + '/bubbles');
      http.get(url2).then((res) {
        if (res.statusCode == 200) {
          Map<String, dynamic> body = jsonDecode(res.body);
          setState(() {
            body["bubbles"].forEach((b) {
              Map<String, dynamic> bubble = b;
              PompNames.add(bubble['name']);
              PompIDs.add(b['_id']);
            });
          });
        }
      });
    });
  }

  void acceptarSolicitud(BuildContext context, int index) {
    var url = Uri.parse('https://safetyout.herokuapp.com/bubbleInvitation/' +
        SolPompIDs[index] +
        '/accept');
    http.post(url).then((res) {
      if (res.statusCode == 200) {
        getSolicituds();
        getBombolles();

        Map<String, dynamic> body = jsonDecode(res.body);
        int achievementId = body["trophy"];

        if (achievementId == 28) {
          String achievementIcon = "bubble master";
          String achievementText =
              AppLocalizations.of(context).translate("Entra en una bombolla");
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
                              achievementIcon +
                              ".png")),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            Constants.h1(context),
                            Constants.v1(context),
                            Constants.h1(context),
                            Constants.v1(context)),
                        child: Text(achievementText),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            Constants.h1(context),
                            Constants.v1(context),
                            Constants.h1(context),
                            Constants.v1(context)),
                        child: Text(
                            AppLocalizations.of(context)
                                .translate("Nou assoliment!"),
                            style: TextStyle(
                                color: Constants.black(context),
                                fontWeight: Constants.bold)),
                      )
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
                            .translate("Sol·licitud_acceptada"),
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
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                content: SingleChildScrollView(
                    child: ListBody(
                  children: <Widget>[
                    Text("Error " + res.statusCode.toString(),
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
    });
  }

  void rebutjarSolicitud(BuildContext context, int index) {
    var url = Uri.parse('https://safetyout.herokuapp.com/friendRequest/' +
        SolPompIDs[index] +
        '/deny');
    http.post(url).then((res) {
      if (res.statusCode == 200) {
        getSolicituds();
        getBombolles();
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
                            .translate("Sol·licitud_rebutjada"),
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
    });
  }

  @override
  void initState() {
    super.initState();
    getSolicituds();
    getBombolles();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Flexible(
        child: Padding(
          padding: EdgeInsets.only(
              top: Constants.v2(context),
              left: Constants.h7(context),
              right: Constants.h7(context)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (_, index) => Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: Constants.w8(context), //Constants.w9(context),
                    height: Constants.w8(context), //Constants.w9(context),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(fit: BoxFit.fill, image: NetworkImage(
                            //Imagen de prueba, se colocará la imagen del usuario
                            "https://cdn.iconscout.com/icon/free/png-256/water-bubble-1124802.png"))),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                        padding: EdgeInsets.only(left: Constants.h2(context)),
                        child: Text(
                          SolPompNames[index],
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        )),
                  ),
                  IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(Icons.check, color: Colors.green),
                      iconSize: Constants.w6(context),
                      onPressed: () {
                        acceptarSolicitud(context, index);
                      }),
                  IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(Icons.close, color: Colors.red),
                      iconSize: Constants.w6(context),
                      onPressed: () {
                        rebutjarSolicitud(context, index);
                      })
                ]),
            separatorBuilder: (_, __) => Divider(
              height: 20,
              thickness: 2,
            ),
            itemCount: SolPompNames.length,
          ),
        ),
      ), //Solicitudes DONE
      Container(
        child: Padding(
          padding: EdgeInsets.only(
              top: Constants.v2(context),
              left: Constants.h7(context),
              right: Constants.v7(context)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              //Boton editar perfil
              Expanded(
                child: Container(
                  child: TextButton(
                    child: Text(
                      AppLocalizations.of(context).translate('Nova_Bombolla'),
                      style: TextStyle(
                          fontSize: Constants.xs(context),
                          fontWeight: Constants.bolder,
                          color: Constants.black(context)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => newBubble()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Constants.trueWhite(context),
                        textStyle: TextStyle(
                          color: Constants.black(context),
                        ),
                        side: BorderSide(color: Constants.black(context)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ), //BotoCrearBombolla DONE
      Flexible(
          child: Padding(
              padding: EdgeInsets.only(
                  top: Constants.v2(context),
                  left: Constants.h1(context),
                  right: Constants.h1(context)),
              child: ListView.separated(
                  separatorBuilder: (_, __) => Divider(),
                  itemCount: PompNames.length,
                  itemBuilder: (context, index) => ListTile(
                        leading: Container(
                            width: Constants.w9(context),
                            height: Constants.w9(context),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(image: NetworkImage(
                                    //Imagen de prueba, se colocará la imagen del usuario
                                    "https://cdn.iconscout.com/icon/free/png-256/water-bubble-1124802.png")))),
                        title: Text(
                          PompNames[index],
                          style: TextStyle(
                              color: Constants.black(context),
                              fontWeight: Constants.bolder,
                              fontSize: Constants.l(context)),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ConversaBubble(
                                      BubbleId: PompIDs[index],
                                      UserId: userid)));
                        },
                        onLongPress: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ConfigBubble(
                                      BubbleId: PompIDs[index],
                                      UserId: userid)));
                        },
                      )))) //Lista DONE?
    ]));
  }
}
