import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'submit_login.dart';

@GenerateMocks([http.Client])
void main() {
  group('Login Function Unit Test', () {
    test('Login Suceeds', () async {
      expect(await submitLogin('agus@gmail.com', 'Agus1234'),
          isA<Map<String, dynamic>>());
    });

    test('Wrong credentials', () async {
      expect(submitLogin('wrongEmail@gmail.com', 'Wrong1234'), throwsException);
    });
  });
}
