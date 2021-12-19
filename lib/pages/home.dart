import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:orario_scuola/components/scaffold.dart';
import 'package:orario_scuola/pages/select.dart';
import 'package:http/http.dart' as http;
import 'package:orario_scuola/util/internet.dart';
import 'package:orario_scuola/util/localization.dart';
import 'package:orario_scuola/util/scraper.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  final String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  final List<Color> colors = [
    const Color(0xFF142999),
    const Color(0xFF497234),
    const Color(0xFF992114),
    const Color(0xFFff0000),
    const Color(0xFFffffff),
    const Color(0xFF165adf),
    const Color(0xFF66df16),
    const Color(0xFFc2a900),
    const Color(0xFFeb0bc6),
    const Color(0xFF2a8857),
    const Color(0xFF505aaa),
    const Color(0xFFa78a67),
    const Color(0xFFfc9341),
    const Color(0xFF006136),
    const Color(0xFF1c4c70),
    const Color(0xFF341c3b),
    const Color(0xFF3f1499),
    const Color(0xFF8f7ab6),
    const Color(0xFF00701d),
    const Color(0xFF0073c9),
    const Color(0xFF413e12),
    const Color(0xFF12411a),
    const Color(0xFFf1470d),
    const Color(0xFFe00404),
    const Color(0xFF00ffa3),
    const Color(0xFF595ece),
  ];
  @override
  initState() {
    super.initState();
  }

  _loadData(BuildContext context, {bool updated = false}) {
    Future.delayed(Duration.zero, () async {
      var box = await Hive.openBox("settings");
      if (box.containsKey("teachers_names")) {
        _teachersNames = box.get("teachers_names");
      }
      if (body.isNotEmpty) body.clear();
      var settings = await Hive.openBox("settings");
      var type = settings.get("select_type");
      var val = settings.get("select_value");
      var storage = await Hive.openBox("storage");
      var value = storage.get("schedule-$type-$val");
      if (value == null) {
        Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => Select()));
        return;
      }
      Map<String, int> assigned = {};
      value["value"].forEach((key, value) {
        var cells = <DataCell>[
          DataCell(Text(key, style: const TextStyle(fontWeight: FontWeight.bold))),
        ];
        for (var i=0;i<value.length;i++) {
          var data = value[i];
          if (data.length == 0 || data[0]["empty"] == true) {
            cells.add(
              DataCell(
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(""),
                    )
                  ],
                )
              )
            ); 
            continue;
          }
          // calculate the right row height
          if (_teachersNames) {
            for (var j=0;j<data.length;j++) {
              if (50 + (data[j]["teachers"].length*14) > _rowHeight) {
                _rowHeight += data[j]["teachers"].length * 18;
              }
            }
          }
          cells.add(DataCell(
            Row(
              children: <Widget>[
                Expanded(
                  child: Builder(
                    builder: (BuildContext context) {
                      List<Widget> childs = [];
                      for (var j=0;j<data.length;j++) {
                        Color set;
                        if (assigned[data[j]["name"]] != null) {
                          set = colors[assigned[data[j]["name"]]!];
                        } else {
                          var index = assigned.keys.length;
                          assigned[data[j]["name"]] = index;
                          set = colors[index];
                        }
                        var teachers = "";
                        if (_teachersNames) {
                          for (var k=0;k<data[j]["teachers"].length;k++) {
                            teachers += data[j]["teachers"][k] + "\n";
                          }
                        }
                        childs.add(Expanded(
                          child: Card(
                            elevation: 10,
                            child: Container(
                              padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                decoration: BoxDecoration(
                                  color: set,
                                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                                ),
                                child: Text("${data[j]["name"]}\n${_teachersNames ? teachers : ""}${data[j]["room"]}", style: TextStyle(color: set.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                              ),
                            ),
                          ),
                        ));
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.max,
                        children: childs,
                      );
                    },
                  )
                )
              ],
            )
          )); 
        }
        body.add(DataRow(cells: cells));
      });
      setState(() {
      });
      if (!(await checkInternetConnection()) || FirebaseAuth.instance.currentUser == null || updated) return;
      CollectionReference ref = FirebaseFirestore.instance.collection("storage");
      DocumentSnapshot<dynamic> snapshot = await ref.doc("url").get();
      if (storage.get("url")["value"] != snapshot.data()["url"]) {
        storage.put("url", {
          "value": snapshot.data()["url"],
          "time": (DateTime.now().millisecondsSinceEpoch/1000).floor()
        });
        var type = settings.get("select_type");
        var val = settings.get("select_value");
        var body = (await http.get(Uri.parse("${snapshot.data()["url"]}/${["Classi", "Docenti", "Aule"].elementAt(int.parse(type))}/$val.html"))).body;
        storage.put("schedule-$type-$val", scrape(body));
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
                  this.body.clear();
                  _loadData(context, updated: true);
                },
                child: Text(AppLocalizations.instance.text("dialog.close")),
              )
            ],
          )
        );
      }
    });
  }

  double _rowHeight = 50;
  bool _teachersNames = false;
  List<DataRow> body = [];

  @override
  Widget build(BuildContext context) {
    if (body.length == 0) _loadData(context); 
    return ScaffoldComponent(
      onGoBack: () {
        _rowHeight = 50;
        _loadData(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  scaleEnabled: false,
                  constrained: false,
                  child: DataTable(
                    dataRowHeight: _rowHeight == 50 ? 50 : _rowHeight,
                    columns: const [
                      DataColumn(label: Text("", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("LUN", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("MAR", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("MER", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("GIO", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("VEN", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("SAB", style: TextStyle(fontWeight: FontWeight.bold)))
                    ],
                    rows: body,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  
}
