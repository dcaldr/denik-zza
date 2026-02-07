import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/input/text_tools.dart';
import 'package:denik_zza/screens2/widgets/zza_scrollable.dart';

class RestrictionsWidget extends StatefulWidget {
  final LogicInterface logic;
  final int? participantId;
  final bool isBounded; // Whether parent has bounded height (Flexible mode)

  const RestrictionsWidget({
    super.key,
    required this.logic,
    this.participantId,
    this.isBounded = false, // Default: assume scroll mode (unbounded)
  });

  @override
  State<RestrictionsWidget> createState() => _RestrictionsWidgetState();
}


class _RestrictionsWidgetState extends State<RestrictionsWidget> {
  late final LogicInterface _logic;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _ghostSuffix = ''; // For inline gray suggestion

  // References to Autocomplete's internal objects
  TextEditingController? _autocompleteController;
  VoidCallback? _textListener;

  // For preventing double-add: onSubmitted defers add, onSelected cancels it
  String? _pendingSubmitValue;
  bool _suppressNextSubmit = false;

  @override
  void initState() {
    super.initState();
    _logic = widget.logic;
    _fetchData();
    // ScrollController is passed to ZzaScrollable which handles the listeners
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    // Clean up Autocomplete listener if registered
    if (_textListener != null && _autocompleteController != null) {
      _autocompleteController!.removeListener(_textListener!);
    }
    super.dispose();
  }

  Future<void> _fetchData() async {
    await _logic.fetchData(widget.participantId);
    if (mounted) setState(() {});
  }

