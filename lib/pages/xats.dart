import 'dart:convert';

import 'package:app/defaults/constants.dart';
import 'package:app/pages/newchat.dart';
import 'package:app/storage/secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:app/models/contactChat.dart';
import 'package:http/http.dart' as http;

import '../app_localizations.dart';
import 'conversa.dart';

class Chats extends StatefulWidget {
  Chats({Key key}) : super(key: key);

  @override
  _Chats createState() => _Chats();
}

class _Chats extends State<Chats> {
  final textController = TextEditingController();

  List<Contact> chats = [
    //Contact(name: 'Joel', lastMessage: "Hola que tal"),
    //Contact(name: 'Joel2', lastMessage: "Hola que tal2")
  ];

  /*@override
  void dispose() {
    super.dispose();
  }*/

  @override
  void initState() {
    super.initState();
    SecureStorage.readSecureStorage('SafetyOUT_UserId').then((id) {
      var url =
          Uri.parse('https://safetyout.herokuapp.com/user/' + id + '/chats');
      http.get(url).then((res) {
        if (res.statusCode == 200) {
          Map<String, dynamic> body = jsonDecode(res.body);
          dynamic chatList = body["chats"];
          chatList.forEach((element) {
            Map<String, dynamic> chat = element;
            String userid = chat["user2_id"].toString();
            if (userid == id) userid = chat["user1_id"].toString();
            var url2 =
                Uri.parse('https://safetyout.herokuapp.com/user/' + userid);
            http.get(url2).then((res) {
              if (res.statusCode == 200) {
                Map<String, dynamic> body2 = jsonDecode(res.body);
                Map<String, dynamic> user2 = body2["user"];
                setState(() {
                  print(userid);
                  Contact c = Contact(
                      destUserId: userid,
                      photoUrl: user2['profileImage'],
                      name: user2["name"].toString() + " " + user2["surnames"]);
                  chats.add(c);
                });
                chats.sort((a, b) =>
                    a.name.toLowerCase().compareTo(b.name.toLowerCase()));
              } else {
                //print(res.statusCode);
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
            });
          });
        } else {
          (print(res.statusCode));
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
        }
      }).catchError((err) {
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

  @override
  Widget build(BuildContext context) {
    if (chats.isNotEmpty) {
      return Expanded(
          child: Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(pageBuilder: (_, __, ___) => NewChat()),
              );
            },
            child: const Icon(Icons.chat_outlined, color: Colors.black),
            backgroundColor: Constants.green(context)),
        body: Stack(
          children: [
            ListView.separated(
                padding: EdgeInsets.only(
                    top: Constants.a5(context), bottom: Constants.a5(context)),
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemCount: chats.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                      child: ListTile(
                    leading: Container(
                      width: Constants.w7(context),
                      height: Constants.w7(context),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage((chats[index].photoUrl !=
                                          '' &&
                                      chats[index].photoUrl != null)
                                  ? chats[index].photoUrl
                                  :
                                  //Imagen de prueba, se colocará la imagen del usuario
                                  "https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg"))),
                    ),
                    title: Text(
                      chats[index].name,
                      style: TextStyle(
                          color: Constants.black(context),
                          fontWeight: Constants.bolder,
                          fontSize: Constants.l(context)),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Conversa(
                                  destUserId: chats[index].destUserId)));
                    },
                  ));
                })
          ],
        ),
      ));
    } else {
      return Expanded(
          child: Scaffold(
              floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(pageBuilder: (_, __, ___) => NewChat()),
                    );
                  },
                  child: const Icon(Icons.chat_outlined, color: Colors.black),
                  backgroundColor: Constants.green(context)),
              body: Stack(children: [
                Padding(
                    padding: EdgeInsets.all(Constants.w6(context)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                AppLocalizations.of(context)
                                    .translate("Aixó_està_molt_tranquil"),
                                style: TextStyle(
                                    color: Constants.grey(context),
                                    fontSize: Constants.s(context),
                                    fontWeight: Constants.bolder))
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                top: Constants.a7(context),
                                bottom: Constants.a3(context)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset('assets/icons/park.svg',
                                    color: Constants.grey(context), height: 150)
                              ],
                            )),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  AppLocalizations.of(context).translate(
                                          "Inicia_un_xat_amb_un_dels_teus") +
                                      "\n" +
                                      AppLocalizations.of(context).translate(
                                          "contactes_polsant_el_botó_inferior"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Constants.grey(context),
                                      fontSize: Constants.s(context),
                                      fontWeight: Constants.bolder))
                            ]),
                      ],
                    )),
              ])));
    }
  }
}
