import 'package:flutter/material.dart';

import 'package:cascade_view/cascade_view.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('app')),
        body: Center(
          child: CascadeView(
            options: [
              CascadeOption('a', 'a', children: [CascadeOption('a-a', 'a-a')]),
              CascadeOption('b', 'b'),
              CascadeOption('c', 'c'),
            ],
          ),
        ),
      ),
    );
  }
}