  void _addItem(String name) {
    if (name.trim().isEmpty) {
      return;
    }
    setState(() {
      _logic.addItem(name);
      _controller.clear();
      _autocompleteController?.clear(); // Also clear visible TextField
      _ghostSuffix = ''; // Clear ghost on add
    });
    // Auto-scroll to bottom so newly added item is visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Update ghost text suffix for inline suggestion preview.
  void _updateGhostSuffix(String input) {
    if (input.isEmpty) {
      if (_ghostSuffix.isNotEmpty) setState(() => _ghostSuffix = '');
      return;
    }
    final normalizedInput = TextTools.normText(input);
    final match = _logic.names.firstWhere(
      (n) => TextTools.normText(n).startsWith(normalizedInput),
      orElse: () => '',
    );
    final newSuffix = match.isNotEmpty && match.length > input.length
        ? match.substring(input.length)
        : '';
    if (newSuffix != _ghostSuffix) {
      setState(() => _ghostSuffix = newSuffix);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Structure depends on whether parent provides bounded height
    // BOUNDED: Column(max) fills parent, Expanded list fills remaining
    // UNBOUNDED: Column(min) shrink-wraps, fixed height list
    return Column(
      mainAxisSize: widget.isBounded ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _logic.getText(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // List: Expanded if bounded, SizedBox if unbounded
        if (widget.isBounded)
          Expanded(child: _buildListContent())
        else
          _buildBoundedList(),

        // Input area
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildAutocomplete()),
              const SizedBox(width: AppSpacing.s),
              _buildAddButton(),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds fixed-height list for UNBOUNDED (scroll) mode only.
  /// In bounded mode, Expanded is used instead (see build method).
  Widget _buildBoundedList() {
    // UNBOUNDED: Use fixed height based on available screen height
    // on 720p (Compact), show ~2 items + peek to ensure it fits without page scroll.
    // on Tall screens, show ~3 items + peek for better visibility.
    final screenHeight = MediaQuery.sizeOf(context).height;
    // We use a local threshold of 800px here to catch standard 720p laptops
    // which fall outside the global 'compact' (600px) definition but still need space optimization.
    final isBrief = screenHeight < 800;

    // 2.7 items for compact (ensure peek + fit 720p), 3.7 for tall
    // Increased from 2.3/3.3 to guarantee "next item" peek is visible behind the 32px gradient
    final targetItems = isBrief ? 2.7 : 3.7;

    final listHeight =
        AppBreakpoints.getListHeight(context, itemCount: 1) * targetItems;

    return SizedBox(
      height: listHeight,
      child: _buildListContent(),
    );
  }

  /// Builds the actual list content with standard scroll signaling
  Widget _buildListContent() {
    // Wrap ZzaScrollable with Scrollbar so the thumb renders ON TOP of the gradients
    // This requires ZzaScrollable to bubble scroll events or share controller.
    // ZzaScrollable uses the SAME controller, so Scrollbar here works perfectly.
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true, // Always visible hint
      child: ZzaScrollable(
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          shrinkWrap: false, // Let it fill available space
          physics: const ClampingScrollPhysics(),
          itemCount: _logic.items.length,
          itemBuilder: (context, index) {
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline, size: 16),
              title: Text(
                _logic.items[index],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _logic.names.where((name) {
          return name
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (selection) {
        // Cancel any pending submit from onSubmitted (prevents double-add)
        _pendingSubmitValue = null;
        _suppressNextSubmit = true;
        // Add the selected suggestion
        _addItem(selection);
        // Clear the autocomplete's text field after frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _autocompleteController?.clear();
          setState(() => _ghostSuffix = '');
        });
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        // Register listener ONLY ONCE (Fix listener accumulation bug)
        if (_autocompleteController != textEditingController) {
          // Remove old listener if controller changed
          if (_textListener != null && _autocompleteController != null) {
            _autocompleteController!.removeListener(_textListener!);
          }
          _autocompleteController = textEditingController;
          _textListener = () {
            if (_controller.text != textEditingController.text) {
              _controller.text = textEditingController.text;
            }
            _updateGhostSuffix(textEditingController.text);
            if (_suppressNextSubmit && textEditingController.text.isNotEmpty) {
              _suppressNextSubmit = false;
            }
          };
          textEditingController.addListener(_textListener!);
        }

        // Key for E2E testing - allows testing robots to find this field
        // Wrap in Focus to capture Tab key for autocomplete
        return Focus(
          skipTraversal: true, // Don't include in tab traversal
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.tab) {
              // Tab autocomplete with diacritics support
              final normalizedInput =
                  TextTools.normText(textEditingController.text);
              if (normalizedInput.isEmpty) return KeyEventResult.ignored;

              final match = _logic.names.firstWhere(
                (n) => TextTools.normText(n).contains(normalizedInput),
                orElse: () => '',
              );
              if (match.isNotEmpty) {
                textEditingController.text = match;
                textEditingController.selection = TextSelection.collapsed(
                  offset: match.length,
                );
                return KeyEventResult.handled; // Consume Tab
              }
            }
            return KeyEventResult.ignored;
          },
          child: Stack(
            children: [
              // TextField first (at bottom of stack)
              TextField(
                key: Key('RestrictionsWidget_${_logic.getText()}_input'),
                controller: textEditingController,
                focusNode: focusNode,
                textInputAction:
                    TextInputAction.done, // Enable Enter submission
                onSubmitted: (value) {
                  if (_suppressNextSubmit) {
                    _suppressNextSubmit = false;
                    return;
                  }
                  // Defer add to next frame - allows onSelected to cancel if it fires
                  _pendingSubmitValue = value;
                  final hadFocus = focusNode.hasFocus;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    // Only add if onSelected didn't cancel it
                    if (_pendingSubmitValue != null) {
                      _addItem(_pendingSubmitValue!);
                      _pendingSubmitValue = null;
                      onFieldSubmitted(); // Close autocomplete dropdown
                      // Refocus if was focused
                      if (hadFocus && mounted) {
                        focusNode.requestFocus();
                      }
                    }
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Zadejte položku',
                  // Border and styling handled by ZzaTheme
                ),
              ),
              // Ghost text overlay second (on top with IgnorePointer)
              if (_ghostSuffix.isNotEmpty)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Padding(
                      // Match TextField's text baseline (title medium with label)
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                      child: Row(
                        children: [
                          // Invisible spacer for typed text width
                          Text(
                            textEditingController.text,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.transparent,
                                ),
                          ),
                          // Gray ghost suffix
                          Text(
                            _ghostSuffix,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.grey.shade400,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddButton() {
    // Key for E2E testing - allows testing robots to tap add button
    return IconButton(
      key: Key('RestrictionsWidget_${_logic.getText()}_add_button'),
      icon: const Icon(Icons.add_circle),
      color: Theme.of(context).primaryColor,
      tooltip: 'Přidat',
      onPressed: () {
        // Cancel any pending submit from Enter key (prevents double-add)
        _pendingSubmitValue = null;
        _suppressNextSubmit = false;

        // Use autocomplete's controller directly to avoid sync race condition
        // Falls back to _controller if autocomplete not yet built
        final text = _autocompleteController?.text ?? _controller.text;

        _addItem(text);
      },
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
