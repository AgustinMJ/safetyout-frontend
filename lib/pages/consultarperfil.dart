import 'dart:convert';

import 'package:app/app_localizations.dart';
import 'package:app/defaults/constants.dart';
import 'package:app/pages/assoliments_contacte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:app/storage/secure_storage.dart';
import 'package:app/pages/profile.dart';

class ConsultarPerfil extends StatefulWidget {
  ConsultarPerfil({Key key, @required this.id}) : super(key: key);
  final String id;

  @override
  _ConsultarPerfil createState() => _ConsultarPerfil(this.id);
}

class _ConsultarPerfil extends State<ConsultarPerfil> {
  _ConsultarPerfil(this.id);
  String name = '';
  String surnames = '';
  String photoUrl = '';
  final String id;

  Function deleteContact = (BuildContext context, String id) {
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
                        .translate("Segur_que_vols_eliminar_el_contacte"),
                    style: TextStyle(fontSize: Constants.m(context))),
              ],
            )),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context).translate("Eliminar"),
                    style: TextStyle(color: Constants.red(context))),
                onPressed: () {
                  SecureStorage.readSecureStorage('SafetyOUT_UserId')
                      .then((id1) {
                    var url = Uri.parse(
                        'https://safetyout.herokuapp.com/friendRequest/' +
                            id1 +
                            '/deleteFriend');
                    http.delete(url, body: {'friend_id': id}).then((res) {
                      if (res.statusCode == 201) {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (_, __, ___) => Profile()),
                        );
                      } else {
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
                    });
                  });
                },
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
  };

  void setName() {
    if (mounted) {
      var url = Uri.parse('https://safetyout.herokuapp.com/user/' + id);
      http.get(url).then((res) {
        if (res.statusCode == 200) {
          Map<String, dynamic> body = jsonDecode(res.body);
          Map<String, dynamic> user = body["user"];
          setState(() {
            name = user["name"];
            surnames = user["surnames"];
            photoUrl = user["profileImage"];
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

  void setTrophies() {}

  @override
  void initState() {
    super.initState();

    setName();

    setTrophies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Constants.xs(context)),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Icono back
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Constants.black(context),
                    iconSize: Constants.xxl(context),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              name == ''
                  ? Expanded(
                      child: Container(
                        decoration:
                            BoxDecoration(color: Constants.trueWhite(context)),
                        child: Center(
                          child: SpinKitFadingCube(
                              color: Colors.grey,
                              size: 40.0 /
                                  (MediaQuery.of(context).size.height < 700
                                      ? 1.3
                                      : MediaQuery.of(context).size.height < 800
                                          ? 1.15
                                          : 1)),
                        ),
                      ),
                    )
                  : Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: Constants.h7(context)),
                                child: Column(
                                  children: [
                                    //Imagen perfil
                                    Container(
                                      width: Constants.w9(context),
                                      height: Constants.w9(context),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(
                                                  //Imagen de prueba, se colocará la imagen del usuario
                                                  photoUrl != ''
                                                      ? photoUrl
                                                      :
                                                      //Imagen de prueba, se colocará la imagen del usuario
                                                      "https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg"))),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: Constants.h1(context),
                                    left: Constants.h1(context)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        //Nombre usuario
                                        SizedBox(
                                          width: Constants.w11(context),
                                          child: Text(
                                            name + ' ' + surnames,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: Constants.l(context),
                                              fontWeight: Constants.bolder,
                                            ),
                                            overflow: TextOverflow.clip,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        //Boton borrar contacto
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: Constants.v1(context)),
                                          child: Container(
                                            height: Constants.a6(context) +
                                                Constants.a2(context),
                                            width: Constants.w11(context),
                                            child: TextButton(
                                              child: Text(
                                                AppLocalizations.of(context)
                                                    .translate(
                                                        "Esborrar_contacte"),
                                                style: TextStyle(
                                                    fontSize:
                                                        Constants.xs(context),
                                                    fontWeight:
                                                        Constants.bolder,
                                                    color:
                                                        Constants.red(context)),
                                              ),
                                              onPressed: () {
                                                deleteContact(context, id);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  primary: Constants.trueWhite(
                                                      context),
                                                  textStyle: TextStyle(
                                                    color: Constants.black(
                                                        context),
                                                  ),
                                                  side: BorderSide(
                                                      color: Constants.black(
                                                          context)),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0))),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                              padding:
                                  EdgeInsets.only(top: Constants.h2(context)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Assoliments',
                                    style: TextStyle(
                                      color: Constants.black(context),
                                      fontSize: Constants.l(context),
                                      fontWeight: Constants.bolder,
                                    ),
                                  )
                                ],
                              )),
                          Expanded(child: AssolimentsContacte(id))
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
