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
  _loadData() {
    Future.delayed(Duration.zero, () async {
      var settings = await Hive.openBox("settings");
      if (settings.containsKey("select_type")) {
        _selectedType = settings.get("select_type");
      }
      if (settings.containsKey("select_value")) {
        _selectedValue = settings.get("select_value");
      }
      var box = await Hive.openBox("storage");
      if (box.containsKey("values")) {
        var value = box.get("values");
        if (value.time > (DateTime.now().millisecondsSinceEpoch/1000).floor()+3600) {
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
          _values[i].add(DropdownMenuItem(
            child: Text(list[i][j]),
            value: list[i][j],
          ));
        }
      }
      setState(() {
        
      });
    });
  }

  String? _selectedType;
  String? _selectedValue;
  List<String> _keys = [
    AppLocalizations.instance.text("select.class"),
    AppLocalizations.instance.text("select.teacher"),
    AppLocalizations.instance.text("select.room")
  ];
  List<List<DropdownMenuItem<String>>> _values = [];

  @override
  void initState() {
    _loadData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ScaffoldComponent(
      title: AppLocalizations.instance.text("appbar.title.select"),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Tipo di orario: ", style: theme.textTheme.headline6),
              DropdownButton(
                value: _selectedType ?? "0",
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem(
                    child: Text(_keys[0]),
                    value: "0",
                  ),
                  DropdownMenuItem(
                    child: Text(_keys[1]),
                    value: "1",
                  ),
                  DropdownMenuItem(
                    child: Text(_keys[2]),
                    value: "2",
                  ),
                ],
                onChanged: (String? newVal) async {
                  _selectedValue = _values[int.parse(newVal!)].first.value;
                  setState(() {
                    _selectedType = newVal;
                  });
                },
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("${_keys[_selectedType == null ? 0 : int.parse(_selectedType!)]}:", style: theme.textTheme.headline6),
              DropdownButton(
                items: _values.isEmpty ? <DropdownMenuItem<String>>[] : _values[_selectedType == null ? 0 : int.parse(_selectedType!)],
                value: _selectedValue ?? (_values.isEmpty ? null : _values[_selectedType == null ? 0 : int.parse(_selectedType!)].first.value),
                onChanged: (String? newVal) async {
                  setState(() {
                    _selectedValue = newVal;
                  });
                },
              )
            ],
          ),
          InkWell(
            onTap: () async {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(AppLocalizations.instance.text("select.schedule.downloading.title")),
                  content: Row(
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(width: 10),
                      Text(AppLocalizations.instance.text("select.schedule.downloading"))
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
                          if (box.containsKey("schedule")) {
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
              var settings = await Hive.openBox("settings");
              settings.put("select_type", _selectedType ?? "0");
              settings.put("select_value", _selectedValue ?? _values[int.parse(_selectedType ?? "0")].first.value);
              var api = await API.inst.getSchedule(_selectedType ?? "0", _selectedValue ?? _values[int.parse(_selectedType ?? "0")].first.value);
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
              var box = await Hive.openBox("storage");
              box.put("schedule", api.value);
              Navigator.of(context).pop();
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(AppLocalizations.instance.text("select.schedule.downloaded.title")),
                  content: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(AppLocalizations.instance.text("select.schedule.downloaded")),
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
            },
            child: Container(
              margin: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Icon(Icons.save),
                    SizedBox(width: 5),
                    Text("Salva", style: theme.textTheme.headline6)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

}
