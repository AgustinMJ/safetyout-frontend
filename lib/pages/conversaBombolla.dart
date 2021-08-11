import 'dart:convert';
//import 'dart:html';

import 'package:app/defaults/constants.dart';
import 'package:app/storage/secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:app/models/chatModel.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;

import '../app_localizations.dart';
import 'configBombolla.dart';

class ConversaBubble extends StatefulWidget {
  ConversaBubble({Key key, @required this.BubbleId, this.UserId})
      : super(key: key);
  final String BubbleId;
  final String UserId;
  @override
  _ConversaBubble createState() => _ConversaBubble(this.BubbleId, this.UserId);
}

class _ConversaBubble extends State<ConversaBubble> {
  _ConversaBubble(this.bubbleId, this.userId);
  final String bubbleId;
  final String userId;
  final textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> messages = [];
  IO.Socket socket;
  dynamic chatRoomId;
  bool isConected = false;
  String bubbleName;

  void getName() {
    var url = Uri.parse('https://safetyout.herokuapp.com/bubble/' + bubbleId);
    http.get(url).then((res) {
      if (res.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(res.body);
        body = body['bubble'];
        setState(() {
          bubbleName = body['name'];
        });
        print("hola");
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
                  Text(AppLocalizations.of(context).translate("Error_de_xarxa"),
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

  void sendMessage() {
    if (textController.text.toString().isNotEmpty) {
      socket.emit('message', {
        'chatRoom': chatRoomId.toString(),
        'author': userId,
        'message': textController.text.toString()
      });
    }
  }

  void handleJoin(dynamic data, String id) {
    chatRoomId = data["roomId"];
    isConected = true;
    print(chatRoomId);
    initializeChatList(id);
  }

  void handleMessage(dynamic data) {
    setState(() {
      messages.add(Message(
          messageContent: data[2].toString(),
          owner: data[1].toString() == userId ? true : false,
          author: data[3].toString()));
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
  }

  void initializeChatList(String id) {
    var url = Uri.parse('https://safetyout.herokuapp.com/chat/' +
        chatRoomId.toString() +
        "/messages");
    http.get(url).then((res) {
      if (res.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(res.body);
        print(body);
        List<dynamic> messagesaux = body["messages"];
        messagesaux.forEach((element) {
          Map<String, dynamic> message = element;
          setState(() {
            Message m = Message(
                messageContent: message["message"],
                owner: message["user_id"].toString() == id ? true : false,
                author: message["username"].toString());
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
                  Text(AppLocalizations.of(context).translate("Error_de_xarxa"),
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

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    getName();

    SecureStorage.readSecureStorage('SafetyOUT_UserId').then((id) {
      try {
        socket = IO.io('https://safetyout.herokuapp.com/',
            OptionBuilder().setTransports(['websocket']).build());
        socket.onConnect((_) {
          print('connect');
          socket.emit('joinBubbleChat', {
            'bubble_id': bubbleId,
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
              Navigator.of(context).pop();
            },
          ),
          title: Text(bubbleName),
          actions: [
            IconButton(
              icon: Icon(Icons.more_horiz),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ConfigBubble(BubbleId: bubbleId, UserId: userId)));
              },
            ),
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
                        child: messages[index].owner == true
                            ? Container(
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
                                        fontSize: Constants.s(context))))
                            : Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    //border: Border.all(color: Colors.black),
                                    color: (messages[index].owner == false
                                        ? Constants.white(context)
                                        : Constants.green(context))),
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Container(
                                      child: Text(messages[index].author,
                                          style: TextStyle(
                                              color: Constants.black(context),
                                              fontSize: Constants.s(context),
                                              fontWeight: Constants.bolder)),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Text(
                                          messages[index].messageContent,
                                          style: TextStyle(
                                              color: Constants.black(context),
                                              fontSize: Constants.s(context))),
                                    ),
                                  ],
                                ))));
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
