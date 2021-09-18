import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orario_scuola/services/online.dart';
import 'package:orario_scuola/services/scraper.dart';
import 'package:orario_scuola/pages/settings.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  bool _online = true;
  String _html = "<h1>Caricamento in corso...</h1>";
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
  }

  _loadSettings() async {
    if (_loaded) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var htmlData;
    if (_online = await OnlineChecker.isOnline()) {
      htmlData = await Scraper().getOrario((prefs.containsKey("OrarioScuolaOrarioTipo") ? (prefs.getString("OrarioScuolaOrarioTipo") == 'Classe' ? 'Classi' : (prefs.getString("OrarioScuolaOrarioTipo") == 'Docente' ? 'Docenti' : 'Aule')) : "Classi"), (prefs.containsKey("OrarioScuolaOrarioValore") ? prefs.getString("OrarioScuolaOrarioValore") : Scraper.scraped["classi"].first));
    }
    if (this.mounted) {
      if (htmlData==null) _setHtml(prefs.getString("OrarioScuolaContent"));
      else _setHtml(htmlData);
      setState(() {
        _loaded = true;
      });
    }
  }

  _setHtml(html) async {
    setState(() {
      _html = html;
      debugPrint(html);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.settings), onPressed: ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Settings()))),
          if (!_online)
            Builder(builder: (BuildContext context) {
              return IconButton(
                  icon: Icon(Icons.signal_wifi_off),
                  color: Colors.redAccent,
                  onPressed: () {
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Nessun accesso a internet!")));
                  }
              );
            })
        ],
      ),
      body: Center(
        child: EasyWebView(
          src: _html,
          isHtml: true,
          isMarkdown: false,
          onLoaded: () async {
            await _loadSettings();
          }
        )
      )
    );
  }

}

