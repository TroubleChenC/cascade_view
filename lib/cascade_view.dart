import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'check_list.dart';

typedef CascadeValue = dynamic;

class CascadeOption {
  final String label;
  final CascadeValue value;
  List<CascadeOption>? children;
  dynamic addition; // addition data

  CascadeOption(this.label, this.value, {this.children, this.addition});
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

/// cascade
class CascadeView extends StatefulWidget {
  const CascadeView({
    super.key,
    required this.options,
    this.value = const [],
    this.onChange,
    this.selectedColor,
  });

  final List<CascadeOption> options;
  final void Function(List<CascadeValue> value, CascadeValueExtend extend)?
  onChange;
  final List<CascadeValue> value;
  final Color? selectedColor;

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
            tabAlignment: TabAlignment.start,
            controller: _tabController,
            indicatorColor:
                widget.selectedColor ?? Theme.of(context).colorScheme.primary,
            labelColor:
                widget.selectedColor ?? Theme.of(context).colorScheme.primary,
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
        selectedColor: widget.selectedColor,
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

/// async cascade
class AsyncCascadeView extends StatefulWidget {
  const AsyncCascadeView({
    super.key,
    this.options = const [],
    required this.getChildren,
    this.onChange,
    this.selectedColor,
  });

  final List<CascadeOption> options;
  final Future<List<CascadeOption>> Function(CascadeOption) getChildren;
  final void Function(List<CascadeValue> value, CascadeValueExtend extend)?
  onChange;
  final Color? selectedColor;

  @override
  State<AsyncCascadeView> createState() => _AsyncCascadeViewState();
}

class _AsyncCascadeViewState extends State<AsyncCascadeView> {
  List<CascadeOption> _list = [];
  var valueToOptions = <CascadeValue, List<CascadeOption>?>{};

  @override
  void initState() {
    super.initState();

    valueToOptions.addAll({null: widget.options});
    setState(() {
      _list = widget.options;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CascadeView(
      options: _list,
      onChange: _onChange,
      selectedColor: widget.selectedColor,
    );
  }

  void _onChange(List<CascadeValue> value, CascadeValueExtend extend) {
    for (var element in value) {
      int index = value.indexOf(element);
      _fetchOptionsForValue(extend.items[index]);
    }

    if (widget.onChange != null) {
      widget.onChange!(value, extend);
    }
  }

  void _fetchOptionsForValue(CascadeOption v) async {
    var key = v.value;
    if (valueToOptions.containsKey(key)) return;

    var data = await widget.getChildren(v);
    valueToOptions.addAll({key: data.isEmpty ? null : data});

    setState(() {
      _list = _generateOptions(null) ?? [];
    });
  }

  List<CascadeOption>? _generateOptions(CascadeValue v) {
    var options = valueToOptions[v];
    if (!valueToOptions.containsKey(v)) {
      return optionSkeleton;
    }

    if (options == null || options.isEmpty) {
      return null;
    }

    for (var element in options) {
      element.children = _generateOptions(element.value);
    }

    return options;
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemBuilder:
              (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: double.infinity,
                  height: 24.0,
                  color: Colors.white,
                ),
              ),
          itemCount: 8,
        ),
      ),
    );
  }
}
