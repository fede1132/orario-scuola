import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:orario_scuola/components/scaffold.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  final String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  final List<List<Color>> colors = [
    const [Color(0xFF142999), Colors.white],
    const [Color(0xFF497234), Colors.white],
    const [Color(0xFF992114), Colors.white],
    const [Color(0xFFff0000), Colors.white],
    const [Color(0xFFffffff), Colors.black],
    const [Color(0xFF165adf), Colors.black],
    const [Color(0xFF66df16), Colors.black],
    const [Color(0xFFc2a900), Colors.black],
    const [Color(0xFFeb0bc6), Colors.white],
    const [Color(0xFF2a8857), Colors.black],
    const [Color(0xFF505aaa), Colors.black],
    const [Color(0xFFa78a67), Colors.black],
    const [Color(0xFFfc9341), Colors.black],
    const [Color(0xFF006136), Colors.white],
    const [Color(0xFF1c4c70), Colors.white],
    const [Color(0xFF341c3b), Colors.white],
    const [Color(0xFF3f1499), Colors.white],
    const [Color(0xFF8f7ab6), Colors.black],
    const [Color(0xFF00701d), Colors.white],
    const [Color(0xFF0073c9), Colors.white],
    const [Color(0xFF413e12), Colors.white],
    const [Color(0xFF12411a), Colors.white],
    const [Color(0xFFf1470d), Colors.white],
    const [Color(0xFFe00404), Colors.white],
    const [Color(0xFF00ffa3), Colors.white],
    const [Color(0xFF595ece), Colors.white],
  ];
  @override
  initState() {
    _loadData();
    super.initState();
  }

  _loadData() {
    Future.delayed(Duration.zero, () async {
      var box = await Hive.openBox("settings");
      if (box.containsKey("teachers_names")) {
        _teachersNames = box.get("teachers_names");
      }
      if (body.isNotEmpty) body.clear();
      var storage = await Hive.openBox("storage");
      var value = storage.get("schedule");
      Map<String, int> assigned = {};
      value.forEach((key, value) {
        var cells = <DataCell>[
          DataCell(Text(key, style: const TextStyle(fontWeight: FontWeight.bold))),
        ];
        for (var i=0;i<value.length;i++) {
          var data = value[i];
          if (data.length == 0 || data[0]["empty"] == true) {
            cells.add(const DataCell(Text(""))); 
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
                        List<Color> set;
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
                                  color: set[0],
                                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                                ),
                                child: Text("${data[j]["name"]}\n${_teachersNames ? teachers : ""}${data[j]["room"]}", style: TextStyle(color: set[1]),
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
    });
  }

  double _rowHeight = 50;
  bool _teachersNames = false;
  List<DataRow> body = [];

  @override
  Widget build(BuildContext context) {
    return ScaffoldComponent(
      onGoBack: () {
        _rowHeight = 50;
        _loadData();
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
