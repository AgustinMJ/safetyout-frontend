import 'dart:convert';

import 'package:app/defaults/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import '../app_localizations.dart';
import 'app.dart';

class ConsultarAforament extends StatefulWidget {
  ConsultarAforament(
      this.placeName, this.placeLocation, this.placeAddress, this.placeId,
      {Key key})
      : super(key: key);

  final String placeName;
  final String placeLocation;
  final String placeAddress;
  final String placeId;

  @override
  _ConsultarAforament createState() => _ConsultarAforament(
      this.placeName, this.placeLocation, this.placeAddress, this.placeId);
}

class _ConsultarAforament extends State<ConsultarAforament> {
  CalendarController _calendarController;
  DateTime pickedDate = DateTime.now();
  DateTime yearDate = DateTime.now();

  _ConsultarAforament(
      this.placeName, this.placeLocation, this.placeAddress, this.placeId);
  final String placeName;
  final String placeLocation;
  final String placeAddress;
  final String placeId;
  int placeGauge;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    consultaAforament();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void consultaAforament() async {
    Uri url = Uri.parse(
        'https://safetyout.herokuapp.com/place/occupation?place_id=' +
            placeId +
            '&year=' +
            pickedDate.year.toString() +
            '&month=' +
            (pickedDate.month - 1).toString() +
            '&day=' +
            pickedDate.day.toString() +
            '&hour=' +
            pickedDate.hour.toString() +
            '&minute=' +
            pickedDate.minute.toString());
    await http.get(url).then((res) {
      if (res.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(res.body);
        setState(() {
          placeGauge = body["occupation"];
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
    }).catchError((err) {
      //Sale error por pantalla
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: SingleChildScrollView(
                  child: ListBody(
                children: <Widget>[
                  Text(AppLocalizations.of(context).translate("Error_de_xarxa"),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
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
                      Navigator.of(context).pushReplacement(
                          PageRouteBuilder(pageBuilder: (_, __, ___) => App()));
                    },
                    child: Icon(Icons.arrow_back_ios_rounded,
                        size: 32 /
                            (MediaQuery.of(context).size.width < 380 ? 1.3 : 1),
                        color: Constants.black(context)),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Visibility(
                  visible: MediaQuery.of(context).viewInsets.bottom == 0,
                  child: Text(
                      AppLocalizations.of(context)
                          .translate("Aforament_per_hores"),
                      style: TextStyle(
                          color: Constants.darkGrey(context),
                          fontSize: Constants.xl(context),
                          fontWeight: Constants.bolder)),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.only(
                top: Constants.v2(context),
                left: Constants.h6(context),
                right: Constants.h6(context)),
            child: Column(
              children: <Widget>[
                Row(children: [
                  SizedBox(
                    width: Constants.w12(context),
                    child: Text(
                      placeName,
                      style: TextStyle(
                          color: Constants.black(context),
                          fontWeight: Constants.bolder,
                          fontSize: Constants.l(context)),
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                    ),
                  )
                ]),
                Row(children: [
                  SizedBox(
                    width: Constants.w12(context),
                    child: Text(
                      placeLocation,
                      style: TextStyle(
                          color: Constants.black(context),
                          fontWeight: Constants.bolder,
                          fontSize: Constants.m(context)),
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                    ),
                  ),
                ]),
                Padding(
                  padding: EdgeInsets.only(
                      top: Constants.v3(context),
                      bottom: Constants.v3(context)),
                  child: Row(children: [
                    SvgPicture.asset('assets/icons/placeholder.svg',
                        color: Constants.black(context),
                        height: Constants.xxl(context),
                        width: Constants.xxl(context)),
                    Padding(
                      padding: EdgeInsets.only(left: Constants.h1(context)),
                      child: SizedBox(
                        width: Constants.w12(context),
                        child: Text(
                          placeAddress,
                          style: TextStyle(
                              color: Constants.black(context),
                              fontSize: Constants.s(context)),
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ]),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Constants.lightGrey(context),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Column(
                            children: [
                              TableCalendar(
                                locale: Localizations.localeOf(context)
                                    .toLanguageTag(),
                                startDay: DateTime.now(),
                                endDay: DateTime(DateTime.now().year + 1,
                                    DateTime.now().month, DateTime.now().day),
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
                                  selectedStyle:
                                      TextStyle(color: Color(0xFF242424)),
                                  todayStyle: TextStyle(
                                      color: Constants.black(context)),
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
                                  leftChevronIcon: Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: Constants.black(context)),
                                  rightChevronIcon: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Constants.black(context)),
                                ),
                                onDaySelected: (date, events, holidays) =>
                                    setState(() {
                                  pickedDate = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      pickedDate.hour,
                                      pickedDate.minute);
                                  _calendarController
                                      .setSelectedDay(pickedDate);
                                  consultaAforament();
                                }),
                                onHeaderTapped: (date) {
                                  pickedDate = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      pickedDate.hour,
                                      pickedDate.minute);
                                  _calendarController
                                      .setSelectedDay(pickedDate);
                                  Picker(
                                    adapter: DateTimePickerAdapter(
                                        type: 11,
                                        yearBegin: DateTime.now().year,
                                        yearEnd: DateTime.now().year + 1,
                                        value: pickedDate,
                                        months: [
                                          AppLocalizations.of(context)
                                              .translate("Gener"),
                                          AppLocalizations.of(context)
                                              .translate("Febrer"),
                                          AppLocalizations.of(context)
                                              .translate("Març"),
                                          AppLocalizations.of(context)
                                              .translate("Abril"),
                                          AppLocalizations.of(context)
                                              .translate("Maig"),
                                          AppLocalizations.of(context)
                                              .translate("Juny"),
                                          AppLocalizations.of(context)
                                              .translate("Juliol"),
                                          AppLocalizations.of(context)
                                              .translate("Agost"),
                                          AppLocalizations.of(context)
                                              .translate("Setembre"),
                                          AppLocalizations.of(context)
                                              .translate("Octubre"),
                                          AppLocalizations.of(context)
                                              .translate("Novembre"),
                                          AppLocalizations.of(context)
                                              .translate("Desembre"),
                                        ],
                                        customColumnType: [
                                          0,
                                          1
                                        ]),
                                    textStyle: TextStyle(
                                        color: Constants.darkGrey(context),
                                        fontSize: Constants.l(context)),
                                    columnFlex: [2, 3],
                                    confirmText: AppLocalizations.of(context)
                                        .translate("Confirmar"),
                                    cancelText: AppLocalizations.of(context)
                                        .translate("Cancel·lar"),
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
                                    backgroundColor:
                                        Constants.lightGrey(context),
                                    onConfirm: (Picker picker, List values) =>
                                        setState(() {
                                      pickedDate = DateTime(
                                          DateTime.now().year + values[0],
                                          values[1] + 1,
                                          pickedDate.day,
                                          pickedDate.hour,
                                          pickedDate.minute);
                                      _calendarController
                                          .setSelectedDay(pickedDate);
                                      consultaAforament();
                                    }),
                                    onCancel: () {},
                                  ).showDialog(context);
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: Constants.h6(context),
                                    right: Constants.h6(context)),
                                child: Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Constants.grey(context),
                                ),
                              ),
                              InkWell(
                                focusColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  Picker(
                                    adapter: DateTimePickerAdapter(
                                        value: pickedDate,
                                        customColumnType: [3, 4]),
                                    textStyle: TextStyle(
                                        color: Constants.darkGrey(context),
                                        fontSize: Constants.l(context)),
                                    confirmText: AppLocalizations.of(context)
                                        .translate("Confirmar"),
                                    cancelText: AppLocalizations.of(context)
                                        .translate("Cancel·lar"),
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
                                    backgroundColor:
                                        Constants.lightGrey(context),
                                    onConfirm: (Picker picker, List values) =>
                                        setState(() {
                                      pickedDate = DateTime(
                                          pickedDate.year,
                                          pickedDate.month,
                                          pickedDate.day,
                                          values[0],
                                          values[1]);
                                      _calendarController
                                          .setSelectedDay(pickedDate);
                                      consultaAforament();
                                    }),
                                    onCancel: () {},
                                  ).showDialog(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: Constants.v3(context),
                                      bottom: Constants.v3(context)),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.access_time_outlined,
                                          size: Constants.xxl(context),
                                          color: Constants.black(context),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: Constants.h1(context)),
                                          child: Text(
                                              (pickedDate.hour < 10
                                                      ? '0'
                                                      : '') +
                                                  pickedDate.hour.toString() +
                                                  ':' +
                                                  (pickedDate.minute < 10
                                                      ? '0'
                                                      : '') +
                                                  pickedDate.minute.toString(),
                                              style: TextStyle(
                                                  fontWeight: Constants.normal,
                                                  color:
                                                      Constants.black(context),
                                                  fontSize:
                                                      Constants.xl(context))),
                                        )
                                      ]),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ]),
                Padding(
                  padding: EdgeInsets.only(top: Constants.v3(context)),
                  child: Row(children: [
                    SvgPicture.asset('assets/icons/group.svg',
                        color: Constants.black(context),
                        height: Constants.xxl(context),
                        width: Constants.xxl(context)),
                    Padding(
                      padding: EdgeInsets.only(left: Constants.h1(context)),
                      child: Text(
                        placeGauge != null
                            ? placeGauge.toString() +
                                ' ' +
                                AppLocalizations.of(context)
                                    .translate("persones")
                            : '',
                        style: TextStyle(
                            color:
                                Constants.black(context), //o green segú aforo
                            fontWeight: Constants.bolder,
                            fontSize: Constants.l(context)),
                      ),
                    ),
                  ]),
                ),
/*                 Padding(
                    padding: EdgeInsets.only(top: Constants.v3(context)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Hi haura (o no) molta gent",
                              style: TextStyle(fontSize: Constants.l(context))),
                        ])),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text("Es recomana no assistir/pots assistir",
                      style: TextStyle(fontSize: Constants.l(context))),
                ]), */
              ],
            ),
          ),
        ),
      ],
    )));
  }
}
