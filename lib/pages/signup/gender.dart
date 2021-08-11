import 'package:app/defaults/constants.dart';
import 'package:app/state/reg.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/signup/password.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';

enum Sex {
  notKnown,
  male,
  female,
  not_applicable,
}

class Gender extends StatefulWidget {
  Gender({Key key /*, this.title*/}) : super(key: key);
  //final String title;

  @override
  _Gender createState() => _Gender();
}

class _Gender extends State<Gender> {
  Sex gender;
  bool activeButton = false;

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
                          .translate("Selecciona_el_teu_gènere"),
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () => setState(() {
                            gender = Sex.female;
                          }),
                          child: Icon(FontAwesomeIcons.venus,
                              size: 150 /
                                  (MediaQuery.of(context).size.height < 700
                                      ? 1.5
                                      : MediaQuery.of(context).size.height < 800
                                          ? 1.3
                                          : 1),
                              color: gender == Sex.female
                                  ? Constants.pink(context)
                                  : Constants.grey(context)),
                        ),
                        Text(AppLocalizations.of(context).translate("Femení"),
                            style: TextStyle(
                                fontSize: Constants.l(context),
                                fontWeight: Constants.bold,
                                color: gender == Sex.female
                                    ? Constants.pink(context)
                                    : Constants.grey(context)))
                      ],
                    ),
                    Column(
                      children: [
                        InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () => setState(() {
                            gender = Sex.male;
                          }),
                          child: Icon(FontAwesomeIcons.mars,
                              size: 150 /
                                  (MediaQuery.of(context).size.height < 700
                                      ? 1.5
                                      : MediaQuery.of(context).size.height < 800
                                          ? 1.3
                                          : 1),
                              color: gender == Sex.male
                                  ? Constants.blue(context)
                                  : Constants.grey(context)),
                        ),
                        Text(AppLocalizations.of(context).translate("Masculí"),
                            style: TextStyle(
                                fontSize: Constants.l(context),
                                fontWeight: Constants.bold,
                                color: gender == Sex.male
                                    ? Constants.blue(context)
                                    : Constants.grey(context)))
                      ],
                    ),
                  ],
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(Constants.h7(context),
                    Constants.v7(context), Constants.h7(context), 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () => setState(() {
                            gender = Sex.notKnown;
                          }),
                          child: Icon(FontAwesomeIcons.transgenderAlt,
                              size: 150 /
                                  (MediaQuery.of(context).size.height < 700
                                      ? 1.5
                                      : MediaQuery.of(context).size.height < 800
                                          ? 1.3
                                          : 1),
                              color: gender == Sex.notKnown
                                  ? Constants.purple(context)
                                  : Constants.grey(context)),
                        ),
                        Text(AppLocalizations.of(context).translate("Altres"),
                            style: TextStyle(
                                fontSize: Constants.l(context),
                                fontWeight: Constants.bold,
                                color: gender == Sex.notKnown
                                    ? Constants.purple(context)
                                    : Constants.grey(context)))
                      ],
                    ),
                    Column(
                      children: [
                        InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () => setState(() {
                            gender = Sex.not_applicable;
                          }),
                          child: Icon(FontAwesomeIcons.genderless,
                              size: 150 /
                                  (MediaQuery.of(context).size.height < 700
                                      ? 1.5
                                      : MediaQuery.of(context).size.height < 800
                                          ? 1.3
                                          : 1),
                              color: gender == Sex.not_applicable
                                  ? Constants.red(context)
                                  : Constants.grey(context)),
                        ),
                        Text(
                            AppLocalizations.of(context)
                                .translate("No_especificar"),
                            style: TextStyle(
                                fontSize: Constants.l(context),
                                fontWeight: Constants.bold,
                                color: gender == Sex.not_applicable
                                    ? Constants.red(context)
                                    : Constants.grey(context)))
                      ],
                    ),
                  ],
                )),
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
                              colors: gender != null
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
                            onPressed: () {
                              if (gender != null) {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          RegPassword()),
                                );
                                Provider.of<RegState>(context, listen: false)
                                    .setGender(gender
                                        .toString()
                                        .replaceAll(RegExp(r'Sex.'), ''));
                              }
                            },
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                )),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent)),
                            child: Text(
                                AppLocalizations.of(context)
                                    .translate("Següent"),
                                style: TextStyle(
                                    fontSize: Constants.m(context),
                                    fontWeight: Constants.bold,
                                    color: Constants.primaryDark(context)))),
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
