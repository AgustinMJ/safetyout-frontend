import 'package:app/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:table_calendar/table_calendar.dart';
import '../app_localizations.dart';
import '../defaults/constants.dart';
import 'Attendance.dart';
import 'package:http/http.dart' as http;

class DetailsAttendance extends StatefulWidget {
  final Attendance assistencia;

  DetailsAttendance({Key key, @required this.assistencia}) : super(key: key);

  @override
  _DetailsAttendanceState createState() => _DetailsAttendanceState();
}

class _DetailsAttendanceState extends State<DetailsAttendance> {
  Function guardarCanvis = (BuildContext context, Attendance assistencia,
      TimeOfDay _inici, TimeOfDay _fi, DateTime oldStartDate) {
    //CRIDA API
    var url = Uri.parse('https://safetyout.herokuapp.com/assistance/modify');
    DateTime startDate = assistencia.getFechaInicial;
    DateTime endDate = assistencia.getFechaFinal;
    http.post(url, body: {
      'user_id': SecureStorage.readSecureStorage('SafetyOUT_userid'),
      'place': {
        'longitude': assistencia.longitud,
        'latitude': assistencia.latitud
      },
      'dateInterval': {
        'startDate': {
          'year': oldStartDate.year,
          'month': oldStartDate.month,
          'day': oldStartDate.day,
          'hour': oldStartDate.hour,
          'minute': oldStartDate.minute,
        }
      },
      'newStartDate': {
        'year': startDate.year,
        'month': startDate.month,
        'day': startDate.day,
        'hour': _inici.hour,
        'minute': _inici.minute,
      },
      'newEndDate': {
        'year': endDate.year,
        'month': endDate.month,
        'day': endDate.day,
        'hour': _fi.hour,
        'minute': _fi.minute,
      }
    }).then((res) {
      if (res.statusCode != 201) {
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
                            .translate("Error_modificar_assistencia"),
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
  };

  Function borrarAssistencia =
      (BuildContext context, Attendance assistencia, DateTime oldStartDate) {
    //CRIDA API
    var url = Uri.parse('https://safetyout.herokuapp.com/assistance');
    http.delete(url, body: {
      'user_id': SecureStorage.readSecureStorage('SafetyOUT_userid'),
      'place': {
        'longitude': assistencia.longitud,
        'latitude': assistencia.latitud
      },
      'dateInterval': {
        'startDate': {
          'year': oldStartDate.year,
          'month': oldStartDate.month,
          'day': oldStartDate.day,
          'hour': oldStartDate.hour,
          'minute': oldStartDate.minute,
        }
      }
    }).then((res) {
      if (res.statusCode != 201) {
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
                            .translate("Error_borrar_assistencia"),
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
    Navigator.of(context).pop();
  };

  var _calendarController;

  DateTime startDate;
  DateTime endDate;
  TimeOfDay _start;
  TimeOfDay _end;

  void _selectstartTime() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      initialTime: _start,
    );
    if (newTime != null) {
      setState(() {
        _start = newTime;
      });
    }
  }

  void _selectendTime() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      initialTime: _end,
    );
    if (newTime != null) {
      setState(() {
        _end = newTime;
      });
    }
  }

  Widget build(BuildContext context) {
    final DateTime oldStartDate = widget.assistencia.getFechaInicial;
    endDate = widget.assistencia.getFechaFinal;
    startDate = oldStartDate;
    _start = TimeOfDay(hour: startDate.hour, minute: startDate.minute);
    _end = TimeOfDay(hour: endDate.hour, minute: endDate.minute);
    widget.assistencia.getDataGoogle();
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
                    child: Visibility(
                      visible: MediaQuery.of(context).viewInsets.bottom == 0,
                      child: Text(
                          AppLocalizations.of(context)
                              .translate("Modificar_Assistencia"),
                          style: TextStyle(
                              color: Constants.darkGrey(context),
                              fontSize: Constants.xl(context),
                              fontWeight: Constants.bolder)),
                    ),
                  ),
                  Align(
                    // BotoGuardarCanvis
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: Constants.xxs(context)),
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: guardarCanvis(
                            context, widget.assistencia, oldStartDate),
                        child: Icon(Icons.check,
                            size: 32 /
                                (MediaQuery.of(context).size.width < 380
                                    ? 1.3
                                    : 1),
                            color: Constants.black(context)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(Constants.h4(context),
                  Constants.v7(context), Constants.h4(context), 0),
              child: Text(widget.assistencia.getplaceName, //placename,
                  style: TextStyle(
                      color: Constants.black(context),
                      fontSize: Constants.xxl(context),
                      fontWeight: Constants.bolder)),
            ),
            Text(widget.assistencia.getplaceDescription, //placeLocation,
                style: TextStyle(color: Constants.black(context))),
            TableCalendar(
              locale: Localizations.localeOf(context).toLanguageTag(),
              startDay: DateTime(1900),
              endDay: DateTime.now(),
              calendarController: _calendarController,
              initialSelectedDay: startDate,
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
                    fontWeight: Constants.bold, fontSize: Constants.l(context)),
                leftChevronIcon: Icon(Icons.arrow_back_ios_rounded,
                    color: Constants.black(context)),
                rightChevronIcon: Icon(Icons.arrow_forward_ios_rounded,
                    color: Constants.black(context)),
              ),
              onDaySelected: (date, events, holidays) => setState(() {
                startDate = date;
                _calendarController.setSelectedDay(startDate);
              }),
              onHeaderTapped: (date) {
                startDate = date;
                _calendarController.setSelectedDay(startDate);
                Picker(
                  adapter: DateTimePickerAdapter(
                      type: 11,
                      yearBegin: 1900,
                      yearEnd: DateTime.now().year,
                      value: startDate,
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
                    startDate = DateTime(
                        1900 + values[0], values[1] + 1, startDate.day);
                    _calendarController.setSelectedDay(startDate);
                  }),
                  onCancel: () {},
                ).showDialog(context);
              },
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(Constants.h4(context),
                  Constants.v7(context), Constants.h4(context), 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _selectstartTime,
                    child: Text('Hora inici'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hora Seleccionada: ${_start.format(context)}',
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(Constants.h4(context),
                  Constants.v7(context), Constants.h4(context), 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _selectendTime,
                    child: Text('Hora final'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hora Seleccionada: ${_end.format(context)}',
                  ),
                ],
              ),
            ),
            Expanded(
              //BotoBorrarAsistencia
              child: SizedBox(
                height: Constants.a7(context),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border:
                          Border.all(color: Constants.red(context), width: 2)),
                  child: TextButton(
                      onPressed: () => borrarAssistencia(context,
                          widget.assistencia, _start, _end, oldStartDate),
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent)),
                      child: Text(
                          AppLocalizations.of(context)
                              .translate("Borrar_Assistencia"),
                          style: TextStyle(
                              fontSize: Constants.m(context),
                              fontWeight: Constants.bold,
                              color: Constants.red(context)))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
