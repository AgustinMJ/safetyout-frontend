import 'package:app/defaults/constants.dart';
import 'package:flutter/material.dart';

TextEditingController textController = TextEditingController();

class LocationInput extends StatelessWidget {
  LocationInput(
      {this.text, this.onChanged, this.type, this.onSubmitted, this.focusNode});

  final String text;
  final Function onChanged;
  final TextInputType type;
  final Function onSubmitted;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: Constants.a7(context),
        child: TextField(
            readOnly: true,
            focusNode: focusNode,
            onSubmitted: onSubmitted,
            onChanged: onChanged,
            autocorrect: false,
            keyboardType: type,
            style: TextStyle(color: Constants.black(context)),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: Constants.h3(context),
              ),
              filled: true,
              fillColor: Constants.trueWhite(context),
              hintText: text,
              hintStyle: TextStyle(
                  fontSize: Constants.m(context),
                  color: Constants.black(context),
                  fontWeight: Constants.bold),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(40),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(40),
              ),
            )),
      ),
    );
  }
}
