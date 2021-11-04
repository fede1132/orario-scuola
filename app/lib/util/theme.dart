import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

class CustomTheme {

  static bool isDark = SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;
  
  Future<ThemeData> getTheme() async {
    var box = await Hive.openBox("settings");
    if (box.containsKey("themeMode")) {
      var themeMode = box.get("themeMode");
      if (themeMode == ThemeMode.dark) {
        isDark = true;
      } 
      if (themeMode == ThemeMode.light) {
        isDark = false;
      }
    }
    return (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
      primaryColor: Colors.blue,
      textTheme: TextTheme(
        bodyText2: TextStyle(color: isDark ? Colors.white : Colors.black),
        headline5: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
        headline6: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
        subtitle1: TextStyle(color: isDark ? Colors.white : Colors.black),
        subtitle2: TextStyle(color: isDark ? Colors.white : Colors.black),
      )
    );
  }

}
