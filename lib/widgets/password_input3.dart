import 'package:app/defaults/constants.dart';
import 'package:flutter/material.dart';

class PasswordInput3 extends StatefulWidget {
  PasswordInput3(
      {this.labelText, this.onChanged, this.onSubmitted, this.focusNode});

  final String labelText;
  final Function onChanged;
  final Function onSubmitted;
  final FocusNode focusNode;

  @override
  PasswordInput3State createState() => PasswordInput3State(
      labelText: this.labelText,
      onChanged: this.onChanged,
      onSubmitted: this.onSubmitted,
      focusNode: this.focusNode);
}

class PasswordInput3State extends State<PasswordInput3> {
  PasswordInput3State(
      {this.labelText, this.onChanged, this.onSubmitted, this.focusNode});

  final String labelText;
  final Function onChanged;
  final Function onSubmitted;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: Constants.a7(context),
        child: TextField(
            focusNode: focusNode,
            onSubmitted: onSubmitted,
            onChanged: onChanged,
            autocorrect: false,
            obscureText: true,
            style: TextStyle(color: Constants.black(context)),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: Constants.h3(context),
                  vertical: Constants.v3(context)),
              filled: true,
              fillColor: Constants.lightGrey(context),
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
            )),
      ),
    );
  }
}
