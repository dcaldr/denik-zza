import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/input/text_tools.dart';

class RestrictionsWidget extends StatefulWidget {
  final LogicInterface logic;
  final int? participantId;

  const RestrictionsWidget(
      {super.key, required this.logic, this.participantId});

  @override
  State<RestrictionsWidget> createState() => _RestrictionsWidgetState();
}

class _RestrictionsWidgetState extends State<RestrictionsWidget> {
  late final LogicInterface _logic;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasMoreBelow = false;
  String _ghostSuffix = ''; // For inline gray suggestion

  // References to Autocomplete's internal objects
  TextEditingController? _autocompleteController;
  VoidCallback? _textListener;

  // For preventing double-add: onSubmitted defers add, onSelected cancels it
  String? _pendingSubmitValue;

  @override
  void initState() {
    super.initState();
    _logic = widget.logic;
    _fetchData();
    _scrollController.addListener(_updateScrollIndicator);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicator);
    _scrollController.dispose();
    _controller.dispose();
    // Clean up Autocomplete listener if registered
    if (_textListener != null && _autocompleteController != null) {
      _autocompleteController!.removeListener(_textListener!);
    }
    super.dispose();
  }

  void _updateScrollIndicator() {
    if (!_scrollController.hasClients) return;
    final hasMore = _scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 10;
    if (hasMore != _hasMoreBelow) {
      setState(() => _hasMoreBelow = hasMore);
    }
  }

  Future<void> _fetchData() async {
    await _logic.fetchData(widget.participantId);
    if (mounted) setState(() {});
  }

  void _addItem(String name) {
    print('tmp_DEBUG: _addItem called with: "$name"');
    if (name.trim().isEmpty) return;
    setState(() {
      _logic.addItem(name);
      _controller.clear();
      _autocompleteController?.clear(); // Also clear visible TextField
      _ghostSuffix = ''; // Clear ghost on add
    });
    print('tmp_DEBUG: _addItem completed, items now: ${_logic.items}');
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
    // Removed SingleChildScrollView to prevent nested scroll wiggle.
    // Parent form handles scrolling. See /scroll-wiggle-prompt workflow.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _logic.getText(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.s),

        // Height-bounded list - always show to reserve fixed space
        _buildBoundedList(),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // If width is too small, stack vertically
              if (constraints.maxWidth < 200) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: _buildAutocomplete(),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: _buildAddButton(),
                    ),
                  ],
                );
              }

              // For normal widths, use horizontal layout
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildAutocomplete(),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  _buildAddButton(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds height-bounded list with scroll indicator when scrollable.
  Widget _buildBoundedList() {
    // Check for scroll indicator after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateScrollIndicator();
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use centralized helper: show 3 items + 25% peek for scroll hint
        // Handles both bounded and unbounded constraints
        final maxHeight = AppBreakpoints.listHeightForItems(
          context,
          constraints,
          itemCount: 3,
        );
        final maxWidth = constraints.maxWidth.clamp(0.0, 300.0);

        // Use SizedBox to reserve fixed space (doesn't shrink when empty)
        return SizedBox(
          width: maxWidth,
          height: maxHeight,
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
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
              // Gradient indicator when there's more content below
              if (_hasMoreBelow)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.greyBackground.withValues(alpha: 0.0),
                            AppColors.greyBackground.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.blueBackground,
                            borderRadius: AppRadii.containerRadius,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.keyboard_arrow_down,
                                  size: 12, color: AppColors.blueText),
                              Text('více',
                                  style: TextStyle(
                                      fontSize: 10, color: AppColors.blueText)),
                            ],
                          ),
                        ),
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
        print('tmp_DEBUG: onSelected FIRED with: "$selection"');
        // Cancel any pending submit from onSubmitted (prevents double-add)
        _pendingSubmitValue = null;
        print('tmp_DEBUG: Cancelled pending submit value');
        // Add the selected suggestion
        _addItem(selection);
        // Clear the autocomplete's text field after frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('tmp_DEBUG: postFrameCallback - clearing autocomplete field');
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
                  print('tmp_DEBUG: onSubmitted FIRED with: "$value"');
                  // Defer add to next frame - allows onSelected to cancel if it fires
                  _pendingSubmitValue = value;
                  print(
                      'tmp_DEBUG: Set pending submit value, deferring add to next frame');
                  final hadFocus = focusNode.hasFocus;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // Only add if onSelected didn't cancel it
                    if (_pendingSubmitValue != null) {
                      print(
                          'tmp_DEBUG: Pending value still set, adding: "$_pendingSubmitValue"');
                      _addItem(_pendingSubmitValue!);
                      _pendingSubmitValue = null;
                      onFieldSubmitted(); // Close autocomplete dropdown
                      // Refocus if was focused
                      if (hadFocus && mounted) {
                        focusNode.requestFocus();
                      }
                    } else {
                      print(
                          'tmp_DEBUG: Pending value was cancelled by onSelected');
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
        // We need to access the text from the Autocomplete's controller
        // But since we can't easily access it here without complex state management,
        // we'll rely on the user pressing Enter or selecting from list for now,
        // OR we can try to use the _controller if we bound it correctly.
        // In the original code, _controller.value was set in fieldViewBuilder.
        // Let's try to capture the text in fieldViewBuilder.

        // Actually, the original code did: _controller.value = textEditingController.value;
        // So _controller.text should be valid.
        _addItem(_controller.text);
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
