import 'package:flutter/material.dart';

class AuthState extends ChangeNotifier {
  bool logedIn = false;

  bool get logInState => logedIn;

  void userLogedIn() {
    this.logedIn = true;
  }
}
