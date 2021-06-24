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
      button: ThemeData.fallback().textTheme.button?.apply(fontFamily: "DM Sans"),
      headline1: ThemeData.fallback().textTheme.headline1?.apply(fontFamily: "DM Sans"),
      headline2: ThemeData.fallback().textTheme.headline2?.apply(fontFamily: "DM Sans"),
      headline3: ThemeData.fallback().textTheme.headline3?.apply(fontFamily: "DM Sans"),
      headline4: ThemeData.fallback().textTheme.headline4?.apply(fontFamily: "DM Sans"),
      headline5: ThemeData.fallback().textTheme.headline5?.apply(fontFamily: "DM Sans"),
      headline6: ThemeData.fallback().textTheme.headline6?.apply(fontFamily: "DM Sans"),
    ),
  );
}