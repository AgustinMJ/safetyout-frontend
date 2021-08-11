import 'dart:convert';

import 'package:app/app_localizations.dart';
import 'package:app/defaults/constants.dart';
import 'package:app/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

import 'activity.dart';

class Calendar extends StatefulWidget {
  Calendar({Key key /*, this.title*/}) : super(key: key);

  //final String title;

  @override
  _Calendar createState() => _Calendar();
}

class _Calendar extends State<Calendar> {
  CalendarController _calendarController;
  List<Activity> activitats = [];

  DateTime pickedDate = DateTime.now();

  void onDelete(String id) {
    setState(() {
      activitats.removeWhere((element) => element.placeId == id);
    });
  }

  void onEdit() {
    activitats.clear();
    getAssistencies();
  }

  String getHour(String t) {
    List<String> l = t.split("-");
    Characters cs = l[2].characters;
    return cs.characterAt(3).toString() +
        cs.characterAt(4).toString() +
        cs.characterAt(5).toString() +
        cs.characterAt(6).toString() +
        cs.characterAt(7).toString();
  }

  List<String> getDate(String t) {
    List<String> l = t.split("-");
    List<String> d = [];
    d.add(l[0]);
    d.add((int.parse(l[1]) - 1).toString());
    Characters cs = l[2].characters;
    d.add(cs.characterAt(0).toString() + cs.characterAt(1).toString());
    d.add(cs.characterAt(3).toString() + cs.characterAt(4).toString());
    d.add(cs.characterAt(6).toString() + cs.characterAt(7).toString());
    return d;
  }

