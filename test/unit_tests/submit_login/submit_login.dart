import 'dart:convert';

import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> submitLogin(String email, String pwd) async {
  var url = Uri.parse('https://safetyout.herokuapp.com/user/login');
  final res = await http.post(url, body: {
    'email': email,
    'password': pwd,
  });
  if (res.statusCode == 200) {
    //Guardar key
    Map<String, dynamic> body = jsonDecode(res.body);
    return body;
  } else if (res.statusCode == 404 || res.statusCode == 401) {
    throw Exception('Credencials incorrectes');
  } else {
    throw Exception('Error de xarxa');
  }
}
