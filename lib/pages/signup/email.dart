import 'package:app/defaults/constants.dart';
import 'package:app/state/reg.dart';
import 'package:app/widgets/raw_input.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/signup/birthdate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../app_localizations.dart';
import 'package:http/http.dart' as http;

class Email extends StatefulWidget {
  Email({Key key}) : super(key: key);

  @override
  _Email createState() => _Email();
}

class _Email extends State<Email> {
  static String email = '';
  static bool activeButton = false;
  static bool isLoading = false;
  Function comprovaEmail = () {};

  @override
  void initState() {
    super.initState();
    comprovaEmail = (BuildContext context) {
      if (activeButton) {
        if (RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(email)) {
          activeButton = false;
          isLoading = true;
          var url = Uri.parse(
              'https://safetyout.herokuapp.com/user/checkEmail/' + email);
          http.get(url).then((res) {
            if (res.statusCode == 200) {
              Provider.of<RegState>(context, listen: false).setEmail(email);
              Navigator.push(
                context,
                PageRouteBuilder(pageBuilder: (_, __, ___) => Birthdate()),
              );
              setState(() {
                isLoading = false;
                activeButton = true;
              });
            } else if (res.statusCode == 409) {
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
                                  .translate("El_correu_ja_existeix"),
                              style: TextStyle(
                                  fontSize: Constants.m(context),
                                  color: Constants.black(context))),
                        ],
                      )),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                              AppLocalizations.of(context)
                                  .translate("Acceptar"),
                              style:
                                  TextStyle(color: Constants.black(context))),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  });
            } else {
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
                              AppLocalizations.of(context)
                                  .translate("Acceptar"),
                              style:
                                  TextStyle(color: Constants.black(context))),
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
        } else {
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
                              .translate("El_correu_no_és_correcte"),
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
                          .translate("Introdueix_un_correu_electronic"),
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
                  RawInput(
                    labelText: AppLocalizations.of(context)
                        .translate("Correu_electronic"),
                    onChanged: (value) => setState(() {
                      email = value;
                      activeButton = email != '';
                    }),
                    type: TextInputType.emailAddress,
                    onSubmitted: (val) => setState(() {
                      comprovaEmail(context);
                    }),
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
                              onPressed: () => setState(() {
                                    comprovaEmail(context);
                                  }),
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
                                          .translate("Següent"),
                                      style: TextStyle(
                                          fontSize: Constants.m(context),
                                          fontWeight: Constants.bold,
                                          color: Constants.primaryDark(
                                              context))))),
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
