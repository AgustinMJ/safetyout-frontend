import 'dart:convert';

import 'package:app/defaults/constants.dart';
import 'package:app/models/contactChat.dart';
import 'package:app/storage/secure_storage.dart';

import 'package:app/widgets/email_input.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_localizations.dart';
import 'package:http/http.dart' as http;

import 'consultarperfil.dart';

class Contacts extends StatefulWidget {
  Contacts({Key key}) : super(key: key);

  @override
  _Contacts createState() => _Contacts();
}

class _Contacts extends State<Contacts> {
  List<Contact> Contactos = [];
  List<String> ContactoSolicitudName = [];
  List<String> ContactoSolicitudID = [];
  List<String> ContactoSolicitudPhoto = [];
  String email;
  FocusNode pwdFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    getSolicituds();
    getContactes();
  }

  void getSolicituds() {
    ContactoSolicitudName.clear();
    ContactoSolicitudID.clear();
    SecureStorage.readSecureStorage('SafetyOUT_UserId').then((id) {
      var url2 = Uri.parse(
          'https://safetyout.herokuapp.com/user/' + id + '/friendRequests');
      http.get(url2).then((res) {
        if (res.statusCode == 200) {
          Map<String, dynamic> body = jsonDecode(res.body);
          setState(() {
            body["friendRequests"].forEach((f) {
              var urlName = Uri.parse('https://safetyout.herokuapp.com/user/' +
                  f['user_id_request']);
              http.get(urlName).then((resName) {
                if (resName.statusCode == 200) {
                  Map<String, dynamic> bodyName = jsonDecode(resName.body);
                  Map<String, dynamic> user = bodyName["user"];
                  setState(() {
                    ContactoSolicitudName.add(
                        user['name'] + " " + user["surnames"]);
                    ContactoSolicitudID.add(f['_id']);
                    ContactoSolicitudPhoto.add(user['profileImage']);
                  });
                }
              });
            });
          });
        }
      });
    });
  }

  void getContactes() {
    Contactos.clear();
    SecureStorage.readSecureStorage('SafetyOUT_UserId').then((id) {
      var url2 =
          Uri.parse('https://safetyout.herokuapp.com/user/' + id + '/friends');
      http.get(url2).then((res) {
        if (res.statusCode == 200) {
          Map<String, dynamic> body = jsonDecode(res.body);
          setState(() {
            body["friends"].forEach((f) {
              String userid = f["userId"].toString();
              var urlName =
                  Uri.parse('https://safetyout.herokuapp.com/user/' + userid);
              http.get(urlName).then((resName) {
                if (resName.statusCode == 200) {
                  Map<String, dynamic> bodyName = jsonDecode(resName.body);
                  Map<String, dynamic> user = bodyName["user"];
                  setState(() {
                    Contact c = Contact(
                        name: user['name'] + " " + user["surnames"],
                        photoUrl: user['profileImage'],
                        destUserId: userid);
                    Contactos.add(c);
                  });
                  setState(() {
                    Contactos.sort((a, b) =>
                        a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                  });
                }
              });
            });
          });
        }
      });
    });
  }

  void acceptarSolicitud(BuildContext context, int index) {
    var url = Uri.parse('https://safetyout.herokuapp.com/friendRequest/' +
        ContactoSolicitudID[index] +
        '/accept');
    http.post(url).then((res) {
      if (res.statusCode == 200) {
        getSolicituds();
        getContactes();
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
    });
  }

  void rebutjarSolicitud(BuildContext context, int index) {
    var url = Uri.parse('https://safetyout.herokuapp.com/friendRequest/' +
        ContactoSolicitudID[index] +
        '/deny');
    http.post(url).then((res) {
      if (res.statusCode == 200) {
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
    });
  }

  void submitEnviar(BuildContext context) {
    var url = Uri.parse('https://safetyout.herokuapp.com/user?email=' + email);
    http.get(url).then((res) {
      if (res.statusCode == 200) {
        //Ventana informant sol·licitud pendent
        Map<String, dynamic> body = jsonDecode(res.body);
        var url1 = Uri.parse('https://safetyout.herokuapp.com/friendRequest');
        SecureStorage.readSecureStorage('SafetyOUT_UserId').then((id) {
          http.post(url1, body: {
            'user_id_request': id,
            'user_id_requested': body["id"]
          }).then((res) {
            if (res.statusCode == 201) {
              Navigator.of(context).pop();
              body = jsonDecode(res.body);

              int achievementId = body["trophy"];
              String achievementIcon;
              String achievementText;

              if (achievementId != -1) {
                switch (achievementId) {
                  case 6:
                    achievementIcon = "friends bronze";
                    achievementText = AppLocalizations.of(context)
                        .translate("Agrega 1 contacte");
                    break;
                  case 7:
                    achievementIcon = "friends silver";
                    achievementText = AppLocalizations.of(context)
                        .translate("Agrega 5 contactes");
                    break;
                  case 8:
                    achievementIcon = "friends gold";
                    achievementText = AppLocalizations.of(context)
                        .translate("Agrega 25 contactes");
                    break;
                  case 9:
                    achievementIcon = "friends platinum";
                    achievementText = AppLocalizations.of(context)
                        .translate("Agrega 50 contactes");
                    break;
                  case 10:
                    achievementIcon = "friends diamond";
                    achievementText = AppLocalizations.of(context)
                        .translate("Agrega 100 contactes");
                    break;
                }

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
                                AppLocalizations.of(context)
                                    .translate("Acceptar"),
                                style:
                                    TextStyle(color: Constants.black(context))),
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
                                  .translate("Sol·licitud_pendent"),
                              style: TextStyle(
                                  fontSize: Constants.m(context),
                                  color: Constants.black(context))),
                        ],
                      )),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                              AppLocalizations.of(context)
                                  .translate("Acceptar"),
                              style:
                                  TextStyle(color: Constants.black(context))),
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
                  Text(AppLocalizations.of(context).translate("Error de xarxa"),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Flexible(
          //Solicitus de contacte
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
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage((ContactoSolicitudPhoto[
                                              index] !=
                                          '' &&
                                      ContactoSolicitudPhoto[index] != null)
                                  ? ContactoSolicitudPhoto[index]
                                  :
                                  //Imagen de prueba, se colocará la imagen del usuario
                                  "https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg"))),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                          padding: EdgeInsets.only(left: Constants.h2(context)),
                          child: Text(
                            ContactoSolicitudName[index],
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                          )),
                    ),
                    Expanded(
                        flex: 1,
                        //Acceptar contacte
                        child: IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            icon: Icon(Icons.check, color: Colors.green),
                            iconSize: Constants.w6(context),
                            onPressed: () {
                              acceptarSolicitud(context, index);
                            })),
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
              itemCount: ContactoSolicitudName.length,
            ),
          ),
        ),
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
                        AppLocalizations.of(context)
                            .translate('Afegeix_contacte'),
                        style: TextStyle(
                            fontSize: Constants.xs(context),
                            fontWeight: Constants.bolder,
                            color: Constants.black(context)),
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                                    title: Text(
                                        'Envia una sol·licitud de contacte'),
                                    titleTextStyle: TextStyle(
                                        color: Constants.black(context),
                                        fontSize: Constants.m(context),
                                        fontWeight: Constants.bolder),
                                    content: Row(
                                      children: [
                                        EmailInput(
                                          labelText: AppLocalizations.of(
                                                  context)
                                              .translate("Correu_electronic"),
                                          prefixIcon:
                                              FontAwesomeIcons.solidUser,
                                          onChanged: (val) => setState(() {
                                            email = val;
                                          }),
                                          onSubmitted: (val) =>
                                              pwdFocusNode.requestFocus(),
                                        ),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                            AppLocalizations.of(context)
                                                .translate('Cancel·lar'),
                                            style:
                                                TextStyle(color: Colors.red)),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop('Cancel·lar');
                                        },
                                      ),
                                      TextButton(
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .translate('Enviar'),
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                          onPressed: () => setState(() {
                                                submitEnviar(context);
                                              }))
                                    ]));
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
        ),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(
                top: Constants.v2(context),
                //left: Constants.h7(context),
                right: Constants.h7(context)),
            child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => Divider(
                      height: 20,
                      thickness: 2,
                    ),
                itemCount: Contactos.length,
                itemBuilder: (context, index) {
                  return Container(
                      child: ListTile(
                          leading: Container(
                            width: Constants.w8(context),
                            height: Constants.w8(context),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage((Contactos[index]
                                                    .photoUrl !=
                                                '' &&
                                            Contactos[index].photoUrl != null)
                                        ? Contactos[index].photoUrl
                                        :
                                        //Imagen de prueba, se colocará la imagen del usuario
                                        "https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg"))),
                          ),
                          title: Text(Contactos[index].name,
                              style: TextStyle(
                                  color: Constants.black(context),
                                  fontWeight: Constants.bolder,
                                  fontSize: Constants.l(context))),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ConsultarPerfil(
                                        id: Contactos[index].destUserId)));
                          }));
                }
                /*itemBuilder: (_, index) =>
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  width: Constants.w8(context),
                  height: Constants.w8(context),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(fit: BoxFit.fill, image: NetworkImage(
                          //Imagen de prueba, se colocará la imagen del usuario
                          "https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg"))),
                ),
                Padding(
                  padding: EdgeInsets.only(left: Constants.h2(context)),
                  child: Text(Contactos[index]),
                )
              ]),*/

                ),
          ),
        )
      ]),
    ));
  }
}
