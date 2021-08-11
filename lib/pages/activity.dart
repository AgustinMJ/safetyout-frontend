import 'dart:convert';

import 'package:app/defaults/constants.dart';
import 'package:app/pages/editar_assistencia.dart';
import 'package:app/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import '../app_localizations.dart';

// ignore: must_be_immutable
class Activity extends StatefulWidget {
  Activity(this.placeName, this.time, this.placeGauge, this.date, this.placeId,
      this.endDate, this.onDelete, this.onEdit,
      {Key key /*, this.title*/})
      : super(key: key);

  final String placeName;
  final String time;
  final int placeGauge;
  final List<String> date;
  final String placeId;
  final List<String> endDate;
  Function onDelete;
  Function onEdit;

  @override
  _Activity createState() => _Activity(
      this.placeName,
      this.time,
      this.placeGauge,
      this.date,
      this.placeId,
      this.endDate,
      this.onDelete,
      this.onEdit);
}

class _Activity extends State<Activity> {
  _Activity(this.placeName, this.time, this.placeGauge, this.date, this.placeId,
      this.endDate, this.onDelete, this.onEdit);
  final String placeName;
  final String time;
  final int placeGauge;
  final List<String> date;
  final List<String> endDate;
  final String placeId;
  Function onDelete;
  Function onEdit;
  bool more = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Constants.v2(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(children: [
                        Container(
                          constraints:
                              BoxConstraints(maxWidth: Constants.w10(context)),
                          child: Text(placeName,
                              style: TextStyle(
                                color: Constants.black(context),
                                fontSize: Constants.m(context),
                              )),
                        ),
                      ]),
                      Column(children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Icon(
                            more ? Icons.remove_rounded : Icons.more_horiz,
                            size: Constants.xxl(context),
                            color: Constants.black(context),
                          ),
                          onTap: () {
                            setState(() {
                              more = !more;
                            });
                          },
                        ),
                      ])
                    ]),
                Padding(
                    padding: EdgeInsets.only(top: Constants.v1(context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: NeverScrollableScrollPhysics(),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                size: Constants.xxl(context),
                                color: Constants.black(context),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: Constants.h1(context)),
                                child: Text(time,
                                    style: TextStyle(
                                      color: Constants.black(context),
                                      fontSize: Constants.s(context),
                                    )),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 100),
                              constraints: BoxConstraints(
                                maxWidth: more ? Constants.w11(context) : 0,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: NeverScrollableScrollPhysics(),
                                child: Container(
                                  color: Constants.orange(context),
                                  height: Constants.a7(context),
                                  width: Constants.w11(context),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                            pageBuilder: (_, __, ___) =>
                                                EditarAssistencia(
                                                    placeName,
                                                    placeId,
                                                    date,
                                                    endDate,
                                                    onEdit)),
                                      );
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)
                                                  .translate("Editar"),
                                              style: TextStyle(
                                                  fontSize:
                                                      Constants.s(context),
                                                  color: Colors.black),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.only(
                      top: Constants.v1(context),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: NeverScrollableScrollPhysics(),
                            child: Row(
                              children: [
                                SvgPicture.asset('assets/icons/group.svg',
                                    color: Constants.black(context),
                                    height: Constants.xxl(context),
                                    width: Constants.xxl(context)),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: Constants.h1(context)),
                                    child: Text(
                                        placeGauge.toString() +
                                            " " +
                                            AppLocalizations.of(context)
                                                .translate("persones"),
                                        style: TextStyle(
                                          color: Constants.black(context),
                                          fontSize: Constants.s(context),
                                        ))),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 100),
                              constraints: BoxConstraints(
                                maxWidth: more ? Constants.w11(context) : 0,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: NeverScrollableScrollPhysics(),
                                child: Container(
                                  color: Constants.red(context),
                                  height: Constants.a7(context),
                                  width: Constants.w11(context),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      24, 20, 24, 0),
                                              content: SingleChildScrollView(
                                                  child: ListBody(
                                                children: <Widget>[
                                                  Text(
                                                      AppLocalizations
                                                              .of(context)
                                                          .translate(
                                                              "Segur_que_vols_eliminar_aquesta_assistencia"),
                                                      style: TextStyle(
                                                          fontSize: Constants.m(
                                                              context),
                                                          color:
                                                              Constants.black(
                                                                  context))),
                                                ],
                                              )),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              "Eliminar"),
                                                      style: TextStyle(
                                                          color: Constants.red(
                                                              context))),
                                                  onPressed: () async {
                                                    String userId =
                                                        await SecureStorage
                                                            .readSecureStorage(
                                                                'SafetyOUT_UserId');
                                                    Uri url = Uri.parse(
                                                        'https://safetyout.herokuapp.com/assistance');
                                                    var body = jsonEncode({
                                                      "user_id": userId,
                                                      "place_id": placeId,
                                                      "dateInterval": {
                                                        "startDate": {
                                                          "year": date[0],
                                                          "month": date[1],
                                                          "day": date[2],
                                                          "hour": date[3],
                                                          "minute": date[4]
                                                        }
                                                      }
                                                    });
                                                    var res = await http.delete(
                                                        url,
                                                        headers: {
                                                          "Content-Type":
                                                              "application/json"
                                                        },
                                                        body: body);
                                                    if (res.statusCode == 200) {
                                                      Navigator.of(context)
                                                          .pop();
                                                      onDelete(placeId);

                                                      Map<String, dynamic>
                                                          resBody =
                                                          jsonDecode(res.body);
                                                      int achievementId =
                                                          resBody["trophy"];

                                                      if (achievementId == 5) {
                                                        String achievementIcon =
                                                            "delete master";
                                                        String achievementText =
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    "Elimina una assistència");
                                                        await showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            24,
                                                                            20,
                                                                            24,
                                                                            0),
                                                                content:
                                                                    SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                  children: [
                                                                    Image(
                                                                        height: Constants.xxl(context) +
                                                                            Constants.xxl(
                                                                                context) +
                                                                            Constants.xxl(
                                                                                context) +
                                                                            Constants.xs(
                                                                                context),
                                                                        image: AssetImage("assets/icons/achievements/" +
                                                                            achievementIcon +
                                                                            ".png")),
                                                                    Padding(
                                                                      padding: EdgeInsets.fromLTRB(
                                                                          Constants.h1(
                                                                              context),
                                                                          Constants.v1(
                                                                              context),
                                                                          Constants.h1(
                                                                              context),
                                                                          Constants.v1(
                                                                              context)),
                                                                      child: Text(
                                                                          achievementText),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.fromLTRB(
                                                                          Constants.h1(
                                                                              context),
                                                                          Constants.v1(
                                                                              context),
                                                                          Constants.h1(
                                                                              context),
                                                                          Constants.v1(
                                                                              context)),
                                                                      child: Text(
                                                                          AppLocalizations.of(context).translate(
                                                                              "Nou assoliment!"),
                                                                          style: TextStyle(
                                                                              color: Constants.black(context),
                                                                              fontWeight: Constants.bold)),
                                                                    )
                                                                  ],
                                                                )),
                                                                actions: <
                                                                    Widget>[
                                                                  TextButton(
                                                                    child: Text(
                                                                        AppLocalizations.of(context).translate(
                                                                            "Acceptar"),
                                                                        style: TextStyle(
                                                                            color:
                                                                                Constants.black(context))),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                      }
                                                    }
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              "Cancel·lar"),
                                                      style: TextStyle(
                                                          color:
                                                              Constants.black(
                                                                  context))),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)
                                                  .translate("Eliminar"),
                                              style: TextStyle(
                                                  fontSize:
                                                      Constants.s(context),
                                                  color: Colors.black),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
