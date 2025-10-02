import 'package:flutter/material.dart';

class ListItem {
  bool isSelected;
  final String label;
  final dynamic value;

  ListItem(this.label, this.value, {this.isSelected = false});
}

class CheckList extends StatefulWidget {
  const CheckList({super.key, required this.items, this.onSelect});

  final List<ListItem> items;
  final Function(dynamic value, ListItem? extend)? onSelect;

  @override
  State<CheckList> createState() => _CheckListState();
}

class _CheckListState extends State<CheckList>
    with AutomaticKeepAliveClientMixin {
  List<ListItem> get _items => widget.items;
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () => _onItemSelected(index),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    widget.items[index].label,
                    style: TextStyle(
                      fontSize: 16.0,
                      color:
                          widget.items[index].isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                      // 如果选中，设置文字颜色为强调色，否则为默认颜色
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  widget.items[index].isSelected ? Icons.check : null,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onItemSelected(int index) {
    dynamic selected;
    if (_selectedIndex == index) {
      // check cancel
      _selectedIndex = -1;
      selected = null;
    } else {
      _selectedIndex = index;
      selected = widget.items[index].value;
    }
    setState(() {
      for (int i = 0; i < _items.length; i++) {
        _items[i].isSelected = (i == _selectedIndex);
      }
    });
    if (widget.onSelect != null) {
      widget.onSelect!(selected, widget.items[index]);
    }
  }

  @override
  bool get wantKeepAlive => true;
}
