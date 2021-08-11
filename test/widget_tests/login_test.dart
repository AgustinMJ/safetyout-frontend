import 'package:app/app_localizations.dart';
import 'package:app/pages/login.dart';
import 'package:app/widgets/email_input.dart';
import 'package:app/widgets/password_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget makeTestableWidget({Widget child}) {
  return MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      locale: Locale('ca'),
      supportedLocales: [
        Locale('en', ''),
        Locale('ca', ''),
        Locale('es', ''),
      ],
      localizationsDelegates: [
        AppLocalizationsDelegate(isTest: true),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: child,
    ),
  );
}

void main() {
  group('Log In Page Widget Tests', () {
    testWidgets('Successful Log In', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(makeTestableWidget(child: Login()));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(EmailInput), 'agustinmillanjimenez@gmail.com');
      expect(find.text('agustinmillanjimenez@gmail.com'), findsOneWidget);
      await tester.enterText(find.byType(PasswordInput), 'Pepito23');
      expect(find.text('Pepito23'), findsOneWidget);
      await tester.tap(find.byKey(Key('loginButton')));
    });
    testWidgets('Go to forgotten password', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(makeTestableWidget(child: Login()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Has_oblidat_la_contrasenya'));
    });
    testWidgets('Go to sign up', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(makeTestableWidget(child: Login()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Registrat'));
    });
  });
}
