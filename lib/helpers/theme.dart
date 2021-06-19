import 'package:flutter/material.dart';

class SeaworldTheme {
  final MaterialColor themeColor;
  final Brightness brightness;
  SeaworldTheme({this.themeColor = Colors.lightBlue, this.brightness = Brightness.light});

  ThemeData get data => ThemeData(
    primarySwatch: themeColor,
    brightness: brightness,
    fontFamily: "Public Sans",
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateColor.resolveWith((states) => Colors.white)
      )
    ),
    textTheme: TextTheme(
      button: TextStyle(fontWeight: FontWeight.w700),
      headline1: TextStyle(fontFamily: "DM Sans"),
      headline2: TextStyle(fontFamily: "DM Sans"),
      headline3: TextStyle(fontFamily: "DM Sans"),
      headline4: TextStyle(fontFamily: "DM Sans"),
      headline5: TextStyle(fontFamily: "DM Sans"),
      headline6: TextStyle(fontFamily: "DM Sans"),
    )
  );
}