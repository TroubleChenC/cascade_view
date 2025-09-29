import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'check_list.dart';

typedef CascadeValue = dynamic;

class CascadeOption {
  final String label;
  final CascadeValue value;
  List<CascadeOption>? children;

  CascadeOption(this.label, this.value, {this.children});
}

const List<CascadeOption> optionSkeleton = []; // loading effect

class CascadeValueExtend {
  final List<CascadeOption> items;
  final bool isLeaf;

  CascadeValueExtend(this.items, this.isLeaf);
}

class _LevelOption {
  CascadeOption? selected;
  final List<CascadeOption> options;

  _LevelOption({required this.options, this.selected});
}

class CascadeView extends StatefulWidget {
  const CascadeView({
    super.key,
    required this.options,
    this.value = const [],
    this.onChange,
  });

  final List<CascadeOption> options;
  final void Function(List<CascadeValue> value, CascadeValueExtend extend)?
  onChange;
  final List<CascadeValue> value;

  @override
  State<CascadeView> createState() => _CascadeViewState();
}

class _CascadeViewState extends State<CascadeView>
    with TickerProviderStateMixin {
  List<CascadeValue> _value = [];
  List<_LevelOption> _levels = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    _updateLevels();
  }

  @override
  void didUpdateWidget(covariant CascadeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateLevels();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color.fromARGB(255, 230, 230, 230),
                width: 1.0,
              ),
            ),
          ),
          child: TabBar(
            isScrollable: true,
            controller: _tabController,
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.black,
            tabs: _generateTabs(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _generateTabViews(),
          ),
        ),
      ],
    );
  }

  void _onItemSelect(CascadeValue? selectValue, int depth) {
    var next = _value.sublist(0, depth);
    if (selectValue != null) {
      next.add(selectValue);
    }
    setState(() {
      _value = next;
      _updateLevels();
    });

    widget.onChange?.call(_value, _generateValueExtend(_value));
  }

  void _updateLevels() {
    List<_LevelOption> ret = [];
    var currentOptions = widget.options;
    bool reachedEnd = false;
    for (var item in _value) {
      try {
        var target = currentOptions.firstWhere(
          (option) => option.value == item,
        );
        ret.add(_LevelOption(options: currentOptions, selected: target));
        if (target.children == null) {
          reachedEnd = true;
          break;
        }

        currentOptions = target.children!;
      } catch (e) {
        reachedEnd = true;
        break;
      }
    }

    if (!reachedEnd) {
      ret.add(_LevelOption(options: currentOptions));
    }

    setState(() {
      _levels = ret;
      _tabController = TabController(
        length: _levels.length,
        initialIndex: _levels.length - 1,
        vsync: this,
      );
    });
  }

  List<Widget> _generateTabs() {
    return _levels
        .map(
          (item) =>
              Tab(text: item.selected == null ? '请选择' : item.selected!.label),
        )
        .toList();
  }

  List<Widget> _generateTabViews() {
    return _levels.map((item) {
      if (item.options == optionSkeleton) {
        return const _ShimmerList();
      }

      int index = _levels.indexOf(item);

      var items =
          item.options.map((option) {
            bool selected = false;
            if (index >= _value.length) {
              selected = false;
            } else {
              selected = _value[index] == option.value;
            }
            return ListItem(option.label, option.value, isSelected: selected);
          }).toList();
      return CheckList(
        key: ValueKey(index),
        items: items,
        onSelect: (selectValue, _) {
          _onItemSelect(selectValue, index);
        },
      );
    }).toList();
  }

  CascadeValueExtend _generateValueExtend(List<CascadeValue> value) {
    List<CascadeOption> items = [];
    bool isLeaf = true;
    var currentOptions = widget.options;
    for (var val in value) {
      try {
        CascadeOption el = currentOptions.firstWhere(
          (option) => option.value == val,
        );
        items.add(el);
        if (el.children != null) {
          currentOptions = el.children!;
          isLeaf = false;
        } else {
          isLeaf = true;
        }
      } on StateError catch (_) {
        break;
      }
    }

    return CascadeValueExtend(items, isLeaf);
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemBuilder:
              (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 24.0,
                      color: Colors.white,
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                    Container(
                      width: double.infinity,
                      height: 8.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
          itemCount: 6,
        ),
      ),
    );
  }
}
