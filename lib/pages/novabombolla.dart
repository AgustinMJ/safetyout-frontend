import 'dart:convert';

import 'package:app/defaults/constants.dart';
import 'package:app/storage/secure_storage.dart';
import 'package:app/widgets/raw_input.dart';
import 'package:flutter/material.dart';

import '../app_localizations.dart';
import 'package:http/http.dart' as http;

class newBubble extends StatefulWidget {
  newBubble({Key key}) : super(key: key);

  @override
  _newBubble createState() => _newBubble();
}

class _newBubble extends State<newBubble> {
  static String nameBubble;
  List<String> Contactos = [];
  List<String> ContactosID = [];
  List<String> ContactosPhoto = [];
  static List<bool> Participants = List<bool>.empty(growable: true);
  int npart = 0;

  @override
  void initState() {
    super.initState();
    getContactes();
    Participants.clear();
  }

  void getContactes() {
    Contactos.clear();
    ContactosID.clear();
    SecureStorage.readSecureStorage('SafetyOUT_UserId').then((id) {
      var url2 =
          Uri.parse('https://safetyout.herokuapp.com/user/' + id + '/friends');
      http.get(url2).then((res) {
        if (res.statusCode == 200) {
          Map<String, dynamic> body = jsonDecode(res.body);
          setState(() {
            body["friends"].forEach((f) {
              var urlName = Uri.parse(
                  'https://safetyout.herokuapp.com/user/' + f["userId"]);
              http.get(urlName).then((resName) {
                if (resName.statusCode == 200) {
                  Map<String, dynamic> bodyName = jsonDecode(resName.body);
                  Map<String, dynamic> user = bodyName["user"];
                  setState(() {
                    Contactos.add(user['name'] + " " + user["surnames"]);
                    ContactosID.add(f["userId"]);
                    ContactosPhoto.add(user['profileImage']);
                  });
                }
              });
            });
          });
        }
      });
    });
  }

  void newBubble() {
    var url1 = Uri.parse('https://safetyout.herokuapp.com/bubble');
    SecureStorage.readSecureStorage('SafetyOUT_UserId').then((id) {
      http.post(url1, body: {'user_id': id, 'bubble_name': nameBubble}).then(
          (res) {
        Map<String, dynamic> body = jsonDecode(res.body);
        if (res.statusCode == 201) {
          Navigator.of(context).pop();
          var url2 =
              Uri.parse('https://safetyout.herokuapp.com/bubbleInvitation');
          for (int index = 0; index < Contactos.length; ++index) {
            if (Participants[index]) {
              http.post(url2, body: {
                'invitee_id': ContactosID[index],
                'bubble_id': body["bubble_id"],
                'invited_by_id': id
              });
            }
          }

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
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                  content: SingleChildScrollView(
                      child: ListBody(
                    children: <Widget>[
                      Text(body["message"],
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
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
                      child: Text(
                          AppLocalizations.of(context)
                              .translate("Nova_Bombolla"),
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
                        onTap: () {
                          newBubble();
                        },
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
            ), //Header DONE
            Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding: EdgeInsets.only(
                        top: Constants.v7(context),
                        left: Constants.h7(context)),
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
                      nameBubble = value;
                    }),
                  )
                ],
              ),
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding: EdgeInsets.only(
                        top: Constants.v7(context),
                        left: Constants.h7(context)),
                    child: Text(
                      AppLocalizations.of(context).translate('Participants') +
                          " (" +
                          npart.toString() +
                          ")",
                      style: TextStyle(
                          color: Constants.black(context),
                          fontSize: Constants.m(context),
                          fontWeight: Constants.bold),
                    ))),
            Flexible(
              child: Padding(
                  padding: EdgeInsets.only(
                      top: Constants.v2(context),
                      left: Constants.h1(context),
                      right: Constants.h1(context)),
                  child: ListView.separated(
                      separatorBuilder: (_, __) => Divider(),
                      itemCount: Contactos.length,
                      itemBuilder: (context, index) {
                        if (index >= Participants.length) {
                          Participants.add(false);
                        }
                        return Container(
                            color: Participants[index]
                                ? Constants.lightGrey(context)
                                : null,
                            child: ListTile(
                                leading: Container(
                                    width: Constants.w9(context),
                                    height: Constants.w9(context),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            //fit: BoxFit.cover,
                                            image: NetworkImage((ContactosPhoto[
                                                            index] !=
                                                        '' &&
                                                    ContactosPhoto[index] !=
                                                        null)
                                                ? ContactosPhoto[index]
                                                :
                                                //Imagen de prueba, se colocará la imagen del usuario
                                                "https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg")))),
                                title: Text(
                                  Contactos[index],
                                  style: TextStyle(
                                      color: Constants.black(context),
                                      fontWeight: Constants.bolder,
                                      fontSize: Constants.l(context)),
                                ),
                                trailing: Participants[index]
                                    ? Icon(Icons.close,
                                        color: Constants.black(context))
                                    : null,
                                onTap: () {
                                  setState(() {
                                    festoogle(index);
                                  });
                                }));
                      })),
            ) //Llista Participants DONE
          ],
        ),
      ),
    );
  }

  void festoogle(int index) {
    if (Participants[index]) {
      Participants[index] = false;
      --npart;
    } else {
      Participants[index] = true;
      ++npart;
    }
  }
}
