import 'dart:convert';

import 'package:app/app_localizations.dart';
import 'package:app/defaults/constants.dart';
import 'package:app/pages/assoliments.dart';
import 'package:app/pages/edit_profile.dart';
import 'package:app/pages/profileconfig.dart';
import 'package:app/pages/bombolles.dart';
import 'package:app/pages/contactes.dart';
import 'package:app/pages/xats.dart';
import 'package:app/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

enum ProfileTab { CONTACTS, BUBBLES, CHATS }

class Profile extends StatefulWidget {
  Profile({Key key}) : super(key: key);

  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile> {
  String name = '';
  String surnames = '';
  String photoUrl = '';
  ProfileTab tab = ProfileTab.CONTACTS;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      SecureStorage.readSecureStorage('SafetyOUT_UserId').then((id) {
        var url = Uri.parse('https://safetyout.herokuapp.com/user/' + id);
        http.get(url).then((res) {
          print(res.statusCode);
          if (res.statusCode == 200) {
            Map<String, dynamic> body = jsonDecode(res.body);
            Map<String, dynamic> user = body["user"];
            setState(() {
              name = user["name"];
              surnames = user["surnames"];
              photoUrl = user["profileImage"];
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: Constants.h1(context)),
                  child: InkWell(
                    focusColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => Assoliments()),
                      );
                    },
                    child: SvgPicture.asset('assets/icons/trophy.svg',
                        color: Constants.black(context),
                        height: Constants.xxl(context)),
                  ),
                ),
                //Icono configuracion
                IconButton(
                  icon: const Icon(Icons.settings),
                  color: Constants.black(context),
                  iconSize: Constants.xxl(context),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (_, __, ___) => ProfileConfig()),
                    );
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
                              padding:
                                  EdgeInsets.only(left: Constants.h7(context)),
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
                                            image: NetworkImage(photoUrl != ''
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
                                      //Boton editar perfil
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: Constants.v1(context)),
                                        child: Container(
                                          height: Constants.a6(context) +
                                              Constants.a2(context),
                                          width: Constants.w10(context),
                                          child: TextButton(
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .translate("Editar_perfil"),
                                              style: TextStyle(
                                                  fontSize:
                                                      Constants.xs(context),
                                                  fontWeight: Constants.bolder,
                                                  color:
                                                      Constants.black(context)),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                    pageBuilder: (_, __, ___) =>
                                                        EditProfile(
                                                            name,
                                                            surnames,
                                                            photoUrl != ''
                                                                ? photoUrl
                                                                :
                                                                //Imagen de prueba, se colocará la imagen del usuario
                                                                "https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg")),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                                primary: Constants.trueWhite(
                                                    context),
                                                textStyle: TextStyle(
                                                  color:
                                                      Constants.black(context),
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
                          padding: EdgeInsets.fromLTRB(Constants.h7(context),
                              Constants.v7(context), Constants.h7(context), 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                focusColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    tab = ProfileTab.CONTACTS;
                                  });
                                },
                                child: Container(
                                  width: Constants.w9(context),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        bottom: Constants.v1(context)),
                                    decoration: tab == ProfileTab.CONTACTS
                                        ? BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Constants.black(
                                                        context),
                                                    width: 2)))
                                        : null,
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('Contactes'),
                                      style: TextStyle(
                                          color: tab == ProfileTab.CONTACTS
                                              ? Constants.black(context)
                                              : Constants.grey(context),
                                          fontSize: Constants.xs(context),
                                          fontWeight: Constants.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                focusColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    tab = ProfileTab.BUBBLES;
                                  });
                                },
                                child: Container(
                                  width: Constants.w9(context),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        bottom: Constants.v1(context)),
                                    decoration: tab == ProfileTab.BUBBLES
                                        ? BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Constants.black(
                                                        context),
                                                    width: 2)))
                                        : null,
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('Bombolles'),
                                      style: TextStyle(
                                          color: tab == ProfileTab.BUBBLES
                                              ? Constants.black(context)
                                              : Constants.grey(context),
                                          fontSize: Constants.xs(context),
                                          fontWeight: Constants.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                focusColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    tab = ProfileTab.CHATS;
                                  });
                                },
                                child: Container(
                                  width: Constants.w9(context),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        bottom: Constants.v1(context)),
                                    decoration: tab == ProfileTab.CHATS
                                        ? BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Constants.black(
                                                        context),
                                                    width: 2)))
                                        : null,
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('Xats'),
                                      style: TextStyle(
                                          color: tab == ProfileTab.CHATS
                                              ? Constants.black(context)
                                              : Constants.grey(context),
                                          fontSize: Constants.xs(context),
                                          fontWeight: Constants.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        tab == ProfileTab.CONTACTS
                            ? Contacts()
                            : tab == ProfileTab.BUBBLES
                                ? Bubbles()
                                : Chats(),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
