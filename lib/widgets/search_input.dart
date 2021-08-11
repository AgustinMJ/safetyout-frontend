import 'dart:async';
import 'dart:convert';

import 'package:app/defaults/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class SearchInput extends StatefulWidget {
  SearchInput(
      {Key key,
      this.labelText,
      this.prefixIcon,
      this.focusNode,
      this.onTapPlace})
      : super(key: key);

  final String labelText;
  final IconData prefixIcon;
  final FocusNode focusNode;
  final Function onTapPlace;

  @override
  SearchInputState createState() => SearchInputState(
      labelText: this.labelText,
      prefixIcon: this.prefixIcon,
      focusNode: this.focusNode,
      onTapPlace: this.onTapPlace);
}

class SearchInputState extends State<SearchInput> {
  SearchInputState(
      {this.labelText, this.prefixIcon, this.focusNode, this.onTapPlace});

  final String labelText;
  final IconData prefixIcon;
  final FocusNode focusNode;
  final Function onTapPlace;

  List<dynamic> predictions = [];
  Timer debounce;

  void autoCompleteSearch(String value) async {
    var urlPark = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=" +
            value +
            "&keyword=park&fields=geometry,place_id,name&language=" +
            Localizations.localeOf(context).languageCode +
            "&key=AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA");
    var urlNature = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=" +
            value +
            "&keyword=nature&fields=geometry,place_id,name&language=" +
            Localizations.localeOf(context).languageCode +
            "&key=AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA");
    var urlSight = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=" +
            value +
            "&keyword=sightseeing&fields=geometry,place_id,name&language=" +
            Localizations.localeOf(context).languageCode +
            "&key=AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA");
    var urlTerrace = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=" +
            value +
            "&keyword=terrace&fields=geometry,place_id,name&key=AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA");
    var urlMountain = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=" +
            value +
            "&keyword=mountain&fields=geometry,place_id,name&language=" +
            Localizations.localeOf(context).languageCode +
            "&key=AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA");
    var urlCastle = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=" +
            value +
            "&keyword=castle&fields=geometry,place_id,name&language=" +
            Localizations.localeOf(context).languageCode +
            "&key=AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA");
    var urlRes = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=" +
            value +
            "&keyword=outdoor seating&fields=geometry,place_id,name&language=" +
            Localizations.localeOf(context).languageCode +
            "&key=AIzaSyALjO4lu3TWJzLwmCWBgNysf7O1pgje1oA");

    List<dynamic> pres = [];

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
        if (r != null && r.statusCode == 200 && mounted) {
          Map<String, dynamic> body = jsonDecode(r.body);
          List<dynamic> results = body["results"];
          results.forEach((r) {
            pres.add(r);
          });
        }
        ;
      });
      setState(() {
        final ids = pres.map((e) => e["place_id"]).toSet();
        pres.retainWhere((x) => ids.remove(x["place_id"]));
        predictions = pres;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Constants.trueWhite(context),
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: predictions.isNotEmpty && focusNode.hasFocus
                  ? Constants.a12(context)
                  : 0,
            ),
            width: Constants.wFull(context),
            child: Padding(
              padding: EdgeInsets.only(
                top: Constants.v7(context) + Constants.v3(context),
              ),
              child: ListView.builder(
                itemCount: predictions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Constants.trueWhite(context),
                      child: Icon(
                        Icons.pin_drop,
                        color: Constants.grey(context),
                      ),
                    ),
                    title: Text(predictions[index]["name"],
                        style: TextStyle(
                          color: Constants.black(context),
                          fontSize: Constants.s(context),
                        )),
                    onTap: () {
                      onTapPlace(
                          predictions[index]["place_id"],
                          LatLng(
                              predictions[index]["geometry"]["location"]["lat"],
                              predictions[index]["geometry"]["location"]
                                  ["lng"]));
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: Constants.a7(context),
            child: TextField(
                focusNode: focusNode,
                onChanged: (value) {
                  if (debounce != null && debounce.isActive) {
                    debounce.cancel();
                  }

                  if (value.isNotEmpty) {
                    debounce = Timer(Duration(milliseconds: 1000), () {
                      autoCompleteSearch(value);
                    });
                  } else {
                    if (predictions.isNotEmpty) {
                      debounce.cancel();
                      setState(() {
                        predictions = [];
                      });
                    }
                  }
                  ;
                },
                autocorrect: false,
                onSubmitted: (value) {
                  focusNode.unfocus();
                },
                style: TextStyle(color: Constants.black(context)),
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: Constants.h3(context)),
                    filled: true,
                    fillColor: Constants.trueWhite(context),
                    labelText: labelText,
                    labelStyle: TextStyle(
                        fontSize: Constants.m(context),
                        color: Constants.grey(context)),
                    hintText: labelText,
                    hintStyle: TextStyle(
                        fontSize: Constants.m(context),
                        color: Constants.grey(context)),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 15, right: 10),
                      child: SvgPicture.asset('assets/icons/loupe.svg',
                          color: Constants.grey(context),
                          height: 20 /
                              (MediaQuery.of(context).size.width < 380
                                  ? 1.3
                                  : 1)),
                    ))),
          ),
        ],
      ),
    );
  }
}
