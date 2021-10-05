import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:orario_scuola/components/scaffold.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _Loading();
}

class _Loading extends State<Loading> {

  @override
  Widget build(BuildContext context) {
    return ScaffoldComponent(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const <Widget>[
            CircularProgressIndicator(
              value: null,
              semanticsLabel: "Caricamento",
              strokeWidth: 6.0,
            ),
            Text("Caricamento...", style: TextStyle(fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

}
