class LoginMock {
  Map<String, dynamic> post(Uri url, {Map<String, dynamic> body}) {
    final String email = body['email'];
    final String pwd = body['password'];
    if (email == 'network error') {
      return {'body': {}, 'statusCode': 500};
    } else if (email != 'email' || pwd != 'pwd') {
      return {'body': {}, 'statusCode': 401};
    } else if (email == 'email' || pwd == 'pwd') {
      return {
        'body': {'token': 'token', 'userId': 'userId'},
        'statusCode': 200
      };
    }
    return {'body': {}, 'statusCode': 500};
  }
}
