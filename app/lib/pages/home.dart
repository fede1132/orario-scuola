import 'package:flutter/material.dart';
import 'package:orario_scuola/components/scaffold.dart';
import 'package:orario_scuola/util/api.dart';
import 'package:orario_scuola/util/localization.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  final String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  final List<Color> lightColors = const [
    Color(0xFFff0000),
    Color(0xFFffffff),
    Color(0xFF165adf),
    Color(0xFF66df16),
    Color(0xFFc2a900),
    Color(0xFFeb0bc6),
    Color(0xFF2a8857),
    Color(0xFF505aaa),
    Color(0xFF8181ec),
    Color(0xFFfc9341),
  ];
  @override
  initState() {
    Future.delayed(Duration.zero, () async {
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
          DataCell(Text(key)),
        ];
        for (var i=0;i<value.length;i++) {
          var data = value[i];
          if (data.length == 0 || data[0]["empty"] == true) {
            cells.add(const DataCell(Text(""))); 
            continue;
          }
          cells.add(DataCell(
            Card(
              elevation: 10,
              child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                decoration: BoxDecoration(
                  color: lightColors[data[0]["name"].length%9],
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: Text("${data[0]["name"]}\n${data[0]["room"]}"),
              ),
            )
          )); 
        }
        body.add(DataRow(cells: cells));
      });
      setState(() {
        
      });
    });

    super.initState();
  }

  List<DataRow> body = [];

  @override
  Widget build(BuildContext context) {
    return ScaffoldComponent(
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
                  child: OrientationBuilder(
                    builder: (BuildContext context, Orientation orientation) {
                      return DataTable(
                        dataRowHeight: orientation == Orientation.landscape ? MediaQuery.of(context).size.width * 0.08 : MediaQuery.of(context).size.height * 0.08,
                        columns: const [
                          DataColumn(label: Text("")),
                          DataColumn(label: Text("LUN", textAlign: TextAlign.center)),
                          DataColumn(label: Text("MAR")),
                          DataColumn(label: Text("MER")),
                          DataColumn(label: Text("GIO")),
                          DataColumn(label: Text("VEN")),
                          DataColumn(label: Text("SAB"))
                        ],
                        rows: body,
                      );
                    },
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
