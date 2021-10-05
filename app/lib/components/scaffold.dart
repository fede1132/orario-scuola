import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:orario_scuola/pages/settings.dart';

class ScaffoldComponent extends StatelessWidget {
  const ScaffoldComponent({Key? key, required this.child, this.title = "Orario Scuola", this.settings = false, this.onGoBack}) : super(key: key);

  final String title;
  final bool settings;
  final VoidCallback? onGoBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              if (!settings) {
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const Settings())).then((value) => {
                  if (onGoBack != null) {
                    onGoBack!()
                  }
                });
              }
            },
          )
        ],
      ),
      body: child,
    );
  }
}
