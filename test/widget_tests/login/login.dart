import 'package:app/app_localizations.dart';
import 'package:app/defaults/constants.dart';
import 'package:app/pages/app.dart';
import 'package:app/pages/recover_password/recover_email.dart';
import 'package:app/pages/signup/name.dart';
import 'package:app/widgets/password_input.dart';
import 'package:app/widgets/email_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'login_test.mocks.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  static String email = '';
  static String pwd = '';
  static bool activeButton = false;
  static bool isLoading = false;
  FocusNode pwdFocusNode = FocusNode();
  Function submitLogin = (BuildContext context) {};

  @override
  void initState() {
    super.initState();
    submitLogin = (BuildContext context) {
      isLoading = true;
      activeButton = false;
      var url = Uri.parse('https://safetyout.herokuapp.com/user/login');
      Map<String, dynamic> res = LoginMock().post(url, body: {
        'email': email,
        'password': pwd,
      });
      if (res['statusCode'] == 200) {
        print(res);
        //Guardar key
        /* SecureStorage.writeSecureStorage(
            'SafetyOUT_Token', res['body']["token"]);
        SecureStorage.writeSecureStorage(
            'SafetyOUT_Token', res['body']["userId"]); */
        Navigator.push(
          context,
          PageRouteBuilder(pageBuilder: (_, __, ___) => App()),
        );
        setState(() {
          isLoading = false;
          activeButton = true;
        });
      } else if (res['statusCode'] == 404 || res['statusCode'] == 401) {
        print(res);
        setState(() {
          isLoading = false;
          activeButton = true;
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                content: SingleChildScrollView(
                    child: ListBody(
                  children: <Widget>[
                    Text(
                        AppLocalizations.of(context)
                            .translate("Els_credencials_són_incorrectes"),
                        style: TextStyle(fontSize: Constants.m(context))),
                  ],
                )),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                        AppLocalizations.of(context).translate("Acceptar"),
                        style: TextStyle(color: Constants.black(context))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      } else {
        print(res);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                content: SingleChildScrollView(
                    child: ListBody(
                  children: <Widget>[
                    Text(
                        AppLocalizations.of(context)
                            .translate("Error de xarxa"),
                        style: TextStyle(fontSize: Constants.m(context))),
                  ],
                )),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                        AppLocalizations.of(context).translate("Acceptar"),
                        style: TextStyle(color: Constants.black(context))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
        setState(() {
          isLoading = false;
          activeButton = true;
        });
      }
    };
  }

  Function facebookLogin = () {};

  Function googleLogin = () {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              //Amaga el logo quan apareix el teclat per aprofitar l'espai
              Visibility(
                visible: MediaQuery.of(context).viewInsets.bottom == 0,
                child: Padding(
                  padding: EdgeInsets.only(top: Constants.xxl(context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('SafetyOUT',
                          style: TextStyle(
                            fontSize: 40 /
                                (MediaQuery.of(context).size.width < 380
                                    ? 1.3
                                    : 1),
                            fontWeight: Constants.bolder,
                            /* shadows: [
                            Shadow(
                              offset: Offset(0, 3),
                              blurRadius: 10,
                              color: Color.fromARGB(100, 0, 0, 0),
                            ),
                          ] */
                          )),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: MediaQuery.of(context).viewInsets.bottom == 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/logo.svg',
                      color: Constants.black(context),
                      height: 150 /
                          (MediaQuery.of(context).size.height < 700
                              ? 1.5
                              : MediaQuery.of(context).size.height < 800
                                  ? 1.3
                                  : 1),
                      width: 150 /
                          (MediaQuery.of(context).size.height < 700
                              ? 1.5
                              : MediaQuery.of(context).size.height < 800
                                  ? 1.3
                                  : 1),
                    )
                  ],
                ),
              ),
              Visibility(
                visible: MediaQuery.of(context).viewInsets.bottom == 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: Constants.v1(context)),
                      child: Text(
                          AppLocalizations.of(context).translate("Benvingut"),
                          style: TextStyle(
                              color: Constants.darkGrey(context),
                              fontSize: Constants.xxl(context),
                              fontWeight: Constants.bolder)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(Constants.h7(context),
                    Constants.v5(context), Constants.h7(context), 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    EmailInput(
                      labelText: AppLocalizations.of(context)
                          .translate("Correu_electronic"),
                      prefixIcon: FontAwesomeIcons.solidUser,
                      onChanged: (val) => setState(() {
                        email = val;
                        activeButton = email != '' && pwd != '';
                      }),
                      onSubmitted: (val) => pwdFocusNode.requestFocus(),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(Constants.h7(context),
                    Constants.v5(context), Constants.h7(context), 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PasswordInput(
                        focusNode: pwdFocusNode,
                        onSubmitted: (val) => email != '' && pwd != ''
                            ? setState(() {
                                submitLogin(context);
                              })
                            : () {},
                        onChanged: (val) => setState(() {
                              pwd = val;
                              activeButton = pwd != '' && email != '';
                            }),
                        labelText: AppLocalizations.of(context)
                            .translate("Contrasenya"))
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(Constants.h7(context),
                      Constants.v4(context), Constants.h7(context), 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => RecoverEmail()),
                            );
                          },
                          child: Text(
                              AppLocalizations.of(context)
                                  .translate("Has_oblidat_la_contrasenya"),
                              style: TextStyle(
                                  fontSize: Constants.m(context),
                                  fontWeight: Constants.bold,
                                  color: Constants.link(context)))),
                    ],
                  )),
              Padding(
                padding: EdgeInsets.fromLTRB(Constants.h7(context),
                    Constants.v4(context), Constants.h7(context), 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: Constants.a7(context),
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: activeButton
                                    ? [Color(0xFF84FCCD), Color(0xFFA7FF80)]
                                    : [Color(0xFF679080), Color(0xFF68865A)],
                                begin: FractionalOffset.centerLeft,
                                end: FractionalOffset.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 5),
                                  blurRadius: 10,
                                  color: Color.fromARGB(100, 0, 0, 0),
                                )
                              ]),
                          child: TextButton(
                              key: Key('loginButton'),
                              onPressed: () => email != '' && pwd != ''
                                  ? setState(() {
                                      submitLogin(context);
                                    })
                                  : () {},
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  )),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.transparent)),
                              child: isLoading
                                  ? SpinKitFadingCube(
                                      color: Colors.white,
                                      size: 20.0 /
                                          (MediaQuery.of(context).size.height <
                                                  700
                                              ? 1.3
                                              : MediaQuery.of(context)
                                                          .size
                                                          .height <
                                                      800
                                                  ? 1.15
                                                  : 1))
                                  : Text(
                                      AppLocalizations.of(context)
                                          .translate("Iniciar_sessio"),
                                      style: TextStyle(
                                          fontSize: Constants.m(context),
                                          fontWeight: Constants.bold,
                                          color:
                                              Constants.primaryDark(context)))),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: Constants.v3(context), bottom: Constants.v3(context)),
                child: Row(children: [
                  Expanded(
                      flex: 45,
                      child:
                          Container(height: 2, color: Constants.grey(context))),
                  Expanded(
                      flex: 15,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context).translate("O"),
                              style: TextStyle(
                                  fontSize: Constants.xl(context),
                                  fontWeight: Constants.bold)),
                        ],
                      )),
                  Expanded(
                      flex: 45,
                      child: Container(
                        height: 2,
                        color: Constants.grey(context),
                      )),
                ]),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    Constants.h7(context), 0, Constants.h7(context), 0),
                child: Row(children: [
                  Expanded(
                    flex: 45,
                    child: SizedBox(
                      height: Constants.a7(context),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 3),
                                blurRadius: 10,
                                color: Color.fromARGB(100, 0, 0, 0),
                              )
                            ]),
                        child: TextButton(
                            onPressed: facebookLogin,
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                )),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent)),
                            child: Padding(
                              padding:
                                  EdgeInsets.only(right: Constants.h1(context)),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 20,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 1),
                                      child: SvgPicture.asset(
                                        'assets/icons/facebook.svg',
                                        color: Colors.blueAccent[700],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 75,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('FACEBOOK',
                                            style: TextStyle(
                                                fontSize: Constants.s(context),
                                                fontWeight: Constants.bold,
                                                color: Colors.blueAccent[700])),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ),
                  ),
                  Spacer(flex: 15),
                  Expanded(
                    flex: 45,
                    child: SizedBox(
                      height: Constants.a7(context),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 3),
                                blurRadius: 10,
                                color: Color.fromARGB(100, 0, 0, 0),
                              )
                            ]),
                        child: TextButton(
                            onPressed: googleLogin,
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                )),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent)),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: Constants.h1(context),
                                  right: Constants.h1(context)),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 25,
                                    child: SvgPicture.asset(
                                      'assets/icons/google.svg',
                                    ),
                                  ),
                                  Expanded(
                                    flex: 75,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('GOOGLE',
                                            style: TextStyle(
                                                fontSize: Constants.s(context),
                                                fontWeight: Constants.bold,
                                                color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ),
                  )
                ]),
              )
            ],
          ),
        ),
        bottomSheet: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(Constants.h4(context), 0,
                Constants.h4(context), Constants.v7(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context).translate("No_tens_un_compte") +
                      ' ',
                  style: TextStyle(
                      color: Constants.black(context),
                      fontSize: Constants.m(context)),
                ),
                InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => RegData()),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context).translate("Registrat"),
                      style: TextStyle(
                        color: Constants.link(context),
                        fontSize: Constants.m(context),
                        fontWeight: Constants.bold,
                      ),
                    ))
              ],
            ),
          ),
        ));
  }
}
