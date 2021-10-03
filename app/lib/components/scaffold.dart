import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScaffoldComponent extends StatelessWidget {
  const ScaffoldComponent({Key? key, required this.child, this.title = "Orario Scuola"}) : super(key: key);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: child,
    );
  }
}
