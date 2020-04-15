import 'dart:io';

import 'package:flutter/material.dart';

final ThemeData _androidTheme = ThemeData(
  primarySwatch: Colors.green,
  primaryColor: Colors.green,
  accentColor: Colors.blue,
  brightness: Brightness.dark,
  buttonColor: Colors.blue,
);

final ThemeData _iosTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.orange,
  accentColor: Colors.blue,
  brightness: Brightness.dark,
  buttonColor: Colors.blue,
);

ThemeData getAdaptiveThemeData(context) {
  return Platform.isIOS ? _iosTheme : _androidTheme;
}
