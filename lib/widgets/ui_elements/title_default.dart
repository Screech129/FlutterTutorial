import 'package:flutter/material.dart';

class TitleDefault extends StatelessWidget {
  final String titleText;

TitleDefault(this.titleText);

  @override
  Widget build(BuildContext context) {
    return Text(
      titleText,
      style: TextStyle(
          fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: 'Oswald'),
    );
  }
}
