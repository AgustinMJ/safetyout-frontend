import 'package:flutter/cupertino.dart';

class Contact {
  String destUserId;
  String name;
  String photoUrl;
  String lastMessage;
  Contact(
      {this.destUserId, this.photoUrl, @required this.name, this.lastMessage});
}
