import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

class CustomTheme {
  
  Future<ThemeData> getTheme() async {
    var box = await Hive.openBox("settings");
    var brightness = SchedulerBinding.instance!.window.platformBrightness;
    bool isDark = brightness == Brightness.dark;
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
        headline6: TextStyle(fontWeight: FontWeight.bold)
      )
    );
  }

}
