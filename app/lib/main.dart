import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:orario_scuola/pages/home.dart';
import 'package:orario_scuola/pages/loading.dart';
import 'package:orario_scuola/pages/tos.dart';
import 'package:orario_scuola/util/localization.dart';
import 'package:orario_scuola/util/theme.dart';

void main() async {
  await Hive.initFlutter();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _App();
}

class _App extends State<App> {

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      theme = await CustomTheme().getTheme();
      var box = await Hive.openBox("settings");
      setState(() {
        if (!box.containsKey("token")) {
          home = const TOS();
          return;
        }
        home = const Home();
      });
    });

    super.initState();
  }

  ThemeData? theme;
  Widget home = const Loading();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orario Scuola',
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('it', ''),
      ],
      localeResolutionCallback:
          (Locale? locale, Iterable<Locale> supportedLocales) {
        for (Locale supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale!.languageCode ||
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      theme: theme ?? ThemeData.light(),
      darkTheme: theme ?? ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: home,
    );
  }

}
