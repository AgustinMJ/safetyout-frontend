import 'dart:convert';
import 'dart:io';

import 'package:app/app_localizations.dart';
import 'package:app/defaults/constants.dart';
import 'package:app/pages/app.dart';
import 'package:app/storage/secure_storage.dart';
import 'package:app/widgets/raw_input.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class EditProfile extends StatefulWidget {
  EditProfile(this.name, this.surnames, this.photoUrl, {Key key})
      : super(key: key);

  String name;
  String surnames;
  String photoUrl;

  @override
  _EditProfile createState() =>
      _EditProfile(this.name, this.surnames, this.photoUrl);
}

class _EditProfile extends State<EditProfile> {
  _EditProfile(this.name, this.surnames, this.photoUrl);

  String name;
  String surnames;
  String photoUrl;
  File image;

  Future<void> submitProfile(BuildContext context) async {
    String userId = await SecureStorage.readSecureStorage('SafetyOUT_UserId');
    var uri = Uri.parse('https://safetyout.herokuapp.com/user/' + userId);

    var request = http.MultipartRequest('PATCH', uri)
      ..fields['new_name'] = name
      ..fields['new_surnames'] = surnames;

    if (image != null) {
      request.files.add(await http.MultipartFile(
          'profileImage', image.readAsBytes().asStream(), image.lengthSync(),
          filename: "profileImage"));
    } else {
      // ignore: unawaited_futures
      Navigator.of(context).pushReplacement(
          PageRouteBuilder(pageBuilder: (_, __, ___) => App()));
    }
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      // ignore: unawaited_futures
      Navigator.of(context).pushReplacement(
          PageRouteBuilder(pageBuilder: (_, __, ___) => App()));
      Map<String, dynamic> body = jsonDecode(response.body);
      int achievementId = body["trophy"];

      if (achievementId == 1) {
        String achievementIcon = "camera master";
        String achievementText =
            AppLocalizations.of(context).translate("Afegeix una foto");
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                content: SingleChildScrollView(
                    child: Column(
                  children: [
                    Image(
                        height: Constants.xxl(context) +
                            Constants.xxl(context) +
                            Constants.xxl(context) +
                            Constants.xs(context),
                        image: AssetImage("assets/icons/achievements/" +
                            achievementIcon +
                            ".png")),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          Constants.h1(context),
                          Constants.v1(context),
                          Constants.h1(context),
                          Constants.v1(context)),
                      child: Text(achievementText),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          Constants.h1(context),
                          Constants.v1(context),
                          Constants.h1(context),
                          Constants.v1(context)),
                      child: Text(
                          AppLocalizations.of(context)
                              .translate("Nou assoliment!"),
                          style: TextStyle(
                              color: Constants.black(context),
                              fontWeight: Constants.bold)),
                    )
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
    } else {
      // ignore: unawaited_futures
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(children: [
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
                child: Text(
                    AppLocalizations.of(context).translate("Editar_Perfil"),
                    style: TextStyle(
                        color: Constants.darkGrey(context),
                        fontSize: Constants.xl(context),
                        fontWeight: Constants.bolder)),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: Constants.xxs(context)),
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () => submitProfile(context),
                    child: Icon(Icons.check_rounded,
                        size: 32 /
                            (MediaQuery.of(context).size.width < 380 ? 1.3 : 1),
                        color: Constants.black(context)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: EdgeInsets.only(top: Constants.v7(context)),
            child: Column(
              children: [
                //Imagen perfil
                Container(
                  width: Constants.w9(context),
                  height: Constants.w9(context),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: image != null ? FileImage(image) : NetworkImage(
                              //Imagen de prueba, se colocará la imagen del usuario
                              photoUrl))),
                ),
              ],
            ),
          ),
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: Constants.v2(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      //Boton editar perfil
                      Padding(
                        padding: EdgeInsets.only(top: Constants.v1(context)),
                        child: Container(
                          height: Constants.a6(context) + Constants.a2(context),
                          width: Constants.w10(context),
                          child: TextButton(
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate("Canviar_foto"),
                              style: TextStyle(
                                  fontSize: Constants.xs(context),
                                  fontWeight: Constants.bolder,
                                  color: Constants.black(context)),
                            ),
                            onPressed: () async {
                              final pickedFile = await ImagePicker.pickImage(
                                  source: ImageSource.gallery);
                              setState(() {
                                if (pickedFile != null) {
                                  image = pickedFile;
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Constants.trueWhite(context),
                                textStyle: TextStyle(
                                  color: Constants.black(context),
                                ),
                                side:
                                    BorderSide(color: Constants.black(context)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(Constants.h6(context),
              Constants.v7(context), Constants.h6(context), 0),
          child: Row(
            children: [
              RawInput(
                labelText: name,
                onChanged: (value) => setState(() {
                  name = value;
                }),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(Constants.h6(context),
              Constants.v6(context), Constants.h6(context), 0),
          child: Row(
            children: [
              RawInput(
                labelText: surnames,
                onChanged: (value) => setState(() {
                  surnames = value;
                }),
              )
            ],
          ),
        ),
      ]),
    ));
  }
}
