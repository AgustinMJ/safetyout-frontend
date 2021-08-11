import 'package:flutter/material.dart';

import 'package:app/defaults/constants.dart';

class BorderButton extends StatelessWidget {
  BorderButton({this.onPressed, this.text});

  final Function onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: onPressed,
        child: Text(text),
        style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
                TextStyle(fontSize: Constants.xs(context))),
            foregroundColor:
                MaterialStateProperty.all(Constants.black(context)),
            side: MaterialStateProperty.all(
                BorderSide(color: Constants.black(context), width: 1)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)))));
  }
}
