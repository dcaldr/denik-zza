import 'package:flutter/material.dart';

class RestrictionsWidget extends StatefulWidget {
  const RestrictionsWidget({super.key});

  @override
  _RestrictionsWidgetState createState() => _RestrictionsWidgetState();
}

class _RestrictionsWidgetState extends State<RestrictionsWidget> {
  final List<String> _items = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _addItem() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _items.add(_controller.text.trim());
        _controller.clear();
      });
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 200, // Set a smaller width
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_items[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) => _addItem(),
                    decoration: const InputDecoration(
                      labelText: 'Enter restriction',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addItem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}