import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:orario_scuola/components/scaffold.dart';
import 'package:orario_scuola/pages/home.dart';
import 'package:orario_scuola/pages/tos.dart';
import 'package:orario_scuola/util/api.dart';
import 'package:orario_scuola/util/internet.dart';
import 'package:orario_scuola/util/localization.dart';

class Select extends StatefulWidget {
  const Select({Key? key}) : super(key: key);

  @override
  State<Select> createState() => _Select();
}

class _Select extends State<Select> {
  _loadData() async {
    var box = await Hive.openBox("storage");
    if (box.containsKey("values")) {
      var value = box.get("values");
      if (!(await checkInternetConnection()) || (value.time+(12*3600) > (DateTime.now().millisecondsSinceEpoch).floor() && value.time > (await API.inst.update()).value)) {
        _values = value.values;
        return;
      }
    }
    var api = await API.inst.getValues();
    if (!api.success) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(AppLocalizations.instance.text("${api.code}.title")),
          content: Row(
            children: <Widget>[
              Expanded(
                child: Text(AppLocalizations.instance.text(api.code!)),
              )
            ],
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.instance.text("dialog.close")),
              onPressed: () {
                if (api.code == "token.invalid") {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
                    return const TOS();
                  }));
                  return;
                }
                Navigator.pop(context, AppLocalizations.instance.text("dialog.close"));
              },
            )
          ],
        )
      );
      return;
    }
    var list = api.value;
    for (var i=0;i<list.length;i++) {
      _values.add([]);
      for (var j=0;j<list[i].length;j++) {
        _values[i].add(list[i][j]);
      }
    }
    setState(() {
      
    });
  }
  List<List<String>> _values = [];

  @override
  void initState() {
    super.initState();
  }

  _download(int i, int j) async {
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
    if (!(await checkInternetConnection())) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(AppLocalizations.instance.text("internet.not-connected.title")),
          content: Row(
            children: <Widget>[
              Expanded(
                child: Text(AppLocalizations.instance.text("internet.not-connected")),
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                var box = await Hive.openBox("storage");
                if (box.containsKey("schedule-$i-${_values[i][j]}")) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => Home()));
                }
              },
              child: Text(AppLocalizations.instance.text("dialog.close")),
            )
          ],
        )
      );
      return;
    }
    var api = await API.inst.getSchedule(i.toString(), _values[i][j]);
    if (!api.success) {
      Navigator.of(context).pop();
      if (settings.containsKey("select_type")) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => Home()));
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(AppLocalizations.instance.text("${api.code}.title")),
          content: Row(
            children: <Widget>[
              Expanded(
                child: Text(AppLocalizations.instance.text(api.code!)),
              )
            ],
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.instance.text("dialog.close")),
              onPressed: () {
                if (api.code == "token.invalid") {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
                    return const TOS();
                  }));
                  return;
                }
                Navigator.pop(context, AppLocalizations.instance.text("dialog.close"));
              },
            )
          ],
        )
      );
      return;
    }
    settings.put("select_type", i.toString());
    settings.put("select_value", _values[i][j]);
    box.put("schedule-$i-${_values[i][j]}", {
      "data": api.value,
      "time": (DateTime.now().microsecondsSinceEpoch/1000).floor()
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

  _showItems() {
    Future.delayed(Duration.zero, () async {
      if (_values.length == 0) await _loadData();
      List<Widget> result = <Widget>[];
      for (int i=0;i<_values.length;i++) {
        for (int j=0;j<_values[i].length;j++) {
          if (_controller.text.isEmpty || _values[i][j].toLowerCase().contains(_controller.text.toLowerCase())) {
            var box = await Hive.openBox("storage");
            result.add(
              MaterialButton(
                onPressed: () async {
                  await _download(i, j);
                },
                child: box.containsKey("schedule-$i-${_values[i][j]}") ? Text("${_values[i][j]} (${AppLocalizations.instance.text("select.available-offline")})") : Text("${_values[i][j]}"),
                color: Colors.blue,
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
    if (_items.isEmpty) _showItems();
    return ScaffoldComponent(
      showSettings: false,
      title: AppLocalizations.instance.text("appbar.title.select"),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _controller,
            onChanged: (String value) {
              _showItems();
            },
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: AppLocalizations.instance.text("textfield.select-search"),
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: _items,
            ),
          )
        ],
      ),
    );
  }
}
