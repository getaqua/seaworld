import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'config.dart';

class SeaworldTheme {
  final MaterialColor themeColor;
  final Brightness brightness;
  SeaworldTheme({this.themeColor = Colors.lightBlue, this.brightness = Brightness.light});

  get _default => Config.darkmode ? ThemeData.dark() : ThemeData.light();

  ThemeData get data => ThemeData(
    primarySwatch: themeColor,
    brightness: brightness,
    fontFamily: "Public Sans",
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(onPrimary: themeColor.shade400.computeLuminance() > 0.5 ? Colors.black : Colors.white)
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: themeColor, accentColor: Colors.deepPurple, brightness: brightness),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? themeColor : Colors.grey),
      trackColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? themeColor.shade300 : Colors.grey.shade300)
    ),
    // bottomNavigationBarTheme: BottomNavigationBarThemeData(
    //   selectedIconTheme: IconThemeData(color: Colors.white),
    //   selectedLabelStyle: TextStyle(color: Colors.white),
    //   selectedItemColor: Colors.white,
    //   unselectedIconTheme: IconThemeData(color: Colors.white),
    //   unselectedLabelStyle: TextStyle(color: Colors.white),
    //   unselectedItemColor: Colors.white,
    // ),
    textTheme: TextTheme(
      button: _default.textTheme.button?.apply(fontFamily: "DM Sans"),
      headline1: _default.textTheme.headline1?.apply(fontFamily: "DM Sans"),
      headline2: _default.textTheme.headline2?.apply(fontFamily: "DM Sans"),
      headline3: _default.textTheme.headline3?.apply(fontFamily: "DM Sans"),
      headline4: _default.textTheme.headline4?.apply(fontFamily: "DM Sans"),
      headline5: _default.textTheme.headline5?.apply(fontFamily: "DM Sans"),
      headline6: _default.textTheme.headline6?.apply(fontFamily: "DM Sans"),
    ),
  );

  static SeaworldTheme fromConfig() {
    return SeaworldTheme(brightness: Config.darkmode ? Brightness.dark : Brightness.light);
  }
}