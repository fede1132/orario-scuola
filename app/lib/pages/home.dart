import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:orario_scuola/components/scaffold.dart';
import 'package:orario_scuola/pages/tos.dart';
import 'package:orario_scuola/util/api.dart';
import 'package:orario_scuola/util/localization.dart';

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
      rowHeight = 50;
      var box = await Hive.openBox("settings");
      if (box.containsKey("teachers_names")) {
        _teachersNames = box.get("teachers_names");
      }
      if (body.isNotEmpty) body.clear();
      var api = await API.inst.getSchedule();
      if (!api.success) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(AppLocalizations.instance.text("${api.code}.title")),
            content: Text(AppLocalizations.instance.text(api.code!)),
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
      api.value.forEach((key, value) {
        var cells = <DataCell>[
          DataCell(Text(key, style: const TextStyle(fontWeight: FontWeight.bold))),
        ];
        for (var i=0;i<value.length;i++) {
          var data = value[i];
          if (data.length == 0 || data[0]["empty"] == true) {
            cells.add(const DataCell(Text(""))); 
            continue;
          }

          // sum every letter in the subject name
          int sum = 0;
          for (var char in data[0]["name"].split('')) {
            var index = alphabet.indexOf(char.toUpperCase());
            sum += index == -1 ? 0 : index;
          }
          // digital root until the number is below 26
          while (sum > 26) {
            int temp = 0;
            for (var num in "$sum".split('')) {
              temp += int.parse(num);
            }
            sum = temp;
          }
          List<Color> set = colors[sum];
          cells.add(DataCell(
            Row(
              children: <Widget>[
                Expanded(
                  child: Builder(
                    builder: (BuildContext context) {
                      List<Widget> childs = [];
                      for (var j=0;j<data.length;j++) {
                        // add teachers name if the setting is enabled
                        var teachers = "";
                        if (_teachersNames) {
                          if (50 + (data[j]["teachers"].length*14) > rowHeight) {
                            rowHeight += data[j]["teachers"].length * 14;
                          }
                          for (var j=0;j<data[j]["teachers"].length;j++) {
                            teachers += data[j]["teachers"][j] + "\n";
                          }
                        }
                        childs.add(Card(
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
                        ));
                      }
                      if (childs.length==1) return childs[0];
                      return Row(
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

  double rowHeight = 50;
  bool _teachersNames = false;
  List<DataRow> body = [];

  @override
  Widget build(BuildContext context) {
    return ScaffoldComponent(
      onGoBack: () {
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
                  constrained: false,
                  child: DataTable(
                    dataRowHeight: rowHeight,
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
