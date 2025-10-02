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
        appBar: AppBar(title: const Text('Cascade Demo')),
        body: Column(
          children: [
            Expanded(
              child: CascadeView(
                options: [
                  CascadeOption(
                    'a',
                    'a',
                    children: [
                      CascadeOption('a-1', 'a-1'),
                      CascadeOption('a-2', 'a-2'),
                    ],
                  ),
                  CascadeOption('b', 'b'),
                  CascadeOption('c', 'c'),
                ],
                onChange: _onChange,
              ),
            ),
            Expanded(
              child: AsyncCascadeView(
                options: [
                  CascadeOption('a', 'a'),
                  CascadeOption('b', 'b'),
                  CascadeOption('c', 'c'),
                ],
                getChildren: getChildrenList,
                onChange: _onChange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onChange(List<CascadeValue> values, CascadeValueExtend extend) {
    // todo: Handle your business
  }
}

Future<List<CascadeOption>> getChildrenList(CascadeOption option) async {
  await Future.delayed(const Duration(milliseconds: 400));
  int level = option.value.split('').where((el) => el == '-').length;
  if (level >= 3) {
    return [];
  }
  return List.generate(10, (index) {
    var val = '${option.label}-$index';
    return CascadeOption(val, val);
  });
}
