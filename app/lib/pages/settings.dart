import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:orario_scuola/components/scaffold.dart';
import 'package:orario_scuola/pages/select.dart';
import 'package:orario_scuola/pages/tos.dart';
import 'package:orario_scuola/util/localization.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _Settings();
}

class _Settings extends State<Settings> {
  @override
  initState() {
    Future.delayed(Duration.zero, () async {
      var box = await Hive.openBox("settings");
      if (box.containsKey("teachers_names")) {
        _teachersNames = box.get("teachers_names");
      }
      _isTeacherSchedule = box.get("select_type") == "1";
      setState(() {
        
      });
    });

    super.initState();
  }

  bool _teachersNames = false;
  bool _isTeacherSchedule = false;
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ScaffoldComponent(
      title: AppLocalizations.instance.text("appbar.title.settings"),
      showSettings: false,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            Text(AppLocalizations.instance.text("settings.settings_change"), style: theme.textTheme.headline6),
            ListTile(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => Select()));
              },
              title: Text(AppLocalizations.instance.text("settings.change"), style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(AppLocalizations.instance.text("settings.change.desc")),
              leading: const Icon(Icons.calendar_today),
            ),
            ListTile(
              onTap: () async {
                var settings = await Hive.openBox("settings");
                settings.clear();
                var storage = await Hive.openBox("storage");
                storage.clear();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => TOS()));
              },
              title: Text(AppLocalizations.instance.text("settings.delete"), style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(AppLocalizations.instance.text("settings.delete.desc")),
              leading: const Icon(Icons.delete),
            ),
            //Text(AppLocalizations.instance.text("settings.settings_misc"), style: theme.textTheme.headline6),
            Divider(),
            SwitchListTile(
              title: Text(AppLocalizations.instance.text(_isTeacherSchedule ? "settings.subject_name" : "settings.teachers_names"), style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(AppLocalizations.instance.text(_isTeacherSchedule ? "settings.subject_name.desc" : "settings.teachers_names.desc")),
              secondary: const Icon(Icons.school),
              value: _teachersNames,
              onChanged: (value) async{
                var box = await Hive.openBox("settings");
                box.put("teachers_names", value);
                setState(() {
                  _teachersNames = value;
                });
              },
            )
          ],
        ),
      ),
    );
  }

}
