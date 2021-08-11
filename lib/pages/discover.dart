import 'dart:convert';
import 'dart:math';
import 'package:app/defaults/constants.dart';
import 'package:app/pages/notificarassistencia.dart';
import 'package:app/pages/consultaraforament.dart';
import 'package:app/widgets/border_button.dart';
import 'package:app/widgets/search_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import '../app_localizations.dart';

class Discover extends StatefulWidget {
  Discover({Key key}) : super(key: key);

  @override
  _Discover createState() => _Discover();
}

class _Discover extends State<Discover> {
  bool firstLocation = false;
  bool serviceEnabled;
  PermissionStatus permissionGranted;
  GoogleMapController controller;
  LatLng initialcameraposition = LatLng(20.5937, 78.9629);
  LatLng lastLatLng = LatLng(20.5937, 78.9629);
  LatLng movingCamPos = LatLng(20.5937, 78.9629);
  Location location = Location();
  final Map<String, Marker> markers = {};

  List<Map<String, dynamic>> places = [];
  bool viewPlace = false;
  bool fullHours = false;
  String placeName = '';
  String placeLocation = '';
  String placeAddress = '';
  List<dynamic> placeOpenHours = [];
  bool placeOpened = false;
  String todaysHours;
  int placeGauge;
  Uri placeDetailsUrl;
  String placeId;
  FocusNode searchNode = FocusNode();

  bool viewSug = false;
  bool fullSugs = false;

  @override
  void dispose() {
    controller = null;
    super.dispose();
  }

