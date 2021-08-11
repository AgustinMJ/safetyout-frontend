import 'dart:convert';
//import 'dart:html';

import 'package:app/defaults/constants.dart';
import 'package:app/pages/profile.dart';
import 'package:app/storage/secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:app/models/chatModel.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;

import '../app_localizations.dart';

class Conversa extends StatefulWidget {
  Conversa({Key key, this.roomId, @required this.destUserId}) : super(key: key);
  final String destUserId;
  final String roomId;
  @override
  _Conversa createState() => _Conversa(this.roomId, this.destUserId);
}

class _Conversa extends State<Conversa> {
  _Conversa(this.roomId, this.destUserId);
  final textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> messages = [];
  IO.Socket socket;
  dynamic chatRoomId;
  bool isConected = false;
  String name;
  final String destUserId;
  final String roomId;
  bool connected = false;
  bool takenName = false;

  void sendMessage() {
    if (textController.text.toString().isNotEmpty) {
      SecureStorage.readSecureStorage('SafetyOUT_UserId').then((id) {
        socket.emit('message', {
          'chatRoom': chatRoomId.toString(),
          'author': id,
          'message': textController.text.toString()
        });
      });
    }
  }

  void handleMessage(dynamic data) {
    SecureStorage.readSecureStorage('SafetyOUT_UserId').then((id) {
      setState(() {
        messages.add(Message(
            messageContent: data[2].toString(),
            owner: data[1].toString() == id ? true : false));
        if (messages.length > 4) {
          _scrollController.animateTo(
            messages.length.toDouble() * 70.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 700),
          );
        }
        textController.clear();
      });
      print(data[2].toString());
    });
  }

  void handleJoin(dynamic data, String id) {
    chatRoomId = data["roomId"];
    int achievementId = data["trophy"];
    String achievementIcon;
    String achievementText;

    if (achievementId != -1) {
      switch (achievementId) {
        case 11:
          achievementIcon = "xat bronze";
          achievementText =
              AppLocalizations.of(context).translate("Comença 1 xat");
          break;
        case 12:
          achievementIcon = "xat silver";
          achievementText =
              AppLocalizations.of(context).translate("Comença 5 xats");
          break;
        case 13:
          achievementIcon = "xat golden";
          achievementText =
              AppLocalizations.of(context).translate("Comença 25 xats");
          break;
        case 14:
          achievementIcon = "xat platinum";
          achievementText =
              AppLocalizations.of(context).translate("Comença 50 xats");
          break;
        case 15:
          achievementIcon = "xat diamond";
          achievementText =
              AppLocalizations.of(context).translate("Comença 100 xats");
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
    isConected = true;
    print(chatRoomId);
    initializeChatList(id);
  }

  void initializeChatList(String id) {
    var url = Uri.parse('https://safetyout.herokuapp.com/chat/' +
        chatRoomId.toString() +
        "/messages");
    http.get(url).then((res) {
      if (res.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(res.body);
        List<dynamic> messagesaux = body["messages"];
        messagesaux.forEach((element) {
          Map<String, dynamic> message = element;
          setState(() {
            Message m = Message(
                messageContent: message["message"],
                owner: message["user_id"].toString() == id ? true : false);
            messages.add(m);
          });
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
      //Sale error por pantalla
      showDialog(
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
    });
  }

  void getName() {
    var url = Uri.parse('https://safetyout.herokuapp.com/user/' + destUserId);
    http.get(url).then((res) {
      if (res.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(res.body);
        Map<String, dynamic> user = body["user"];
        setState(() {
          name = user["name"] + " " + user["surnames"];
        });
        takenName = true;
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
    });
  }

  Function deleteChat = (BuildContext context, String chatId) {
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
                        .translate("Segur_que_vols_eliminar_la conversa"),
                    style: TextStyle(fontSize: Constants.m(context))),
              ],
            )),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context).translate("Eliminar"),
                    style: TextStyle(color: Constants.red(context))),
                onPressed: () {
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

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //destUserId = "609116e842fa750022ab15b7";
    //destUserId = Provider.of<RegState>(context, listen: false).getId;

    getName();

    SecureStorage.readSecureStorage('SafetyOUT_UserId').then((id) {
      try {
        socket = IO.io('https://safetyout.herokuapp.com/',
            OptionBuilder().setTransports(['websocket']).build());
        socket.onConnect((_) {
          print('connect');
          socket.emit('join', {
            'user1_id': id,
            'user2_id': destUserId //destUserId
          });
        });
        socket.on('joined', (data) => handleJoin(data, id));
        socket.on('message', (data) => handleMessage(data));
      } catch (e) {
        print(e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.white(context),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).push(
                  PageRouteBuilder(pageBuilder: (_, __, ___) => Profile()));
            },
          ),
          title: Text(name),
          actions: [
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  deleteChat(context, chatRoomId.toString());
                })
          ],
        ),
        body: Stack(
          children: <Widget>[
            ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10, bottom: 50),
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                    width: 80,
                    height: 80,
                    padding:
                        EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
                    child: Align(
                        alignment: (messages[index].owner == false
                            ? Alignment.topLeft
                            : Alignment.topRight),
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                //border: Border.all(color: Colors.black),
                                color: (messages[index].owner == false
                                    ? Constants.white(context)
                                    : Constants.green(context))),
                            padding: EdgeInsets.all(10),
                            child: Text(messages[index].messageContent,
                                style: TextStyle(
                                    color: (messages[index].owner == false
                                        ? Constants.black(context)
                                        : Colors.black),
                                    fontSize: Constants.s(context))))));
              },
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    color: Constants.trueWhite(context),
                    width: 500,
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 15.0, bottom: 15.0, right: 10.0),
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: TextField(
                                  controller: textController,
                                  decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)
                                          .translate("Escriu_un_missatge"),
                                      contentPadding:
                                          const EdgeInsets.only(left: 20.0),
                                      hintStyle:
                                          TextStyle(color: Colors.black54),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      filled: true,
                                      fillColor: Constants.lightGrey(context),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(30))),
                                ),
                              )),
                        ),
                        Padding(
                            padding: EdgeInsets.only(right: 15.0, bottom: 15.0),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: FloatingActionButton(
                                onPressed: () => setState(() => sendMessage()),
                                child: Icon(
                                  Icons.send,
                                  color: Constants.grey(context),
                                  size: 25,
                                ),
                                backgroundColor: Constants.lightGrey(context),
                                elevation: 0,
                              ),
                            )),
                      ],
                    )))
          ],
        ));
  }
}
