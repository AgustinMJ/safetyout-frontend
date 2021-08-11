import 'package:flutter/cupertino.dart';

class Message {
  String messageContent;
  bool owner;
  String author;
  Message({@required this.messageContent, @required this.owner, this.author});
}
