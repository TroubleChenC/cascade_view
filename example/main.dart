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
  final List<Map> _data = [
    {
      'id': 01,
      'name': 'a',
      'remark': 'remark',
      'children': [
        {'id': 0101, 'name': 'a-1'},
        {'id': 0102, 'name': 'a-2'},
        {'id': 0103, 'name': 'a-3'},
      ],
    },
    {'id': 02, 'name': 'b'},
    {'id': 03, 'name': 'c'},
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Cascade Demo')),
        body: Column(
          children: [
            const Text('Cascade'),
            Expanded(
              child: CascadeView(
                options: transformList(_data) ?? [],
                onChange: _onChange,
                selectedColor: Colors.blue,
              ),
            ),
            const Text('Async Cascade'),
            Expanded(
              child: AsyncCascadeView(
                options: [
                  CascadeOption('a', 'a'),
                  CascadeOption('b', 'b'),
                  CascadeOption('c', 'c'),
                ],
                getChildren: getChildrenList,
                onChange: _onChange,
                selectedColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onChange(List<CascadeValue> values, CascadeValueExtend extend) {
    // todo: Handle your business

    // addition data
    if (extend.items.isNotEmpty) {
      final data = extend.items.last.addition;
      print(data);
    }
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

// transform source data to List<CascadeOption>
List<CascadeOption>? transformList(
  List<dynamic>? list, {
  String label = 'name',
  String value = 'id',
  String children = 'children',
}) {
  if (list == null || list.isEmpty) return null;
  return list.map((item) {
    return CascadeOption(
      item[label],
      item[value],
      addition: item,
      children: transformList(item[children], label: label, value: value),
    );
  }).toList();
}
