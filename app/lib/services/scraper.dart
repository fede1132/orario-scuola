import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:http/http.dart' as http;
import 'online.dart' as OnlineChecker;

class Scraper {

  // ignore: non_constant_identifier_names
  static String URL;
  static var scraped;

  runScraper() async {
    var success = false;
    // first run
    // try with the algorithm
    var response = await http.get('http://istitutogobetti.it/2020/');
    var scraper = WebScraper('http://istitutogobetti.it');
    if (await scraper.loadWebPage('/2020')) {
      var elements = scraper.getElement("#jsn-pos-left > div:nth-child(1) > div > div > div > div > ul > li", ['children']).map((e) => e['title']).toList();
    }
  }

  getGistUrl() async {
    var response = await http.get('https://api.github.com/gists/076efba5988869351cc295f6ac566c65');
    if (response.statusCode != 200) return;
    var data = json.decode(response.body);
    Scraper.URL = data['files']['url.txt']['content'];
  }

  getValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var scraped = {"classi": <String>[], "docenti": <String>[], "aule": <String>[]};
    if (!await OnlineChecker.OnlineChecker.isOnline()) {
      if (prefs.containsKey("OrarioScuolaClassi")) {
        scraped["classi"] = prefs.getStringList("OrarioScuolaClassi");
        scraped["docenti"] = prefs.getStringList("OrarioScuolaDocenti");
        scraped["aule"] = prefs.getStringList("OrarioScuolaAule");
        return scraped;
      } else {
        return scraped;
      }
    }
    if (URL==null) await runScraper();
    var path = URL.split(RegExp('(http:).*\.(it|com|edu|net|org)'))[1];
    final scraper = WebScraper(URL.replaceAll(path, ''));
    if (await scraper.loadWebPage(path)) {
      List<Map<String, dynamic>> elements = scraper.getElement('body > center > table > tbody > tr > td > p > a', ['href']);
      elements.forEach((element) {
        var title = element.values.first;
        String href = element.values.last.values.first;
        scraped[(href.contains("Classi/") ? "classi" : (href.contains("Docenti/") ? "docenti" : "aule"))].add(title);
      });
    }
    Scraper.scraped = scraped;
    prefs.setStringList("OrarioScuolaClassi", scraped["classi"]);
    prefs.setStringList("OrarioScuolaDocenti", scraped["docenti"]);
    prefs.setStringList("OrarioScuolaAule", scraped["aule"]);
    return scraped;
  }

  getOrario(type, value) async {
    if (URL==null) await runScraper();
    var url = URL.replaceAll('index.html', '');
    var response = await http.get('$url$type/$value.html');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (response.statusCode != 200) {
      prefs.setString("OrarioScuolaContent", '<h1 style="color: red;">Impossibile trovare una pagina al link: $url$type/$value.html</h1>');
      return '<h1 style="color: red;">Impossibile trovare una pagina al link: $url$type/$value.html</h1>';
    }
    var regex = new RegExp(r'''href=(["'])(.*?)\1''');
    String body = response.body.replaceAll(regex, '');
    prefs.setString("OrarioScuolaContent", body);
    return body;
  }
}