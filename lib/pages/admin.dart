import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orario_scuola/components/scaffold.dart';
import 'package:orario_scuola/pages/tos.dart';
import 'package:orario_scuola/util/api.dart';
import 'package:orario_scuola/util/localization.dart';

class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  State<Admin> createState() => _Admin();
}

class _Admin extends State<Admin> {
  final TextEditingController _urlController = TextEditingController();

  @override
  initState() {
    Future.delayed(Duration.zero, () async {
      CollectionReference ref = FirebaseFirestore.instance.collection("storage");
      DocumentSnapshot<dynamic> url = await ref.doc("url").get();
      if (!url.exists) return;
      setState(() {
        _urlController.text = url.data()["url"];
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ScaffoldComponent(
      showAdmin: false,
      showSettings: false,
      title: AppLocalizations.instance.text("appbar.title.admin"),
      child: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _urlController,
            ),
            InkWell(
              onTap: () async {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text(AppLocalizations.instance.text("admin.sending.title")),
                    content: Row(
                      children: <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(width: 10),
                        Text(AppLocalizations.instance.text("admin.sending"))
                      ],
                    ),
                  )
                );
                CollectionReference ref = FirebaseFirestore.instance.collection("storage");
                await ref.doc("url").update({
                  "url": _urlController.text
                });
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text(AppLocalizations.instance.text("admin.success.title")),
                    content: Text(AppLocalizations.instance.text("admin.success")),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Chiudi"),
                      )
                    ]
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
        )
      ),
    );
  }

}
