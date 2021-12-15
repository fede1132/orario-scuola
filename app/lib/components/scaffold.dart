import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:orario_scuola/pages/admin.dart';
import 'package:orario_scuola/pages/settings.dart';
import 'package:orario_scuola/util/api.dart';

class ScaffoldComponent extends StatelessWidget {
  ScaffoldComponent({Key? key, required this.child, this.title = "Orario Scuola", this.showSettings = true, this.showAdmin = true, this.onGoBack}) : super(key: key);

  final TextEditingController _panic = TextEditingController();
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
                icon: const Icon(Icons.warning),
                onPressed: () {
                  showDialog(context: context, builder: (BuildContext cctx) => AlertDialog(
                    title: Text("Sei sicuro?"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("Digita \"CONFERMA\" per avviare la procedura anti panico"),
                        TextField(
                          controller: _panic,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text("Digita qui")
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (_panic.text != "CONFERMA") {
                              showDialog(context: context, builder: (BuildContext _) => AlertDialog(
                                title: Text("Hai digitato male!"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    }, 
                                    child: Text("Chiudi")
                                  )
                                ],
                              ));
                              return;
                            }
                            APIResponse api = await API.inst.panic();
                            if (api.success) {
                              showDialog(context: context, builder: (BuildContext _) => AlertDialog(
                                title: Text("SUCCESSO"),
                                content: Text("Procedura anti panico inviata correttament al server, database ripulito, comunicazione inviata a tutti i dispositivi"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    }, 
                                    child: Text("Chiudi")
                                  )
                                ],
                              ));
                              return;
                            }
                            showDialog(context: context, builder: (BuildContext _) => AlertDialog(
                              title: Text("Errore"),
                              content: Text("Errore: \n${api.code}"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }, 
                                  child: Text("Chiudi")
                                )
                              ],
                            ));
                          },
                          child: Text("AVVIA!"),
                        )
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        }, 
                        child: Text("Chiudi")
                      )
                    ],
                  ));
                },
              ),
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
