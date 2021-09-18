import 'package:flutter/material.dart';
import 'package:orario_scuola/pages/agreement.dart';
import 'package:orario_scuola/pages/home.dart';
import 'package:orario_scuola/services/scraper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loading extends StatefulWidget {
  Loading({Key key}) : super(key: key);

  @override
  _Loading createState() => _Loading();
}

class _Loading extends State<Loading> {

  @override
  void initState() {
    super.initState();
  }

  _load(BuildContext context) {
    Future(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool agreement = prefs.containsKey("OrarioScuolaAgreement");
      if (agreement) await Scraper().getValues();
      return agreement;
    }).then((value) {
      if (value) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      else Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Agreement()));
    });
  }

  @override
  Widget build(BuildContext context) {
    _load(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Caricamento in corso..."),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Caricamento in corso...")
          ],
        ),
      ),
    );
  }

}