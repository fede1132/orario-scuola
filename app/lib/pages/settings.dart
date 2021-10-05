import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:orario_scuola/components/scaffold.dart';
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
      setState(() {
        
      });
    });

    super.initState();
  }

  bool _teachersNames = false;
  @override
  Widget build(BuildContext context) {
    return ScaffoldComponent(
      title: AppLocalizations.instance.text("appbar.title.settings"),
      settings: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            SwitchListTile(
              title: Text(AppLocalizations.instance.text("settings.teachers_names")),
              subtitle: Text(AppLocalizations.instance.text("settings.teachers_names.desc")),
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
