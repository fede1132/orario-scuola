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
      var api = await API.inst.getUrl();
      if (!api.success) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(AppLocalizations.instance.text("${api.code}.title")),
            content: Row(
              children: <Widget>[
                Expanded(
                  child: Text(AppLocalizations.instance.text(api.code!)),
                )
              ],
            ),
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
      setState(() {
        _urlController.text = api.value;
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
                var api = await API.inst.updateUrl(_urlController.text);
                if (!api.success) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(AppLocalizations.instance.text("${api.code}.title")),
                      content: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(AppLocalizations.instance.text(api.code!)),
                          )
                        ],
                      ),
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
                }
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
