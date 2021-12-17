import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:orario_scuola/components/scaffold.dart';
import 'package:orario_scuola/pages/home.dart';
import 'package:orario_scuola/util/internet.dart';
import 'package:orario_scuola/util/localization.dart';
import 'package:http/http.dart' as http;
import 'package:orario_scuola/util/scraper.dart';

class Select extends StatefulWidget {
  const Select({Key? key}) : super(key: key);

  @override
  State<Select> createState() => _Select();
}

class _Select extends State<Select> {
  _loadData() async {
    var box = await Hive.openBox("storage");
    if (box.containsKey("values")) {
      bool internet = await checkInternetConnection();
      var value = box.get("values")["value"];
      for (var i=0;i<value.length;i++) {
        for (var j in value[i]) {
          if (_values[i] == null) _values[i] = [];
          if (internet || box.containsKey("schedule-$i-$j")) {
            _values[i]!.add(j);
          }
        }
      }
    }
    setState(() {
      
    });
  }
  Map<int, List<String>> _values = {};

  @override
  void initState() {
    super.initState();
  }

  _download(int i, String j) async {
    var box = await Hive.openBox("storage");
    var settings = await Hive.openBox("settings");
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.instance.text("dialog.schedule.downloading.title")),
        content: Row(
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(width: 10),
            Text(AppLocalizations.instance.text("dialog.schedule.downloading"))
          ],
        ),
      )
    );
    var data;
    try {
      data = (await http.get(Uri.parse("${box.get("url")["value"]}/${["Classi", "Docenti", "Aule"].elementAt(i)}/$j"))).body;
    } catch (ex) {
      print(ex);
      return;
    }
    settings.put("select_type", i.toString());
    settings.put("select_value", j);
    box.put("schedule-$i-$j", {
      "value": scrape(data),
      "time": (DateTime.now().millisecondsSinceEpoch/1000).floor()
    });
    Navigator.of(context).pop();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.instance.text("dialog.schedule.downloaded.title")),
        content: Row(
          children: <Widget>[
            Expanded(
              child: Text(AppLocalizations.instance.text("dialog.schedule.downloaded")),
            )
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => Home()));
            },
            child: Text(AppLocalizations.instance.text("dialog.close")),
          )
        ],
      )
    );
  }

  _showItems(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Future.delayed(Duration.zero, () async {
      if (_values.length == 0) await _loadData();
      List<Widget> result = <Widget>[];
      for (var type in _values.keys) {
        if (_values[type] == null) continue;
        for (var value in _values[type]!) {
          if (_controller.text.isEmpty || value.toLowerCase().contains(_controller.text.toLowerCase())) {
            var box = await Hive.openBox("storage");
            result.add(
              MaterialButton(
                onPressed: () async {
                  await _download(type, value);
                },
                child: Text("$value ${box.containsKey("schedule-$type-$value") ? "(${AppLocalizations.instance.text("select.available-offline")})" : ""}", style: theme.textTheme.button?.copyWith(color: theme.primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)),
                color: _values[type]!.indexOf(value) % 2 == 0 ? theme.primaryColor : theme.primaryColor.withOpacity(0.5),
              )
            );
          }
        }
      }
      if (result.length == 0) {
        result.add(
          MaterialButton(
            color: Colors.red,
            onPressed: () {

            },
            child: Text(AppLocalizations.instance.text("select.no-match"), style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          )
        );
      }
      _items = result;
      setState(() {
        
      });
    });
  }

  List<Widget> _items = <Widget>[];
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) _showItems(context);
    return ScaffoldComponent(
      showSettings: false,
      title: AppLocalizations.instance.text("appbar.title.select"),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _controller,
            onChanged: (String value) {
              _showItems(context);
            },
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: AppLocalizations.instance.text("textfield.select-search"),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: _items,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              padding: EdgeInsets.all(5),
            ),
          )
        ],
      ),
    );
  }
}
