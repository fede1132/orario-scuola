import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:orario_scuola/components/scaffold.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orario_scuola/pages/select.dart';
import 'package:orario_scuola/util/api.dart';
import 'package:orario_scuola/util/localization.dart';
import 'package:url_launcher/url_launcher.dart';

class TOS extends StatefulWidget {
  const TOS({Key? key}) : super(key: key);

  @override
  State<TOS> createState() => _TOS();
}

class _TOS extends State<TOS> {
  final String tos = AppLocalizations.instance.text("tos.tos");
  final TextEditingController _email = TextEditingController();
  final TextEditingController _mailCode = TextEditingController();

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
              child: LayoutBuilder(
                builder: (BuildContext context3, BoxConstraints costraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints.tightFor(height: costraints.maxHeight-20),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: AppLocalizations.instance.text("tos.welcome"),
                                    style: theme.textTheme.headline5!.copyWith(fontWeight: FontWeight.bold)
                                  ),
                                  TextSpan(
                                    text: "\n" + AppLocalizations.instance.text("tos.name"),
                                    style: theme.textTheme.headline5!.copyWith(fontWeight: FontWeight.bold, fontSize: 45, color: Color(0xFFE9B03E))
                                  )
                                ]
                              ),
                            ),
                          ),
                          SvgPicture.asset(
                            "assets/svg/icons8-school.svg",
                            semanticsLabel: "Undraw Login",
                            width: MediaQuery.of(context2).size.width,
                          ),
                          Column(
                            children: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  showDialog(context: context2, builder: (BuildContext context) {
                                    bool _invalidEmail = false;
                                    return StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                        return AlertDialog(
                                          title: Text(AppLocalizations.instance.text("dialog.email.title")),
                                          scrollable: true,
                                          content: Column(
                                            children: <Widget>[
                                              TextField(
                                                controller: _email,
                                                decoration: InputDecoration(
                                                  border: const UnderlineInputBorder(),
                                                  labelText: AppLocalizations.instance.text("textfield.email"),
                                                  errorText: _invalidEmail ? AppLocalizations.instance.text("tos.email.wrong") : null
                                                ),
                                                onChanged: (String str) {
                                                  setState(() {
                                                    if (!str.endsWith("@gobettire.istruzioneer.it")) {
                                                      _invalidEmail = true;
                                                      return;
                                                    }
                                                    _invalidEmail = false;
                                                  });
                                                },
                                              )
                                            ],
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () async {
                                                if (_email.text.isEmpty || _invalidEmail) return;
                                                var api = await API.inst.getToken(_email.text);
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
                                                    context: context2,
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
                                                                  var api = await API.inst.getToken(_email.text, code: _mailCode.text);
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
                                                                                Navigator.of(context2).pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
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
                                                                  showDialog(context: context2, builder: (BuildContext context) {
                                                                    bool _choosen = true;
                                                                    return StatefulBuilder(
                                                                      builder: (BuildContext context, StateSetter setState) {
                                                                        return AlertDialog(
                                                                          title: Text(AppLocalizations.instance.text("dialog.anon-data.title")),
                                                                          content: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Text(AppLocalizations.instance.text("tos.anon-data.desc")),
                                                                              ListTile(
                                                                                title: Text(AppLocalizations.instance.text("generic.yes")),
                                                                                leading: Radio<bool>(
                                                                                  value: true,
                                                                                  groupValue: _choosen,
                                                                                  onChanged: (_newVal) {
                                                                                    setState(() {
                                                                                      _choosen = _newVal!;
                                                                                    });
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              ListTile(
                                                                                title: Text(AppLocalizations.instance.text("generic.no")),
                                                                                leading: Radio<bool>(
                                                                                  value: false,
                                                                                  groupValue: _choosen,
                                                                                  onChanged: (_newVal) {
                                                                                    setState(() {
                                                                                      _choosen = _newVal!;
                                                                                    });
                                                                                  },
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          actions: <Widget>[
                                                                            TextButton(
                                                                              child: Text(AppLocalizations.instance.text("dialog.close")),
                                                                              onPressed: () async {
                                                                                var box = await Hive.openBox("settings");
                                                                                box.put("token", api.value["token"]);
                                                                                box.put("admin", api.value["admin"]);
                                                                                Navigator.of(context2).popUntil((route) => route.isFirst);
                                                                                Navigator.of(context2).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => Select()));
                                                                              },
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                  });
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
                                              },
                                              child: Text(AppLocalizations.instance.text("dialog.continue")),
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(theme.primaryColor),
                                                foregroundColor: MaterialStateProperty.all(theme.textTheme.headline6!.color),
                                                overlayColor: MaterialStateProperty.all(theme.splashColor)
                                              )
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context2).pop();
                                              },
                                              child: Text(AppLocalizations.instance.text("dialog.close")),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  });
                                },
                                child: Text(AppLocalizations.instance.text("tos.join"), style: theme.textTheme.headline6),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(theme.primaryColor),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                                  elevation: MaterialStateProperty.all(5)
                                ),
                              ),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: tos.substring(0, tos.indexOf("{%}")),
                                      style: theme.textTheme.subtitle2!
                                    ),
                                    TextSpan(
                                      text: tos.substring(tos.indexOf("{%}")+3, tos.lastIndexOf("{%}")),
                                      style: theme.textTheme.subtitle2!.copyWith(decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        if (await canLaunch("https://www.termsandconditionsgenerator.com/live.php?token=huchWUopclp87QWoBkKmCuuUUDrl3nqh")) await launch("https://www.termsandconditionsgenerator.com/live.php?token=huchWUopclp87QWoBkKmCuuUUDrl3nqh");
                                      }
                                    ),
                                    TextSpan(
                                      text: tos.substring(tos.lastIndexOf("{%}")+3, tos.indexOf("{\$}")),
                                      style: theme.textTheme.subtitle2!
                                    ),
                                    TextSpan(
                                      text: tos.substring(tos.indexOf("{\$}")+3, tos.lastIndexOf("{\$}")),
                                      style: theme.textTheme.subtitle2!.copyWith(decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        if (await canLaunch("https://www.privacypolicygenerator.info/live.php?token=atqi08asBRdTR9HSmKIbl94xBVbN4Emz")) await launch("https://www.privacypolicygenerator.info/live.php?token=atqi08asBRdTR9HSmKIbl94xBVbN4Emz");
                                      }
                                    ),
                                    TextSpan(
                                      text: tos.substring(tos.lastIndexOf("{\$}")+3),
                                      style: theme.textTheme.subtitle2!
                                    )
                                  ]
                                )
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            )
          ],
        ),
      ),
    );
  }
}
