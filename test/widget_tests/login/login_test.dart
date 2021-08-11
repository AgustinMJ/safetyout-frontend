import 'package:app/app_localizations.dart';
import 'package:app/routes/router.dart';
import 'package:app/widgets/email_input.dart';
import 'package:app/widgets/password_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'login.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

final mockObserver = MockNavigatorObserver();

// Mètode per fer funcionar la nostra pantalla correctament com si estigues al Widget root
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
      onGenerateRoute: AppRouter.generateRoute,
      home: child,
      navigatorObservers: [mockObserver],
    ),
  );
}

void main() {
  // Grup de tests per la pantalla de login
  group('Log In Page Widget Tests', () {
    testWidgets('Successful Log In', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(child: Login()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EmailInput), 'email');
      expect(find.text('email'), findsOneWidget);
      await tester.enterText(find.byType(PasswordInput), 'pwd');
      expect(find.text('pwd'), findsOneWidget);
      await tester.tap(find.text('Iniciar_sessio'));
      verify(mockObserver.didPush(any, any));
    });

    testWidgets('Wrong Credentials', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(child: Login()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EmailInput), 'wrongEmail');
      expect(find.text('wrongEmail'), findsOneWidget);
      await tester.enterText(find.byType(PasswordInput), 'wrongPwd');
      expect(find.text('wrongPwd'), findsOneWidget);
      await tester.tap(find.text('Iniciar_sessio'));
      await tester.pumpAndSettle();
      expect(find.text('Els_credencials_són_incorrectes'), findsOneWidget);
    });

    testWidgets('Network Error', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(child: Login()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EmailInput), 'network error');
      expect(find.text('network error'), findsOneWidget);
      await tester.enterText(find.byType(PasswordInput), 'wrongPwd');
      expect(find.text('wrongPwd'), findsOneWidget);
      await tester.tap(find.text('Iniciar_sessio'));
      await tester.pumpAndSettle();
      expect(find.text('Error de xarxa'), findsOneWidget);
    });

    testWidgets('Go to forgotten password', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(makeTestableWidget(child: Login()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Has_oblidat_la_contrasenya'));
      verify(mockObserver.didPush(any, any));
      await tester.pumpAndSettle();
      expect(find.text('Recuperar_contrassenya'), findsOneWidget);
    });

    testWidgets('Go to sign up', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(makeTestableWidget(child: Login()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Registrat'));
      verify(mockObserver.didPush(any, any));
      await tester.pumpAndSettle();
      expect(find.text('Registre_Usuari'), findsOneWidget);
    });
  });
}
