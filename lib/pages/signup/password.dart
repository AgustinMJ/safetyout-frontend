import 'package:app/defaults/constants.dart';
import 'package:app/state/reg.dart';
import 'package:app/storage/secure_storage.dart';
import 'package:app/widgets/password_input2.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/password_input3.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import 'dart:convert';

class RegPassword extends StatefulWidget {
  RegPassword({Key key}) : super(key: key);

  @override
  _RegPassword createState() => _RegPassword();
}

class _RegPassword extends State<RegPassword> {
  static String pwd = '';
  static String rePwd = '';
  static bool activeButton = false;
  static bool isLoading = false;
  FocusNode rePwdFocusNode = FocusNode();
  Function submitSignUp = (BuildContext context) {};

  @override
  void initState() {
    super.initState();
    submitSignUp = (BuildContext context) {
      if (pwd != rePwd) {
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
                            .translate("Les_contrasenyes_no_coincideixen"),
                        style: TextStyle(
                            fontSize: Constants.m(context),
                            color: Constants.black(context))),
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
      } else if (!pwd.contains(RegExp(r'[0-9]')) ||
          !pwd.contains(RegExp(r'[a-z]')) ||
          !pwd.contains(RegExp(r'[A-Z]')) ||
          pwd.length < 8) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                content: SingleChildScrollView(
                    child: ListBody(
                  children: <Widget>[
                    Text(
                        AppLocalizations.of(context).translate(
                            "La_contrasenya_ha_de_contenir_com_a_mínim:"),
                        style: TextStyle(
                            fontSize: Constants.m(context),
                            color: Constants.black(context))),
                    Text(AppLocalizations.of(context).translate("8_caràcters"),
                        style: TextStyle(
                            fontSize: Constants.m(context),
                            fontWeight: Constants.bold,
                            color: Constants.black(context))),
                    Text(AppLocalizations.of(context).translate("Un_número"),
                        style: TextStyle(
                            fontSize: Constants.m(context),
                            fontWeight: Constants.bold,
                            color: Constants.black(context))),
                    Text(
                        AppLocalizations.of(context).translate("Una_minúscula"),
                        style: TextStyle(
                            fontSize: Constants.m(context),
                            fontWeight: Constants.bold,
                            color: Constants.black(context))),
                    Text(
                        AppLocalizations.of(context).translate("Una_majúscula"),
                        style: TextStyle(
                            fontSize: Constants.m(context),
                            fontWeight: Constants.bold,
                            color: Constants.black(context))),
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
        isLoading = true;
        activeButton = false;
        String name = Provider.of<RegState>(context, listen: false).getName;
        List<String> fullName = name.split(" ");
        String surnames =
            fullName.length > 1 ? name.replaceAll(fullName[0] + ' ', '') : '';
        String email = Provider.of<RegState>(context, listen: false).getEmail;
        String gender = Provider.of<RegState>(context, listen: false).getGender;
        DateTime birthdate =
            Provider.of<RegState>(context, listen: false).getBirthdate;
        String birthday = birthdate.year.toString() +
            '-' +
            birthdate.month.toString() +
            '-' +
            birthdate.day.toString();
        String profileImage = "a";
        var url = Uri.parse('https://safetyout.herokuapp.com/user/signup');
        http.post(url, body: {
          'name': fullName[0],
          'surnames': surnames,
          'email': email,
          'gender': gender,
          'birthday': birthday,
          'password': pwd,
          'profileImage': profileImage
        }).then((res) {
          if (res.statusCode == 201) {
            //Guardar key
            Map<String, dynamic> body = jsonDecode(res.body);
            SecureStorage.writeSecureStorage('SafetyOUT_Token', body["token"]);
            SecureStorage.writeSecureStorage(
                'SafetyOUT_UserId', body["userId"]);
            Navigator.of(context).pushReplacementNamed('/');
            setState(() {
              isLoading = false;
              activeButton = true;
            });
          } else {
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
                                .translate("Error_de_xarxa"),
                            style: TextStyle(
                                fontSize: Constants.m(context),
                                color: Constants.black(context))),
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
          }
        }).catchError((err) {
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
                              .translate("Error_de_xarxa"),
                          style: TextStyle(
                              fontSize: Constants.m(context),
                              color: Constants.black(context))),
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
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: Constants.xs(context)),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: Constants.xxs(context)),
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.arrow_back_ios_rounded,
                            size: 32 /
                                (MediaQuery.of(context).size.width < 380
                                    ? 1.3
                                    : 1),
                            color: Constants.black(context)),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                        AppLocalizations.of(context)
                            .translate("Registre_Usuari"),
                        style: TextStyle(
                            color: Constants.darkGrey(context),
                            fontSize: Constants.xl(context),
                            fontWeight: Constants.bolder)),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: Constants.v4(context)),
                  child: Text(
                      AppLocalizations.of(context)
                          .translate("Introdueix_una_contrasenya"),
                      style: TextStyle(
                          color: Constants.darkGrey(context),
                          fontSize: Constants.l(context),
                          fontWeight: Constants.normal)),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(Constants.h7(context),
                  Constants.v5(context), Constants.h7(context), 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PasswordInput2(
                      labelText:
                          AppLocalizations.of(context).translate("Contrasenya"),
                      onChanged: (value) => setState(() {
                            pwd = value;
                            activeButton = pwd != '' && rePwd != '';
                          }),
                      onSubmitted: (val) => rePwdFocusNode.requestFocus())
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(Constants.h7(context),
                  Constants.v5(context), Constants.h7(context), 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PasswordInput3(
                    labelText: AppLocalizations.of(context)
                        .translate("Confirmar_Contrasenya"),
                    onChanged: (value) => setState(() {
                      rePwd = value;
                      activeButton = pwd != '' && rePwd != '';
                    }),
                    focusNode: rePwdFocusNode,
                    onSubmitted: (val) => activeButton
                        ? setState(() {
                            submitSignUp(context);
                          })
                        : () {},
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(Constants.h7(context),
                  Constants.v7(context), Constants.h7(context), 0),
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
                                offset: Offset(0, 3),
                                blurRadius: 10,
                                color: Color.fromARGB(100, 0, 0, 0),
                              )
                            ]),
                        child: TextButton(
                            onPressed: () => activeButton
                                ? setState(() {
                                    submitSignUp(context);
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
                                        .translate("Confirmar"),
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
          ],
        ),
      ),
    );
  }
}