  void getOcupation(LatLng cords) async {
    DateTime now = DateTime.now();
    Uri url = Uri.parse(
        'https://safetyout.herokuapp.com/place/occupation?place_id=' +
            placeId +
            '&year=' +
            now.year.toString() +
            '&month=' +
            (now.month - 1).toString() +
            '&day=' +
            now.day.toString() +
            '&hour=' +
            now.hour.toString() +
            '&minute=' +
            now.minute.toString());
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
    });
  }

  Future<String> getDetails(Uri placeDetailsUrl) async {
    var response = await http.get(placeDetailsUrl);
    setState(() {
      Map<String, dynamic> convertDataToJson = jsonDecode(response.body);
      placeName = convertDataToJson["result"]["name"];
      List<String> address =
          convertDataToJson["result"]["formatted_address"].split(', ');
      placeAddress = address[0];

      var openHours = convertDataToJson["result"]["opening_hours"];
      placeOpenHours = [];
      if (openHours != null) {
        openHours["weekday_text"].forEach((p) {
          String ph = '';
          List<String> aux = p.split(' ');
          for (int i = 1; i < aux.length; i++) {
            ph += aux[i] + (i + 1 < aux.length ? ' ' : '');
          }
          placeOpenHours.add(ph);
        });
        placeOpened = openHours["open_now"];
        todaysHours = placeOpenHours[DateTime.now().weekday - 1];
      } else {
        placeOpened = true;
        todaysHours = "";
      }

      var location = convertDataToJson["result"]["address_components"];

      int max = location.length;
      int index = 0;
      while (index < max - 1) {
        if (location[index]["types"].toString() == "[locality, political]") {
          placeLocation = location[index]["long_name"];
        }
        if (location[index]["types"].toString() ==
            "[administrative_area_level_2, political]") {
          placeLocation += ", " + location[index]["long_name"];
        }
        ++index;
      }
    });
    return "Success";
  }

  Future<void> onMapCreated(GoogleMapController cntlr) async {
    controller = cntlr;
    String mapStyle;
    Brightness theme = MediaQuery.of(context).platformBrightness;
    if (theme != null) {
      mapStyle = theme == Brightness.light
          ? await rootBundle.loadString('assets/map_styles/light.json')
          : await rootBundle.loadString('assets/map_styles/dark.json');
    } else {
      mapStyle = MediaQuery.of(context).platformBrightness == Brightness.light
          ? await rootBundle.loadString('assets/map_styles/light.json')
          : await rootBundle.loadString('assets/map_styles/dark.json');
    }
    await cntlr.setMapStyle(mapStyle);

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  void retrievePlaces(LatLng l) async {
    var urlPark = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=' +
            l.latitude.toString() +
            ',' +
            l.longitude.toString() +
            '&radius=5000&keyword=park&language=' +
            Localizations.localeOf(context).languageCode +
            '&key=AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA&fields=geometry,place_id,name');
    var urlNature = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=' +
            l.latitude.toString() +
            ',' +
            l.longitude.toString() +
            '&radius=5000&keyword=nature&language=' +
            Localizations.localeOf(context).languageCode +
            '&key=AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA&fields=geometry,place_id,name');
    var urlSight = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=' +
            l.latitude.toString() +
            ',' +
            l.longitude.toString() +
            '&radius=5000&keyword=sightseeing&language=' +
            Localizations.localeOf(context).languageCode +
            '&key=AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA&fields=geometry,place_id,name');
    var urlTerrace = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=' +
            l.latitude.toString() +
            ',' +
            l.longitude.toString() +
            '&radius=5000&keyword=terrace&language=' +
            Localizations.localeOf(context).languageCode +
            '&key=AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA&fields=geometry,place_id,name');
    var urlMountain = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=' +
            l.latitude.toString() +
            ',' +
            l.longitude.toString() +
            '&radius=5000&keyword=mountain&language=' +
            Localizations.localeOf(context).languageCode +
            '&key=AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA&fields=geometry,place_id,name');
    var urlCastle = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=' +
            l.latitude.toString() +
            ',' +
            l.longitude.toString() +
            '&radius=5000&keyword=castle&language=' +
            Localizations.localeOf(context).languageCode +
            '&key=AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA&fields=geometry,place_id,name');
    var urlRes = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=' +
            l.latitude.toString() +
            ',' +
            l.longitude.toString() +
            '&radius=5000&keyword=takeout&language=' +
            Localizations.localeOf(context).languageCode +
            '&fields=geometry,place_id,name&key=AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA');
    places = [];
    await Future.wait([
      http.get(urlPark),
      http.get(urlNature),
      http.get(urlSight),
      http.get(urlTerrace),
      http.get(urlMountain),
      http.get(urlCastle),
      http.get(urlRes)
    ]).then((List responses) {
      responses.forEach((r) {
        Map<String, dynamic> body = jsonDecode(r.body);
        List<dynamic> results = body["results"];
        results.forEach((element) {
          Map<String, dynamic> place = {
            "location": element["geometry"]["location"],
            "place_id": element["place_id"],
            "name": element["name"]
          };
          places.add(place);
        });
      });
    }).catchError((error) => {});

    final ids = places.toList().map((e) => e["place_id"]).toList().toSet();
    places.toList().retainWhere((x) => ids.remove(x["place_id"]));

    if (mounted) {
      setState(() {
        markers.clear();
        places.forEach((place) {
          final marker = Marker(
              markerId: MarkerId(place["place_id"]),
              icon: BitmapDescriptor.defaultMarker,
              position:
                  LatLng(place["location"]["lat"], place["location"]["lng"]),
              onTap: () {
                handlePinTap(place["place_id"],
                    LatLng(place["location"]["lat"], place["location"]["lng"]));
                String api_key = "AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA";
                String place_id = place["place_id"];
                placeDetailsUrl = Uri.parse(
                    'https://maps.googleapis.com/maps/api/place/details/json?place_id=' +
                        place_id +
                        '&key=' +
                        api_key);

                placeId = place["place_id"];

                getDetails(placeDetailsUrl);

                getOcupation(
                    LatLng(place["location"]["lat"], place["location"]["lng"]));

                setState(() {
                  viewPlace = true;
                });
                if (mounted) {
                  controller
                      .animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(
                              target: LatLng(place["location"]["lat"],
                                  place["location"]["lng"]),
                              zoom: 18)))
                      .catchError((error) {});
                }
              });

          markers[place["place_id"]] = marker;
        });
      });
    }
  }

  void getFirstLocation() {
    location.getLocation().then((l) {
      initialcameraposition = LatLng(l.latitude, l.longitude);
      lastLatLng = initialcameraposition;
      firstLocation = true;
      setState(() {
        retrievePlaces(lastLatLng);
      });
    }).catchError((err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: SingleChildScrollView(
                  child: ListBody(
                children: <Widget>[
                  Text(AppLocalizations.of(context).translate("Error de xarxa"),
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
    });
  }

  void handlePinTap(String placeId, LatLng loc) {
    String api_key = "AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA";
    placeDetailsUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=' +
            placeId +
            '&key=' +
            api_key);

    getDetails(placeDetailsUrl);

    getOcupation(loc);

    setState(() {
      viewPlace = true;
      viewSug = false;
      fullSugs = false;
      searchNode.unfocus();
    });
    if (mounted) {
      controller
          .animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: loc, zoom: 18)))
          .catchError((error) {});
    }
  }

  @override
  void initState() {
    super.initState();
    getFirstLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            firstLocation
                ? GoogleMap(
                    onTap: (lat) {
                      setState(() {
                        viewPlace = false;
                        searchNode.unfocus();
                      });
                    },
                    initialCameraPosition: firstLocation
                        ? CameraPosition(
                            target: initialcameraposition, zoom: 18)
                        : CameraPosition(target: initialcameraposition),
                    mapType: MapType.normal,
                    onMapCreated: onMapCreated,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    markers: markers.values.toSet(),
                    onCameraIdle: () {
                      setState(() {
                        if (pow(movingCamPos.latitude - lastLatLng.latitude,
                                    2) >=
                                0.0010000000000 ||
                            pow(movingCamPos.longitude - lastLatLng.longitude,
                                    2) >=
                                0.0010000000000) {
                          lastLatLng = movingCamPos;
                          retrievePlaces(movingCamPos);
                        }
                      });
                    },
                    onCameraMove: (CameraPosition newCamPos) {
                      movingCamPos = newCamPos.target;
                    },
                  )
                : Container(
                    decoration:
                        BoxDecoration(color: Constants.lightGrey(context)),
                    child: Center(
                      child: SpinKitFadingCube(
                          color: Colors.white,
                          size: 40.0 /
                              (MediaQuery.of(context).size.height < 700
                                  ? 1.3
                                  : MediaQuery.of(context).size.height < 800
                                      ? 1.15
                                      : 1)),
                    ),
                  ),
            Padding(
              padding: EdgeInsets.only(
                  top: Constants.v3(context),
                  right: Constants.h6(context),
                  left: Constants.h6(context)),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: Constants.h7(context) + Constants.h7(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: Constants.a7(context),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 5),
                                  blurRadius: 5,
                                  color: Color.fromARGB(100, 0, 0, 0),
                                )
                              ],
                            ),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  viewSug = !viewSug;
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate("Suggerencies"),
                                      style: TextStyle(
                                          color: Constants.black(context),
                                          fontWeight: Constants.bold,
                                          fontSize: Constants.m(context))),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: Constants.h1(context)),
                                    child: Icon(
                                        viewSug
                                            ? FontAwesomeIcons.chevronUp
                                            : FontAwesomeIcons.chevronDown,
                                        color: Constants.black(context),
                                        size: 24.0 /
                                            (MediaQuery.of(context)
                                                        .size
                                                        .height <
                                                    700
                                                ? 1.3
                                                : MediaQuery.of(context)
                                                            .size
                                                            .height <
                                                        800
                                                    ? 1.15
                                                    : 1)),
                                  )
                                ],
                              ),
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.symmetric(
                                          vertical: Constants.v1(context),
                                          horizontal: Constants.h1(context))),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  )),
                                  backgroundColor: MaterialStateProperty.all(
                                      Constants.trueWhite(context))),
                            )),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          constraints: BoxConstraints(
                            maxHeight: viewSug
                                ? MediaQuery.of(context).size.height
                                : 0,
                          ),
                          width: Constants.wFull(context),
                          child: SingleChildScrollView(
                            physics: NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: Constants.v2(context),
                                      bottom: Constants.v2(context)),
                                  child: Container(
                                    height: fullSugs
                                        ? Constants.a13(context)
                                        : Constants.a11(context),
                                    child: ListView.builder(
                                      itemCount:
                                          fullSugs ? places.toList().length : 3,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: Constants.v2(context)),
                                          child: Row(
                                            children: [
                                              Container(
                                                  height: Constants.a7(context),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        offset: Offset(0, 5),
                                                        blurRadius: 5,
                                                        color: Color.fromARGB(
                                                            100, 0, 0, 0),
                                                      )
                                                    ],
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      handlePinTap(
                                                          places.toList()[index]
                                                              ["place_id"],
                                                          LatLng(
                                                              places.toList()[
                                                                          index]
                                                                      [
                                                                      "location"]
                                                                  ["lat"],
                                                              places.toList()[
                                                                          index]
                                                                      [
                                                                      "location"]
                                                                  ["lng"]));
                                                      setState(() {
                                                        viewSug = false;
                                                        fullSugs = false;
                                                      });
                                                    },
                                                    child: Container(
                                                      constraints:
                                                          BoxConstraints(
                                                              maxWidth:
                                                                  Constants.w12(
                                                                      context)),
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              places
                                                                      .toList()
                                                                      .isNotEmpty
                                                                  ? places.toList()[
                                                                          index]
                                                                      ["name"]
                                                                  : '',
                                                              style: TextStyle(
                                                                  color: Constants
                                                                      .black(
                                                                          context),
                                                                  fontWeight:
                                                                      Constants
                                                                          .bold,
                                                                  fontSize:
                                                                      Constants.m(
                                                                          context)),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    style: ButtonStyle(
                                                        padding: MaterialStateProperty.all(
                                                            EdgeInsets.symmetric(
                                                                vertical:
                                                                    Constants.v1(
                                                                        context),
                                                                horizontal:
                                                                    Constants.h1(
                                                                        context))),
                                                        shape: MaterialStateProperty
                                                            .all(
                                                                RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30.0),
                                                        )),
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Constants
                                                                    .trueWhite(
                                                                        context))),
                                                  )),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      bottom: Constants.v2(context)),
                                  child: Container(
                                      height: Constants.a7(context),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(0, 5),
                                            blurRadius: 5,
                                            color: Color.fromARGB(100, 0, 0, 0),
                                          )
                                        ],
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            fullSugs = !fullSugs;
                                          });
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                                fullSugs
                                                    ? AppLocalizations.of(
                                                            context)
                                                        .translate("Menys")
                                                    : AppLocalizations.of(
                                                            context)
                                                        .translate("Mes"),
                                                style: TextStyle(
                                                    color: Constants.black(
                                                        context),
                                                    fontWeight: Constants.bold,
                                                    fontSize:
                                                        Constants.m(context))),
                                          ],
                                        ),
                                        style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                                EdgeInsets.symmetric(
                                                    vertical:
                                                        Constants.v1(context),
                                                    horizontal:
                                                        Constants.h1(context))),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            )),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Constants.trueWhite(
                                                        context))),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 5),
                            blurRadius: 5,
                            color: Color.fromARGB(100, 0, 0, 0),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          SearchInput(
                            labelText: AppLocalizations.of(context)
                                .translate("Cerca_un_espai_obert"),
                            onTapPlace: handlePinTap,
                            focusNode: searchNode,
                          ),
                        ],
                      )),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Constants.trueWhite(context),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                  boxShadow: viewPlace
                      ? [
                          BoxShadow(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.light
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 8), // changes position of shadow
                          ),
                        ]
                      : [],
                ),
                constraints: BoxConstraints(
                  maxHeight: viewPlace ? MediaQuery.of(context).size.height : 0,
                ),
                width: Constants.wFull(context),
                child: Padding(
                  padding: EdgeInsets.only(
                      top: Constants.v2(context),
                      left: Constants.h6(context),
                      right: Constants.h6(context)),
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: Constants.w12(context),
                              child: Text(
                                placeName,
                                style: TextStyle(
                                    fontSize: Constants.l(context),
                                    fontWeight: Constants.bolder),
                                overflow: TextOverflow.clip,
                                maxLines: 1,
                              ),
                            ),
                            InkWell(
                              child: Icon(Icons.close,
                                  size: Constants.xxl(context),
                                  color: Constants.black(context)),
                              onTap: () {
                                setState(() {
                                  viewPlace = false;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          width: Constants.w12(context),
                          child: Text(placeLocation,
                              style: TextStyle(
                                  fontSize: Constants.m(context),
                                  fontWeight: Constants.bold),
                              overflow: TextOverflow.clip,
                              maxLines: 1),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: Constants.v3(context)),
                          child: Row(
                            children: [
                              SvgPicture.asset('assets/icons/placeholder.svg',
                                  color: Constants.black(context),
                                  height: Constants.xxl(context),
                                  width: Constants.xxl(context)),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: Constants.h1(context)),
                                child: SizedBox(
                                  width: Constants.w10(context),
                                  child: Text(
                                    placeAddress,
                                    style: TextStyle(
                                        fontSize: Constants.s(context),
                                        fontWeight: Constants.normal),
                                    overflow: TextOverflow.clip,
                                    maxLines: 1,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: Constants.v1(context)),
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
                                child: Row(
                                  children: [
                                    Text(
                                      placeOpened == true
                                          ? AppLocalizations.of(context)
                                                  .translate("Obert") +
                                              '. '
                                          : AppLocalizations.of(context)
                                                  .translate("Tancat") +
                                              '. ',
                                      style: TextStyle(
                                          color: placeOpened == true
                                              ? Constants.green(context)
                                              : Constants.red(context),
                                          fontSize: Constants.s(context),
                                          fontWeight: Constants.normal),
                                      overflow: TextOverflow.clip,
                                    ),
                                    Text(
                                      placeOpenHours.isEmpty
                                          ? AppLocalizations.of(context)
                                              .translate(
                                                  "Aquest_espai_no_te_horaris")
                                          : todaysHours == 'Open 24 hours'
                                              ? AppLocalizations.of(context)
                                                  .translate("Obert_24_hores")
                                              : todaysHours == 'Closed'
                                                  ? AppLocalizations.of(context)
                                                      .translate("Tancat")
                                                  : todaysHours,
                                      style: TextStyle(
                                          fontSize: Constants.s(context),
                                          fontWeight: Constants.normal),
                                      overflow: TextOverflow.clip,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: Constants.h1(context)),
                                      child: InkWell(
                                        onTap: () => setState(() {
                                          fullHours = !fullHours;
                                        }),
                                        child: Icon(
                                            fullHours == false
                                                ? FontAwesomeIcons.chevronDown
                                                : FontAwesomeIcons.chevronUp,
                                            color: Constants.black(context),
                                            size: 24.0 /
                                                (MediaQuery.of(context)
                                                            .size
                                                            .height <
                                                        700
                                                    ? 1.3
                                                    : MediaQuery.of(context)
                                                                .size
                                                                .height <
                                                            800
                                                        ? 1.15
                                                        : 1)),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        placeOpenHours.isNotEmpty
                            ? AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: Constants.trueWhite(context),
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(30),
                                    bottomLeft: Radius.circular(30),
                                  ),
                                ),
                                constraints: BoxConstraints(
                                  maxHeight: fullHours
                                      ? MediaQuery.of(context).size.height
                                      : 0,
                                ),
                                width: Constants.wFull(context),
                                child: SingleChildScrollView(
                                    physics: NeverScrollableScrollPhysics(),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: Constants.h7(context) +
                                              Constants.h2(context),
                                          right: Constants.h7(context) +
                                              Constants.h2(context)),
                                      child: Column(children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: Constants.v1(context)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)
                                                    .translate("Dilluns"),
                                                style: TextStyle(
                                                    fontSize:
                                                        Constants.s(context),
                                                    fontWeight:
                                                        Constants.normal),
                                                overflow: TextOverflow.clip,
                                              ),
                                              Text(
                                                placeOpenHours[0] != null
                                                    ? placeOpenHours[0] ==
                                                            'Open 24 hours'
                                                        ? AppLocalizations.of(
                                                                context)
                                                            .translate(
                                                                "Obert_24_hores")
                                                        : placeOpenHours[0] ==
                                                                'Closed'
                                                            ? AppLocalizations
                                                                    .of(context)
                                                                .translate(
                                                                    "Tancat")
                                                            : placeOpenHours[0]
                                                    : AppLocalizations.of(
                                                            context)
                                                        .translate("Tancat"),
                                                style: TextStyle(
                                                    fontSize:
                                                        Constants.s(context),
                                                    fontWeight:
                                                        Constants.normal),
                                                overflow: TextOverflow.clip,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: Constants.v1(context)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)
                                                    .translate("Dimarts"),
                                                style: TextStyle(
                                                    fontSize:
                                                        Constants.s(context),
                                                    fontWeight:
                                                        Constants.normal),
                                                overflow: TextOverflow.clip,
                                              ),
                                              Text(
                                                placeOpenHours[1] != null
                                                    ? placeOpenHours[1] ==
                                                            'Open 24 hours'
                                                        ? AppLocalizations.of(
                                                                context)
                                                            .translate(
                                                                "Obert_24_hores")
                                                        : placeOpenHours[1] ==
                                                                'Closed'
                                                            ? AppLocalizations
                                                                    .of(context)
                                                                .translate(
                                                                    "Tancat")
                                                            : placeOpenHours[1]
                                                    : AppLocalizations.of(
                                                            context)
                                                        .translate("Tancat"),
                                                style: TextStyle(
                                                    fontSize:
                                                        Constants.s(context),
                                                    fontWeight:
                                                        Constants.normal),
                                                overflow: TextOverflow.clip,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: Constants.v1(context)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)
                                                    .translate("Dimecres"),
                                                style: TextStyle(
                                                    fontSize:
                                                        Constants.s(context),
                                                    fontWeight:
                                                        Constants.normal),
                                                overflow: TextOverflow.clip,
                                              ),
                                              Text(
                                                placeOpenHours[2] != null
                                                    ? placeOpenHours[2] ==
                                                            'Open 24 hours'
                                                        ? AppLocalizations.of(
                                                                context)
                                                            .translate(
                                                                "Obert_24_hores")
                                                        : placeOpenHours[2] ==
                                                                'Closed'
                                                            ? AppLocalizations
                                                                    .of(context)
                                                                .translate(
                                                                    "Tancat")
                                                            : placeOpenHours[2]
                                                    : AppLocalizations.of(
                                                            context)
                                                        .translate("Tancat"),
                                                style: TextStyle(
                                                    fontSize:
                                                        Constants.s(context),
                                                    fontWeight:
                                                        Constants.normal),
                                                overflow: TextOverflow.clip,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                top: Constants.v1(context)),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)
                                                        .translate("Dijous"),
                                                    style: TextStyle(
                                                        fontSize: Constants.s(
                                                            context),
                                                        fontWeight:
                                                            Constants.normal),
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                  Text(
                                                    placeOpenHours[3] != null
                                                        ? placeOpenHours[3] ==
                                                                AppLocalizations.of(
                                                                        context)
                                                                    .translate(
                                                                        "Obert_24_hores")
                                                            ? AppLocalizations
                                                                    .of(context)
                                                                .translate(
                                                                    "Obert_24_hores")
                                                            : placeOpenHours[
                                                                        3] ==
                                                                    'Closed'
                                                                ? AppLocalizations.of(
                                                                        context)
                                                                    .translate(
                                                                        "Tancat")
                                                                : placeOpenHours[
                                                                    3]
                                                        : AppLocalizations.of(
                                                                context)
                                                            .translate(
                                                                "Tancat"),
                                                    style: TextStyle(
                                                        fontSize: Constants.s(
                                                            context),
                                                        fontWeight:
                                                            Constants.normal),
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ])),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: Constants.v1(context)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)
                                                    .translate("Divendres"),
                                                style: TextStyle(
                                                    fontSize:
                                                        Constants.s(context),
                                                    fontWeight:
                                                        Constants.normal),
                                                overflow: TextOverflow.clip,
                                              ),
                                              Text(
                                                placeOpenHours[4] != null
                                                    ? placeOpenHours[4] ==
                                                            'Open 24 hours'
                                                        ? AppLocalizations.of(
                                                                context)
                                                            .translate(
                                                                "Obert_24_hores")
                                                        : placeOpenHours[4] ==
                                                                'Closed'
                                                            ? AppLocalizations
                                                                    .of(context)
                                                                .translate(
                                                                    "Tancat")
                                                            : placeOpenHours[4]
                                                    : AppLocalizations.of(
                                                            context)
                                                        .translate("Tancat"),
                                                style: TextStyle(
                                                    fontSize:
                                                        Constants.s(context),
                                                    fontWeight:
                                                        Constants.normal),
                                                overflow: TextOverflow.clip,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: Constants.v1(context)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)
                                                    .translate("Dissabte"),
                                                style: TextStyle(
                                                    fontSize:
                                                        Constants.s(context),
                                                    fontWeight:
                                                        Constants.normal),
                                                overflow: TextOverflow.clip,
                                              ),
                                              Text(
                                                placeOpenHours[5] != null
                                                    ? placeOpenHours[5] ==
                                                            'Open 24 hours'
                                                        ? AppLocalizations.of(
                                                                context)
                                                            .translate(
                                                                "Obert_24_hores")
                                                        : placeOpenHours[5] ==
                                                                'Closed'
                                                            ? AppLocalizations
                                                                    .of(context)
                                                                .translate(
                                                                    "Tancat")
                                                            : placeOpenHours[5]
                                                    : AppLocalizations.of(
                                                            context)
                                                        .translate("Tancat"),
                                                style: TextStyle(
                                                    fontSize:
                                                        Constants.s(context),
                                                    fontWeight:
                                                        Constants.normal),
                                                overflow: TextOverflow.clip,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: Constants.v1(context)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)
                                                    .translate("Diumenge"),
                                                style: TextStyle(
                                                    fontSize:
                                                        Constants.s(context),
                                                    fontWeight:
                                                        Constants.normal),
                                                overflow: TextOverflow.clip,
                                              ),
                                              Text(
                                                placeOpenHours[6] != null
                                                    ? placeOpenHours[6] ==
                                                            'Open 24 hours'
                                                        ? AppLocalizations.of(
                                                                context)
                                                            .translate(
                                                                "Obert_24_hores")
                                                        : placeOpenHours[6] ==
                                                                'Closed'
                                                            ? AppLocalizations
                                                                    .of(context)
                                                                .translate(
                                                                    "Tancat")
                                                            : placeOpenHours[6]
                                                    : AppLocalizations.of(
                                                            context)
                                                        .translate("Tancat"),
                                                style: TextStyle(
                                                    fontSize:
                                                        Constants.s(context),
                                                    fontWeight:
                                                        Constants.normal),
                                                overflow: TextOverflow.clip,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                    )))
                            : Container(),
                        Padding(
                          padding: EdgeInsets.only(top: Constants.v1(context)),
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
                                  placeGauge != null
                                      ? placeGauge.toString() +
                                          ' ' +
                                          AppLocalizations.of(context)
                                              .translate("persones")
                                      : '',
                                  style: TextStyle(
                                      fontSize: Constants.s(context),
                                      fontWeight: Constants.normal),
                                  overflow: TextOverflow.clip,
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: Constants.v3(context),
                              bottom: Constants.v4(context)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  constraints: BoxConstraints(
                                      minWidth: Constants.w10(context),
                                      maxWidth: Constants.w11(context)),
                                  child: BorderButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                              pageBuilder: (_, __, ___) =>
                                                  ConsultarAforament(
                                                      placeName,
                                                      placeLocation,
                                                      placeAddress,
                                                      placeId)),
                                        );
                                      },
                                      text: 'Veure més')),
                              Container(
                                  constraints: BoxConstraints(
                                      minWidth: Constants.w10(context),
                                      maxWidth: Constants.w11(context)),
                                  child: BorderButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                              pageBuilder: (_, __, ___) =>
                                                  NotificarAssistencia(
                                                      placeName,
                                                      placeLocation,
                                                      placeAddress,
                                                      placeId)),
                                        );
                                      },
                                      text: 'Vull anar-hi')),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          elevation: 10,
          backgroundColor: Constants.trueWhite(context),
          onPressed: () {
            if (mounted) {
              location.getLocation().then((loc) {
                controller
                    .animateCamera(CameraUpdate.newCameraPosition(
                        CameraPosition(
                            target: LatLng(loc.latitude, loc.longitude),
                            zoom: 18)))
                    .catchError((error) {});
                retrievePlaces(LatLng(loc.latitude, loc.longitude));
              });
            }
            setState(() {
              viewPlace = false;
              searchNode.unfocus();
            });
          },
          child: Icon(
            Icons.location_searching,
            color: Constants.black(context),
          )),
    );
  }
}
