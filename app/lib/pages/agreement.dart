import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:orario_scuola/pages/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Agreement extends StatefulWidget {
  Agreement({Key key}) : super(key: key);

  _Agreement createState() => _Agreement();
}

class _Agreement extends State<Agreement> {
  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle = TextStyle(color: Colors.black, fontSize: 16.0);
    TextStyle linkStyle = TextStyle(color: Colors.blue);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RichText(
                  text: TextSpan(
                    style: defaultStyle,
                    children: [
                      TextSpan(text: "Cliccando sul bottone sottostante si acconsente all'invio di dati anonimi secondo la normativa europea del GDPR. Si accetta inoltre i "),
                      TextSpan(
                          text: "termini di servizio",
                          style: linkStyle,
                          recognizer: TapGestureRecognizer()..onTap = () async => await launch("https://marketingplatform.google.com/about/analytics/terms/it/")
                      ),
                      TextSpan(text: " di Google Analytics (Google Inc.). Questa app non é in alcun modo affilita con l'istituto di scuola superiore Piero Gobetti di Scandiano.")
                    ]
                  )
              ),
              SizedBox(height: 50),
              FlatButton(
                  color: Colors.amberAccent,
                  splashColor: Colors.yellowAccent,
                  height: 50,
                  minWidth: 150,
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setBool("OrarioScuolaAgreement", true);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Loading()));
                  },
                  child: Text("Acconsento", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))
            ],
          ),
        ),
      ),
    );
  }

}