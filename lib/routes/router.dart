import 'package:app/pages/app.dart';
import 'package:app/pages/login.dart';
import 'package:app/pages/profile.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String app = '/';
  static const String login = '/login';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case app:
        return PageRouteBuilder(pageBuilder: (_, __, ___) => App());
        break;
      case login:
        return PageRouteBuilder(pageBuilder: (_, __, ___) => Login());
        break;
      case profile:
        return PageRouteBuilder(pageBuilder: (_, __, ___) => Profile());
        break;
      default:
        return null;
    }
  }
}
