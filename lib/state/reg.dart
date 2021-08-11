import 'package:flutter/material.dart';

class RegState extends ChangeNotifier {
  String name = '';
  String email = '';
  String gender = '';
  DateTime birthdate;
  String id = '';

  String get getName => name;
  String get getEmail => email;
  String get getGender => gender;
  DateTime get getBirthdate => birthdate;

  void setName(String name) {
    this.name = name;
  }

  void setEmail(String email) {
    this.email = email;
  }

  void setGender(String gender) {
    this.gender = gender;
  }

  void setBirthdate(DateTime birthdate) {
    this.birthdate = birthdate;
  }
}
