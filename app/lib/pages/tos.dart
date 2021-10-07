import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:orario_scuola/components/scaffold.dart';
import 'package:orario_scuola/pages/select.dart';
import 'package:orario_scuola/util/api.dart';
import 'package:orario_scuola/util/localization.dart';

class TOS extends StatefulWidget {
  const TOS({Key? key}) : super(key: key);

  @override
  State<TOS> createState() => _TOS();
}

enum SingingCharacter {
  yes,
  no
}

class _TOS extends State<TOS> {
  SingingCharacter? _character = SingingCharacter.yes;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _mailCode = TextEditingController();

  void updateRadio(SingingCharacter? value) {
    setState(() {
      _character = value;
    });
  }

  @override
  Widget build(BuildContext context2) {
    ThemeData theme = Theme.of(context2);
    return ScaffoldComponent(
      showSettings: false,
      title: AppLocalizations.instance.text("appbar.title.tos"),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Text("Invio dati", style: theme.textTheme.headline4),
                    ListTile(
                      title: const Text("Accetto di condividere dati statistici in forma anonima con gli sviluppatori dell'app, ai fini del miglioramento di essa."),
                      leading: Radio<SingingCharacter>(
                        value: SingingCharacter.yes,
                        groupValue: _character,
                        onChanged: updateRadio
                      ),
                    ),
                    ListTile(
                      title: const Text("Non accetto di condividere dati statistici in forma anonima con gli sviluppatori dell'app, ai fini del miglioramento di essa."),
                      leading: Radio<SingingCharacter>(
                        value: SingingCharacter.no,
                        groupValue: _character,
                        onChanged: updateRadio,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Email istituzionale", style: theme.textTheme.headline4),
                    Padding(
                      child: TextFormField(
                        autocorrect: false,
                        controller: _controller,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: AppLocalizations.instance.text("textfield.email")
                        ),
                      ),
                      padding: const EdgeInsets.all(10.0),
                    ),
                    const SizedBox(height: 50),
                    TextButton(
                      child: const Text("Termina registrazione", style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        var api = await API.inst.getToken(_controller.text);
                        if (!api.success) {
                          showDialog(
                            context: context2,
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
                        if (api.code == "token.check-mail") {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              bool _invalidCode = false;
                              return StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) {
                                  return AlertDialog(
                                    title: Text(AppLocalizations.instance.text("tos.check-mail.title")),
                                    content: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(AppLocalizations.instance.text("tos.check-mail")),
                                              SizedBox(height: 10),
                                              TextField(
                                                controller: _mailCode,
                                                decoration: InputDecoration(
                                                  border: const UnderlineInputBorder(),
                                                  labelText: AppLocalizations.instance.text("textfield.code"),
                                                  errorText: _invalidCode ? AppLocalizations.instance.text("tos.check-mail.wrong") : null
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context2).pop();
                                        },
                                        child: Text("Annulla"),
                                      ),
                                      TextButton(
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(theme.primaryColor),
                                        ),
                                        onPressed: () async {
                                          var api = await API.inst.getToken(_controller.text, code: _mailCode.text);
                                          if (api.code == "code.invalid") {
                                            setState(() {
                                              _invalidCode = true;
                                            });
                                            return;
                                          }
                                          if (!api.success) {
                                            showDialog(
                                              context: context2,
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
                                                      Navigator.pop(context2, AppLocalizations.instance.text("dialog.close"));
                                                    },
                                                  )
                                                ],
                                              )
                                            );
                                            return;
                                          }
                                          var box = await Hive.openBox("settings");
                                          box.put("token", api.value);
                                          box.put("admin", true);
                                          Navigator.of(context2).pop();
                                          Navigator.of(context2).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => Select()));
                                        },
                                        child: Text("Conferma", style: TextStyle(color: Colors.white)),
                                      )
                                    ]
                                  );
                                },
                              );
                            }
                          );
                          return;
                        }
                        var box = await Hive.openBox("settings");
                        box.put("token", api.value);
                        box.put("send_anon_data", _character == SingingCharacter.yes ? true : false);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const Select()));
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(theme.primaryColor),
                      ),
                    ),
                    const Text("Cliccando su \"Termina registrazione\" si accettano i termini e condizioni dell'applicazione."),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
