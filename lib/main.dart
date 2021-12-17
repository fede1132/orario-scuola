import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:orario_scuola/pages/home.dart';
import 'package:orario_scuola/pages/loading.dart';
import 'package:orario_scuola/pages/select.dart';
import 'package:orario_scuola/pages/tos.dart';
import 'package:orario_scuola/util/internet.dart';
import 'package:orario_scuola/util/localization.dart';
import 'package:orario_scuola/util/scraper.dart';
import 'package:orario_scuola/util/theme.dart';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      var box = await Hive.openBox("settings");
      var storage = await Hive.openBox("storage");
      if (await checkInternetConnection() && FirebaseAuth.instance.currentUser != null) {
        if (!storage.containsKey("url") || storage.get("url")["time"]+3600 < (DateTime.now().millisecondsSinceEpoch/1000).floor()) {
          CollectionReference ref = FirebaseFirestore.instance.collection("storage");
          DocumentSnapshot<dynamic> snapshot = await ref.doc("url").get();
          if (!snapshot.exists) return;
          if (snapshot.data()!["url"] != null) {
            storage.put("url", {
              "time": (DateTime.now().millisecondsSinceEpoch/1000).floor(),
              "value": snapshot.data()!["url"]
            });
          }  
        }
        if (!storage.containsKey("values") || storage.get("values")["time"]+3600 < (DateTime.now().millisecondsSinceEpoch/1000).floor()) {
          try {
            var data = (await http.get(Uri.parse(storage.get("url")["value"]))).body;
            storage.put("values", {
              "value": scrapeValues(data),
              "time": (DateTime.now().millisecondsSinceEpoch/1000).floor()
            });
          } catch (ex) {
            print(ex);
          }
        }
        try {
          CollectionReference ref = FirebaseFirestore.instance.collection("users");
          await ref.doc(FirebaseAuth.instance.currentUser?.uid.toString()).get();
          box.put("admin", true);
        } catch (ex) {
          if ((ex as FirebaseException).code == "permission-denied") {
            box.put("admin", false);
          }
        }
      }
      theme = await CustomTheme().getTheme();
      setState(() {
        if (FirebaseAuth.instance.currentUser == null) {
          home = const TOS();
          return;
        }
        if (!storage.containsKey("schedule-${box.get("select_type")}-${box.get("select_value")}")) {
          home = const Select();
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
    if (home is Loading) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) { 
        if (user == null) {
          return;
        }
        if (user.email!.endsWith("@gobettire.istruzioneer.it")) {
          print("right mail :)");
          return;
        }
        showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) => AlertDialog(
          title: Text(AppLocalizations.instance.text("email.wrong-domain.title")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(AppLocalizations.instance.text("email.wrong-domain"))
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text("Chiudi"),
            )
          ],
        ));
      });
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
