import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:orario_scuola/pages/admin.dart';
import 'package:orario_scuola/pages/settings.dart';

class ScaffoldComponent extends StatelessWidget {
  const ScaffoldComponent({Key? key, required this.child, this.title = "Orario Scuola", this.showSettings = true, this.showAdmin = true, this.onGoBack}) : super(key: key);

  final String title;
  final bool showSettings;
  final bool showAdmin;
  final VoidCallback? onGoBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Future.delayed(Duration.zero, () async {
        var box = await Hive.openBox("settings");
        var value = box.get("admin");
        return value == null ? false : value;
      }),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: <Widget>[
              if (showAdmin && snapshot.hasData && snapshot.data) IconButton(
                icon: const Icon(Icons.admin_panel_settings),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const Admin())).then((value) => {
                      if (onGoBack != null) {
                        onGoBack!()
                      }
                  });
                },
              ),
              if (showSettings) IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const Settings())).then((value) => {
                      if (onGoBack != null) {
                        onGoBack!()
                      }
                  });
                },
              )
            ],
          ),
          body: child,
        );
      },
    );
  }
}
