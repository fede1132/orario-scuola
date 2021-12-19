import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:orario_scuola/main.dart';

class CustomTheme {

  static bool _isDark = SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;

  static getDark() => _isDark;
  static setDark(bool val) {
    _isDark = val;
    bloc.changeTheme(val);
  }
  
  static Future<void> checkLocal() async {
    var box = await Hive.openBox("settings");
    if (box.containsKey("theme")) {
      var theme = box.get("theme");
      if (theme == "dark") {
        _isDark = true;
      } 
      if (theme == "light") {
        _isDark = false;
      }
    }
  }

  static ThemeData getTheme() {
    return (_isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
      primaryColor: Colors.blue,
      colorScheme: ColorScheme(
        primary: Colors.blue,
        primaryVariant: Colors.blueAccent,
        secondary: Colors.blueAccent,
        secondaryVariant: Colors.cyan,
        surface: Colors.grey,
        background: _isDark ? Color(0xFF303030) : Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: _isDark ? Colors.white : Colors.black,
        onError: Colors.redAccent,
        brightness: SchedulerBinding.instance!.window.platformBrightness
      ),
      textTheme: TextTheme(
        bodyText2: TextStyle(color: _isDark ? Colors.white : Colors.black),
        headline5: TextStyle(fontWeight: FontWeight.bold, color: _isDark ? Colors.white : Colors.black),
        headline6: TextStyle(fontWeight: FontWeight.bold, color: _isDark ? Colors.white : Colors.black),
        subtitle1: TextStyle(color: _isDark ? Colors.white : Colors.black),
        subtitle2: TextStyle(color: _isDark ? Colors.white : Colors.black),
        button: TextStyle(color: _isDark ? Colors.white : Colors.black),
      ),
      iconTheme: IconThemeData(
        color: _isDark ? Colors.white : Colors.black
      )
    );
  }

}