  void getAssistencies() async {
    setState(() {
      activitats.clear();
    });
    await SecureStorage.readSecureStorage('SafetyOUT_UserId').then((val) {
      var url = Uri.parse(
          'https://safetyout.herokuapp.com/assistance/consultOnDate?user_id=' +
              val +
              '&year=' +
              pickedDate.year.toString() +
              '&month=' +
              (pickedDate.month - 1).toString() +
              '&day=' +
              pickedDate.day.toString());
      http.get(url).then((res) {
        if (res.statusCode == 200) {
          setState(() {
            Map<String, dynamic> body = jsonDecode(res.body);
            List<dynamic> assistances = body['message'];
            assistances.forEach((a) {
              setState(() {
                Uri urlPlaces = Uri.parse(
                    'https://maps.googleapis.com/maps/api/place/details/json?place_id=' +
                        a["place_id"] +
                        '&key=' +
                        "AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA");
                List<String> date = getDate(a["dateInterval"]["startDate"]);
                Uri urlApi = Uri.parse(
                    'https://safetyout.herokuapp.com/place/occupation?place_id=' +
                        a["place_id"] +
                        '&year=' +
                        date[0] +
                        '&month=' +
                        date[1] +
                        '&day=' +
                        date[2] +
                        '&hour=' +
                        date[3] +
                        '&minute=' +
                        date[4]);

                Future.wait([
                  http.get(urlPlaces),
                  http.get(urlApi),
                ]).then((List responses) {
                  Map<String, dynamic> bodyPlaces =
                      jsonDecode(responses[0].body);
                  String placeName = bodyPlaces["result"]["name"];
                  Map<String, dynamic> bodyApi = jsonDecode(responses[1].body);
                  int placeGauge = bodyApi["occupation"];
                  setState(() {
                    activitats.add(Activity(
                        placeName,
                        getHour(a["dateInterval"]["startDate"]) +
                            " - " +
                            getHour(a["dateInterval"]["endDate"]),
                        placeGauge,
                        date,
                        a["place_id"],
                        getDate(a["dateInterval"]["endDate"]),
                        onDelete,
                        onEdit));
                  });
                }).catchError((error) => {});
              });
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
      });
    });
  }

  String getWeekDay(int num) {
    if (num == 7) {
      return AppLocalizations.of(context).translate("Dilluns");
    } else if (num == 1) {
      return AppLocalizations.of(context).translate("Dimarts");
    } else if (num == 2) {
      return AppLocalizations.of(context).translate("Dimecres");
    } else if (num == 3) {
      return AppLocalizations.of(context).translate("Dijous");
    } else if (num == 4) {
      return AppLocalizations.of(context).translate("Divendres");
    } else if (num == 5) {
      return AppLocalizations.of(context).translate("Dissabte");
    } else if (num == 6) {
      return AppLocalizations.of(context).translate("Diumenge");
    }
    return '';
  }

  String getMonth(int num) {
    if (num == 1) {
      return AppLocalizations.of(context).translate("de_gener");
    } else if (num == 2) {
      return AppLocalizations.of(context).translate("de_febrer");
    } else if (num == 3) {
      return AppLocalizations.of(context).translate("de_març");
    } else if (num == 4) {
      return AppLocalizations.of(context).translate("dabril'");
    } else if (num == 5) {
      return AppLocalizations.of(context).translate("de_maig");
    } else if (num == 6) {
      return AppLocalizations.of(context).translate("de_juny");
    } else if (num == 7) {
      return AppLocalizations.of(context).translate("de_juliol");
    } else if (num == 8) {
      return AppLocalizations.of(context).translate("dagost");
    } else if (num == 9) {
      return AppLocalizations.of(context).translate("de_setembre");
    } else if (num == 10) {
      return AppLocalizations.of(context).translate("doctubre");
    } else if (num == 11) {
      return AppLocalizations.of(context).translate("de_novembre");
    } else if (num == 12) {
      return AppLocalizations.of(context).translate("de_desembre");
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    if (mounted) {
      getAssistencies();
    }
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: EdgeInsets.fromLTRB(Constants.h7(context), Constants.v5(context),
          Constants.h7(context), 0),
      child: Column(children: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
            Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Constants.lightGrey(context),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: TableCalendar(
                locale: Localizations.localeOf(context).toLanguageTag(),
                startDay: DateTime.now(),
                endDay: DateTime(DateTime.now().year + 1),
                calendarController: _calendarController,
                initialSelectedDay: pickedDate,
                initialCalendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {
                  CalendarFormat.month: '',
                },
                availableGestures: AvailableGestures.all,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendStyle: TextStyle(
                      color: Constants.black(context),
                      fontSize: Constants.m(context)),
                  holidayStyle: TextStyle(
                      color: Constants.black(context),
                      fontSize: Constants.m(context)),
                  weekdayStyle: TextStyle(
                      color: Constants.black(context),
                      fontSize: Constants.m(context)),
                  selectedColor: Constants.primary(context),
                  selectedStyle: TextStyle(color: Color(0xFF242424)),
                  todayStyle: TextStyle(color: Constants.black(context)),
                  todayColor: Colors.transparent,
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                      color: Constants.darkGrey(context),
                      fontSize: Constants.m(context),
                      fontWeight: Constants.bold),
                  weekendStyle: TextStyle(
                      color: Constants.darkGrey(context),
                      fontSize: Constants.m(context),
                      fontWeight: Constants.bold),
                ),
                headerStyle: HeaderStyle(
                  centerHeaderTitle: true,
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                      fontWeight: Constants.bold,
                      fontSize: Constants.l(context)),
                  leftChevronIcon: Icon(Icons.arrow_back_ios_rounded,
                      color: Constants.black(context)),
                  rightChevronIcon: Icon(Icons.arrow_forward_ios_rounded,
                      color: Constants.black(context)),
                ),
                onDaySelected: (date, events, holidays) => setState(() {
                  pickedDate = date;
                  _calendarController.setSelectedDay(pickedDate);
                  getAssistencies();
                }),
                onHeaderTapped: (date) {
                  pickedDate = date;
                  _calendarController.setSelectedDay(pickedDate);
                  Picker(
                    adapter: DateTimePickerAdapter(
                        type: 11,
                        yearBegin: DateTime.now().year,
                        yearEnd: DateTime.now().year + 1,
                        value: pickedDate,
                        months: [
                          AppLocalizations.of(context).translate("Gener"),
                          AppLocalizations.of(context).translate("Febrer"),
                          AppLocalizations.of(context).translate("Març"),
                          AppLocalizations.of(context).translate("Abril"),
                          AppLocalizations.of(context).translate("Maig"),
                          AppLocalizations.of(context).translate("Juny"),
                          AppLocalizations.of(context).translate("Juliol"),
                          AppLocalizations.of(context).translate("Agost"),
                          AppLocalizations.of(context).translate("Setembre"),
                          AppLocalizations.of(context).translate("Octubre"),
                          AppLocalizations.of(context).translate("Novembre"),
                          AppLocalizations.of(context).translate("Desembre"),
                        ],
                        customColumnType: [
                          0,
                          1
                        ]),
                    textStyle: TextStyle(
                        color: Constants.darkGrey(context),
                        fontSize: Constants.l(context)),
                    columnFlex: [2, 3],
                    confirmText:
                        AppLocalizations.of(context).translate("Confirmar"),
                    cancelText:
                        AppLocalizations.of(context).translate("Cancel·lar"),
                    confirmTextStyle: TextStyle(
                        color: Constants.darkGrey(context),
                        fontWeight: Constants.bold,
                        fontSize: Constants.s(context)),
                    cancelTextStyle: TextStyle(
                        color: Constants.darkGrey(context),
                        fontWeight: Constants.bold,
                        fontSize: Constants.s(context)),
                    height: Constants.a11(context),
                    hideHeader: true,
                    selectedTextStyle: TextStyle(
                      color: Constants.black(context),
                    ),
                    backgroundColor: Constants.lightGrey(context),
                    onConfirm: (Picker picker, List values) => setState(() {
                      pickedDate = DateTime(DateTime.now().year + values[0],
                          values[1] + 1, pickedDate.day);
                      _calendarController.setSelectedDay(pickedDate);
                      getAssistencies();
                    }),
                    onCancel: () {},
                  ).showDialog(context);
                },
              ),
            ),
          )
        ]),
        Padding(
          padding: EdgeInsets.only(top: Constants.v2(context)),
          child: Row(children: [
            Text(AppLocalizations.of(context).translate("Activitats"),
                style: TextStyle(
                    color: Constants.black(context),
                    fontSize: Constants.xl(context),
                    fontWeight: Constants.bolder)),
          ]),
        ),
        Row(children: [
          Text(
              getWeekDay(pickedDate.weekday) +
                  ", " +
                  pickedDate.day.toString() +
                  " " +
                  getMonth(pickedDate.month) +
                  " de " +
                  pickedDate.year.toString(),
              style: TextStyle(
                color: Constants.black(context),
                fontSize: Constants.l(context),
              )),
        ]),
        Visibility(
            visible: activitats.isNotEmpty,
            child: Expanded(child: ListView(children: activitats))),
      ]),
    )));
  }
}
