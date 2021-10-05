import 'package:flutter/material.dart';
import 'package:orario_scuola/components/scaffold.dart';
import 'package:orario_scuola/util/localization.dart';

class Select extends StatefulWidget {
  const Select({Key? key}) : super(key: key);

  @override
  State<Select> createState() => _Select();
}

class _Select extends State<Select> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldComponent(
      title: AppLocalizations.instance.text("appbar.title.select"),
      child: Column(
        children: <Widget>[
        ],
      ),
    );
  }

}
