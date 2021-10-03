import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:orario_scuola/components/scaffold.dart';
import 'package:orario_scuola/pages/home.dart';
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

  void updateRadio(SingingCharacter? value) {
    setState(() {
      _character = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ScaffoldComponent(
      title: AppLocalizations.instance.text("appbar.title.tos"),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Text("Invio dati", style: theme.textTheme.headline1),
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
                    Text("Email istituzionale", style: theme.textTheme.headline1),
                    Padding(
                      child: TextFormField(
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
                        var box = await Hive.openBox("settings");
                        box.put("token", api.value);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const Home()));
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
