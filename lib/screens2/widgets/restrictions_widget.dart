import 'package:flutter/material.dart';


class RestrictionsWidget extends StatefulWidget {
  final LogicInterface logic;
  final int? participantId;

  const RestrictionsWidget({super.key, required this.logic, this.participantId});

  @override
  _RestrictionsWidgetState createState() => _RestrictionsWidgetState();

  void update() {
    _RestrictionsWidgetState? state = _RestrictionsWidgetState();
    state._updateData();
  }
}

class _RestrictionsWidgetState extends State<RestrictionsWidget> {
  late final LogicInterface _logic;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _logic = widget.logic;
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _logic.fetchData(widget.participantId);
    setState(() {});
  }

  Future<void> _updateData() async {
    await _logic.update();
    setState(() {});
  }

  void _addItem(String name) {
    setState(() {
      _logic.addItem(name);
      _controller.clear();
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_logic.getText()),
          SizedBox(
            width: 200,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _logic.items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_logic.items[index]),
                );
              },
            ),
          ),          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // If width is too small, stack vertically or hide completely
                if (constraints.maxWidth < 160) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Autocomplete<String>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              return _logic.names.where((name) {
                                return name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                              });
                            },
                            onSelected: (selection) {
                              _addItem(selection);
                            },
                            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                              _controller.value = textEditingController.value;
                              return TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (value) {
                                  _addItem(value);
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Enter restriction',
                                  border: OutlineInputBorder(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              _addItem(_controller.text);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                // For normal widths, use horizontal layout
                return Row(
                  children: [
                    Expanded(
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return _logic.names.where((name) {
                            return name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (selection) {
                          _addItem(selection);
                        },
                        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                          _controller.value = textEditingController.value;
                          return TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) {
                              _addItem(value);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Enter restriction',
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        _addItem(_controller.text);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

abstract class LogicInterface {
  Future<void> fetchData([int? participantId]);
  void addItem(String name);
  List<String> get items;
  List<String> get names;
  String getText();
  Future<void> update();
}